library(shiny)
library(dplyr)
library(ggplot2)
library(DT)

# Liste des ères classées de la première à la dernière 
ordre_eres <- c(
  "Âge du Fer", "Haut Moyen Âge", "Moyen Âge Classique", "Renaissance",
  "Âge Colonial", "Âge Industriel", "Ère Progressiste", "Ère Moderne",
  "Ère Postmoderne", "Ère Contemporaine", "Demain", "Ère du Futur",
  "Futur arctique", "Futur océanique", "Futur virtuel", "Ère spatiale - Mars",
  "Ère spatiale - Ceinture d'astéroïdes", "Ère spatiale - Vénus",
  "Ère spatiale - Lune de Jupiter", "Ère spatiale - Titan", "Ère spatiale : Hub spatial"
)


#====== Partie  interface====


ui <- navbarPage(
  "Projet Personnel Olivier Gabriel",
  
  # ===== Premier onglet : import des fichiers === 
  tabPanel("Aperçu des données",
           fluidPage(
             titlePanel("Import des fichiers CSV"),
             selectInput("choix", "Choisissez le fichier à importer :",
                         choices = c("GuildBuildings", "GuildGoods Maintenant", "GuildGoods Avant")),
             conditionalPanel(condition = "input.choix == 'GuildBuildings'",
                              fileInput("file1", "Importer le fichier GuildBuildings", accept = ".csv")),
             conditionalPanel(condition = "input.choix == 'GuildGoods Maintenant'",
                              fileInput("file2", "Importer le fichier GuildGoods (Maintenant)", accept = ".csv")),
             conditionalPanel(condition = "input.choix == 'GuildGoods Avant'",
                              fileInput("file3", "Importer le fichier GuildGoods (Avant)", accept = ".csv")),
             hr(),
             verbatimTextOutput("resume")
           )
  ),
  
  # ===== Deuxième onglet : aperçu des données pour chaque joueur === 
  
  tabPanel("Production par joueur",
           sidebarLayout(
             sidebarPanel(
               selectInput("player_choice", "Choisir un joueur :", choices = NULL)
             ),
             mainPanel(
               plotOutput("plot_prod_joueur"),
               h4("Détail de la production par ère"), 
               DTOutput("table_detail_joueur"),     
               hr(),
               h4("Classement général des membres"),
               DTOutput("table_prod_joueur")        
             )
           )
  ),
  
  # ===== Troisième onglet : aperçu des données pour chaque ère === 
  
  tabPanel("Production par ère",
           fluidPage(
             h3("Classement de toutes les ères"),
             fluidRow(
               column(12, wellPanel(DTOutput("table_globale_eres")))
             ),
             hr(),
             h3("2. Détails par ère sélectionnée"),
             sidebarLayout(
               sidebarPanel(
                 selectInput("era_choice", "Choisir une ère pour le détail :", choices = NULL),
                 uiOutput("res_total_era")
               ),
               mainPanel(
                 plotOutput("plot_prod_era"),
                 h4("Classement des joueurs pour cette ère"),
                 DTOutput("table_prod_era")
               )
             )
           )
  ),
  
  # ===== Quatrième onglet : calcul de l'évolution de la trésorerie === 
  
  tabPanel("Stock Maintenant vs Avant",
           fluidRow(
             column(12, plotOutput("plot_stock_diff")),
             column(6, h4("Ressources avec gain"), DTOutput("table_stock_gain")),
             column(6, h4("Ressources avec perte"), DTOutput("table_stock_loss"))
           )
  ),
  
  # ===== Cinquième onglet : aperçu des joueurs et des ressources en dessous d'une certaine limite === 
  tabPanel("Alertes",
           fluidPage(
             h4("Seuil d'alerte pour les ressources"),
             sliderInput("seuil_ressources",
                         "Stock minimum :",min = 0, max = 1000000,value = 300000, step = 10000),
             h4("Ressources en dessous du seuil"),
             DTOutput("table_alert_ressources"),
             hr(),
             h4("Seuil d'alerte pour les joueurs"),
             sliderInput("seuil_joueurs",
                         "Production minimum :",min = 0,max = 20000,value = 8000,step = 500),
             h4("Joueurs en dessous du seuil"),
             DTOutput("table_alert_joueurs")
           )
  ))

# ===== Partie serveur =====
server <- function(input, output, session) {
  
  # ===== Premier onglet : import des fichiers === 
  guild_buildings <- reactive({ req(input$file1); tryCatch({ read.csv2(input$file1$datapath) }, error=function(e) NULL) })
  guild_goods_maintenant <- reactive({ req(input$file2); tryCatch({ read.csv2(input$file2$datapath) }, error=function(e) NULL) })
  guild_goods_avant <- reactive({ req(input$file3); tryCatch({ read.csv2(input$file3$datapath) }, error=function(e) NULL) })
  
  output$resume <- renderPrint({
    df <- if (input$choix == "GuildBuildings") guild_buildings() else if (input$choix == "GuildGoods Maintenant") guild_goods_maintenant() else guild_goods_avant()
    req(df); head(df)
  })
  
  # ===== Deuxième onglet : aperçu des données pour chaque joueur === 
  observe({ df <- guild_buildings(); req(df); updateSelectInput(session, "player_choice", choices = unique(df$member)) })
  output$table_prod_joueur <- renderDT({
    df <- guild_buildings(); req(df)
    res <- df %>% group_by(member) %>% summarise(Total = sum(as.numeric(guildGoods), na.rm=T)) %>% arrange(desc(Total))
    datatable(res, options = list(paging = FALSE, searching = FALSE, dom = 't', ordering = TRUE))
  })
  output$plot_prod_joueur <- renderPlot({
    df <- guild_buildings(); req(df, input$player_choice)
    df %>% filter(member == input$player_choice) %>%
      ggplot(aes(x=factor(era, levels=ordre_eres), y=as.numeric(guildGoods))) +
      geom_bar(stat="identity", fill="steelblue") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(title=paste("Production de", input$player_choice), x="Ère",y="Production")
  })
  output$table_detail_joueur <- renderDT({
    df <- guild_buildings(); req(df, input$player_choice)
    
    res <- df %>% 
      filter(member == input$player_choice) %>%
      group_by(era) %>% 
      summarise(total_ressources = sum(as.numeric(guildGoods), na.rm = TRUE)) %>% 
      rename("Ère" = era, "Ressources produites" = total_ressources) %>%
      mutate(`Ère` = factor(`Ère`, levels = ordre_eres)) %>%
      arrange(desc(`Ère`))
    datatable(res, options = list(paging = FALSE, searching = FALSE, dom = 't', ordering = TRUE))
  })
  
  # ===== Troisième onglet : aperçu des données pour chaque ère === 
  observe({ df <- guild_buildings(); req(df); updateSelectInput(session, "era_choice", choices = intersect(ordre_eres, unique(df$era))) })
  
  output$table_globale_eres <- renderDT({
    df <- guild_buildings(); req(df)
    res <- df %>%
      group_by(era) %>%
      summarise(Production_Totale = sum(as.numeric(guildGoods), na.rm=T))
    
    res$era <- factor(res$era, levels = ordre_eres)
    res <- res %>% arrange(desc(era)) 
    
    datatable(res, options = list(paging = FALSE, searching = FALSE, dom = 't', ordering = TRUE))
  })
  
  output$table_prod_era <- renderDT({
    df <- guild_buildings(); req(df, input$era_choice)
    res <- df %>% filter(era == input$era_choice) %>% group_by(member) %>% summarise(Production = sum(as.numeric(guildGoods), na.rm=T)) %>% arrange(desc(Production))
    datatable(res, options = list(paging = FALSE, searching = FALSE, dom = 't', ordering = TRUE))
  })
  
  output$plot_prod_era <- renderPlot({
    df <- guild_buildings(); req(df, input$era_choice)
    df_p <- df %>% filter(era == input$era_choice) %>% group_by(member) %>% summarise(P = sum(as.numeric(guildGoods), na.rm=T))
    ggplot(df_p, aes(x=reorder(member, P), y=P)) + geom_bar(stat="identity", fill="orange") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) + labs(x="Joueur", title=input$era_choice)
  })
  
  output$res_total_era <- renderUI({
    df <- guild_buildings(); req(df, input$era_choice)
    t <- df %>% filter(era == input$era_choice) %>% summarise(s = sum(as.numeric(guildGoods), na.rm=T)) %>% pull(s)
    wellPanel(h4("Total Ère :"), h3(format(t, big.mark=" "), style="color:green"))
  })
  
  # ===== Quatrième onglet : calcul de l'évolution de la trésorerie === 
  stock_diff <- reactive({
    n <- guild_goods_maintenant(); b <- guild_goods_avant(); req(n, b)
    merge(n, b, by=c("eraID","good"), suffixes=c("_maintenant","_avant")) %>% mutate(diff = as.numeric(instock_maintenant) - as.numeric(instock_avant))
  })
  
  output$plot_stock_diff <- renderPlot({
    df <- stock_diff(); req(df); df_loss <- df %>% filter(diff < 0) %>% mutate(a = abs(diff))
    ggplot(df_loss, aes(x=reorder(good, a), y=a)) + geom_bar(stat="identity", fill="red") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) + labs(y="Perte", title="Graphique des pertes")
  })
  
  output$table_stock_gain <- renderDT({
    datatable(stock_diff() %>% filter(diff > 0) %>% select(good, diff),
              options = list(paging = FALSE, searching = FALSE, dom = 't', ordering = TRUE))
  })
  
  output$table_stock_loss <- renderDT({
    datatable(stock_diff() %>% filter(diff < 0) %>% select(good, diff),
              options = list(paging = FALSE, searching = FALSE, dom = 't', ordering = TRUE))
  })
  
  # ===== Cinquième onglet : aperçu des joueurs et des ressources en dessous d'une certaine limite === 
  output$table_alert_ressources <- renderDT({
    datatable(guild_goods_maintenant() %>% filter(as.numeric(instock) < input$seuil_ressources),
              options = list(paging = FALSE, searching = FALSE, dom = 't', ordering = TRUE))
  })
  
  output$table_alert_joueurs <- renderDT({
    df <- guild_buildings(); req(df)
    res <- df %>% group_by(member) %>% summarise(total = sum(as.numeric(guildGoods), na.rm=T)) %>% filter(total < input$seuil_joueurs)
    datatable(res, options = list(paging = FALSE, searching = FALSE, dom = 't', ordering = TRUE))
  })
}

shinyApp(ui, server)

