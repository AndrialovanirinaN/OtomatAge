# Shiny application - Estimating fish age from otoliths
# Responsive version with bslib

# ---- App configuration ----

# 1. Load the required packages and data
library(shiny)
library(bslib)
library(shinyjs)
library(magick)
library(FNN)
library(DT)

# CONFIGURATION FOR HIGH-RESOLUTION IMAGES
options(shiny.maxRequestSize = 10*1024^2)  # 10MB instead of the default 5MB

# Load data
load('cleandata/model_age.RData')

# Function to obtain a random image
get_random_image <- function() {
  img_dir <- "data/img_app"
  
  # Check that the folder exists
  if (!dir.exists(img_dir)) {
    stop(paste("Le dossier", img_dir, "n'existe pas. Dossier de travail actuel:", getwd()))
  }
  
  # Supported image extensions (simpler pattern)
  pattern <- "\\.(tif|tiff|png|jpg|jpeg)$"
  
  # Retrieve all image files
  all_images <- list.files(img_dir, pattern = pattern, full.names = TRUE, ignore.case = TRUE)
  
  if (length(all_images) == 0) {
    stop(paste("Aucune image trouvée dans le dossier", img_dir, ". Fichiers présents:", 
               paste(list.files(img_dir), collapse = ", ")))
  }
  
  # Select a random image
  selected_image <- sample(all_images, 1)
  
  return(list(
    path = selected_image,
    name = tools::file_path_sans_ext(basename(selected_image))
  ))
}

# ---- User interface (frontend) ----
ui <- fluidPage(
  
  # Footer style 
  tags$style(tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Lato:wght@300;400;700&display=swap"),
             HTML("
    
    /* Lock navbar on top */
    .navbar {
      position: fixed;
      top: 0;
      width: 100%;
      z-index: 9999;
      border: 0px;
    }

    /* Adds a space so that the content does not go under the navbar */
    body {
      padding-top: 70px; /* Adjust to the height of your navbar */
    }
  
    .footer-logos {
      display: flex;
      justify-content: center;
      align-items: center;
      flex-wrap: wrap;
      margin-top: 50px;
      padding-bottom: 30px;
      gap: 30px;
      transition: all 0.3s ease-in-out;
    }
  
    .footer-logos img {
      height: auto;
      max-height: 60px;
      max-width: 120px;
      width: auto;
      transition: transform 0.3s ease, max-width 0.3s ease, max-height 0.3s ease;
    }
  
    /* Responsive for small screens */
    @media (max-width: 600px) {
      .footer-logos {
        flex-direction: column;
        gap: 20px;
      }
  
      .footer-logos img {
        max-width: 90px;
        max-height: 50px;
      }
    }
    
    .footer-copyright {
    text-align: center;
    padding: 10px 0;
    font-size: 12px;
    color: #777;
    }
    
    #viewer-container {
    width: 100%;
    height: 450px;
    border: 1px solid #ccc;
    margin-bottom: 20px;
    }
    
    .correct {
    color: green;
    font-weight: bold;
    }
    
    .wrong {
    color: red;
    font-weight: bold;
    }
    
    .btn {
    margin-top: 5px;
    margin-right: 5px;
    }
    
    .logo-container {
        text-align: center;
        padding: 15px;
        margin: 10px;
        border: 1px solid #ffffff;
        border-radius: 8px;
        background-color: #ffffff;
        height: 100px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
      
    .logo-img {
        max-width: 150px;
        max-height: 100px;
        width: auto;
        height: auto;
    }
      
    .row-spacing {
        margin-bottom: 10px;
    }
    
")),
  
  # Main interface
  page_navbar(
    
    title = "OTOmatAGE",
    theme = bs_theme(preset = "litera"),
    fillable = TRUE,
    
    # ---- Page 1 - Image analysis ----
    tabPanel(
      title = "Application",
      useShinyjs(),
      
      h6("Estimation de l'âge de la plie à l'aide de son otolithe"),
      
      layout_columns(
        col_widths = c(12, 12, 12),  # On mobile: 1 column, on desktop: 2 columns
        
        # First card - Display of the otolith
        card(
          card_header(
            class = "bg-primary text-white",
            h6("Affichage de l'otolithe")
          ),
          card_body(
            class = "text-center p-0",
            style = "height: calc(100% - 60px);", 
            plotOutput("image_display", 
                       height = "100%",
                       width = "100%"),
          ),
          min_height = "500px",
          max_height = "80vh",
          fill = TRUE
        ),
        
        # Second card - Age estimation
        card(
          card_header(
            class = "bg-primary text-white",
            h6("Estimation de l'âge")
          ),
          card_body(
            verbatimTextOutput("image_info"),
            conditionalPanel(
              condition = "output.data_available == true",
              numericInput("user_age", 
                           "Votre estimation d'âge (de 0 à 7+ ans):", 
                           value = 0, min = 0, max = 7, step = 1,
                           width = "100%"),
              div(
                actionButton("estimate_btn", 
                             "Cliquez pour vérifier l'âge", 
                             icon = icon("check"),
                             class = "btn-primary"),
                
                actionButton("reset_btn", 
                             " Charger un autre otolithe", 
                             icon = icon("refresh"), 
                             class = "btn-warning")
              ),
              conditionalPanel(
                condition = "output.show_results == true",
                div(
                    style = "font-style: italic;",
                    br(),
                    "Utilisez 'Charger un autre otolithe' pour continuer.")
              )
            )
          ),
          height = "100%"
        ),
        
        # Third card - Results (full width)
        card(
          card_header(
            class = "bg-primary text-white",
            h6("Résultats des estimations")
          ),
          card_body(
            conditionalPanel(
              condition = "output.show_results == true",
              h6("Comparaison des estimations :"),
              htmlOutput("results_display")
            ),
            conditionalPanel(
              condition = "output.show_results == false",
              div(class = "text-muted text-center p-4",
                  "Les résultats apparaîtront ici après votre estimation")
            )
          ),
          min_height = "200px"
        )
      )
    ),
    
    # ---- Page 2 - Descriptions ----
    tabPanel(
      title = "Description",
      
      # Main header
      div(class = "page-header",
          h4("OTOmatAGE", icon("microscope")),
          "Un outil ludique et scientifique qui vous plonge dans le monde fascinant des otolithes"
      ),
      
      # Introduction
      div(class = "card mb-4",
          div(class = "card-body",
              "Les biologistes marins étudient l’âge des poissons pour connaître la santé des populations et suivre leur croissance, 
              comme on le fait pour les humains lors d’un recensement.",
              tags$br(), 
              
              "Pour connaître l'âge d'un poisson, on observe ses otolithes, de petits os situés dans son oreille interne.
            Chaque année, une nouvelle couche s'y dépose comme les cernes d'un arbre.
            En les étudiant, on peut donc estimer l'âge du poisson.", tags$br(),
              
              div(class = "well well-sm",
                  h6("Le rôle de l'IA ", icon("robot")), hr(),
                    "Traditionnellement, ce travail demande un œil expert et beaucoup de patience.
                C'est là qu'intervient OTOmatAGE : une intelligence artificielle (IA) entraînée 
                à reconnaître la forme des otolithes et à prédire automatiquement l'âge d'une 
                plie (un poisson plat très commun dans nos mers).", tags$br()
              )
          )
      ),
      
      # Species used
      div(class = "card mb-4",
          div(class = "card-header",
              h5(class = "mb-0", icon("fish"), " Espèce utilisée : Plie commune")
          ),
          div(class = "card-body",
              div(class = "row",
                  div(class = "col-md-4",
                      h6("Classification scientifique :"),
                      tags$br(),
                      icon("chevron-right"), " Embranchement : Chordata", 
                      tags$br(),
                      icon("chevron-right"), " Classe : Actinopterygii",
                      tags$br(),
                      icon("chevron-right"), " Ordre : Pleuronectiformes",
                      tags$br(),
                      icon("chevron-right"), " Famille : Pleuronectidae",
                      tags$br(),
                      icon("chevron-right"), " Nom latin : ", tags$i("Pleuronectes platessa")
                  ),
                  div(class = "col-md-4 text-center",
                      h6(icon("camera"), " Photo d'une plie"),
                      tags$img(
                        src = "img/plie.png",
                        alt = "Plie commune",
                        class = "img-fluid",
                        style = "max-width: 100%; max-height: 150px;"
                      )
                  ),
                  div(class = "col-md-4 text-center",
                      h6("Otolithe d'une plie de 3 ans"),
                      tags$img(
                        src = "img/otolith_plie.png",
                        alt = "Otolithe de plie",
                        class = "img-fluid",
                        style = "max-width: 100%; max-height: 150px;"
                      )
                  )
              )
          )
      ),
      
      # It's your turn
      div(class = "panel panel-primary mb-4",
          div(class = "panel-heading",
              h5(class = "panel-title", " À vous de jouer")
          ),
          div(class = "panel-body",
              "Sur la page application, vous pouvez observer des images d'otolithes, 
            faire votre propre estimation de l'âge du poisson, puis comparer 
            votre réponse à celle de l'IA et au vrai résultat.", tags$br(),
              "Saurez-vous battre la machine ?", tags$br(),
              " C'est une belle façon de découvrir le travail des biologistes marins tout en s'amusant."
          )
      ),
      
      # Why it matters
      div(class = "card mb-4",
          div(class = "card-header",
              h5(class = "mb-0", icon("lightbulb"), " Pourquoi c'est important")
          ),
          div(class = "card-body",
              "Mieux connaître l'âge des poissons aide les chercheurs à :",
              tags$ul(style = "list-style-type: none;",
                tags$li(icon("chart-line"), " Suivre la croissance des populations"),
                tags$li(icon("thermometer-half"), " Comprendre les effets du climat sur la mer"),
                tags$li(icon("shield-alt"), " Protéger les ressources marines pour les générations futures")
              ),
              div(class = "well well-sm mt-3",
                    "Chaque otolithe raconte une histoire
                    et grâce à OTOmatAGE, vous pouvez la lire vous aussi."
              )
          )
      )
    ),
    
    # ---- Page 3 - Partner ----
    tabPanel(
      title = "Partenaires",
      
      div(
        class = "container-fluid py-4",
        
        # Institutional partner
        card(
          card_header("Partenaires institutionnels"),
          card_body(
            div(
              class = "text-center p-3",
              h6("Université Littoral Côte d'Opale"),
              "Laboratoire d'Informatique Signal & Image de la Côte d'Opale",
              hr(),
              h6("Ifremer - Unité Halieutique Manche-Mer du Nord"),
              "Laboratoire Ressources Halieutiques - Pôle Sclérochronologie"
            )
          )
        ),
        
        # Technical partners
        card(
          card_header("Partenaires financiers"),
          card_body(
            div(
              class = "text-center p-3",
              h6("CPER CornelIA (2021-2027)"),
              "Co-construction responsable et durable d’une Intelligence Artificielle",
              hr(),
              h6("IFSEA graduate school • ANR-21-EXES-00 11"),
              "Provenant de l'Agence Nationale de la Recherche dans le cadre du Programmes d’investissements d'avenir."
            )
          )
        )
      ),
      
      # Contact
      div(
        class = "mt-4 p-3 bg-light rounded",
        # Row 1 - Official Partners (7 logos, will wrap to multiple lines)
        fluidRow(class = "row-spacing",
                 column(4, 
                        div(class = "logo-container",
                            img(src = "partenaires/par_off_1.png", class = "logo-img", alt = "Official Partner 1")
                        )
                 ),
                 column(4, 
                        div(class = "logo-container",
                            img(src = "partenaires/par_off_2.png", class = "logo-img", alt = "Official Partner 2")
                        )
                 ),
                 column(4, 
                        div(class = "logo-container",
                            img(src = "partenaires/par_off_3.png", class = "logo-img", alt = "Official Partner 3")
                        )
                 )
        ),
        fluidRow(class = "row-spacing",
                 column(4, 
                        div(class = "logo-container",
                            img(src = "partenaires/par_off_4.png", class = "logo-img", alt = "Official Partner 4")
                        )
                 ),
                 column(4, 
                        div(class = "logo-container",
                            img(src = "partenaires/par_off_5.png", class = "logo-img", alt = "Official Partner 5")
                        )
                 ),
                 column(4, 
                        div(class = "logo-container",
                            img(src = "partenaires/par_off_6.png", class = "logo-img", alt = "Official Partner 6")
                        )
                 )
        ),
        fluidRow(class = "row-spacing",
                 column(4, 
                        div(class = "logo-container",
                            img(src = "partenaires/par_off_7.png", class = "logo-img", alt = "Official Partner 7")
                        )
                 )
        ),
        
        # Row 2 - Project Partners (5 logos)
        fluidRow(class = "row-spacing",
                 column(4, 
                        div(class = "logo-container",
                            img(src = "partenaires/proj_1.png", class = "logo-img", alt = "Project Partner 1")
                        )
                 ),
                 column(4, 
                        div(class = "logo-container",
                            img(src = "partenaires/proj_3.png", class = "logo-img", alt = "Project Partner 3")
                        )
                 ),
                 column(4, 
                        div(class = "logo-container",
                            img(src = "partenaires/proj_4.png", class = "logo-img", alt = "Project Partner 4")
                        )
                 )
        ),
        fluidRow(class = "row-spacing",
                 column(4, 
                        div(class = "logo-container",
                            img(src = "partenaires/proj_5.png", class = "logo-img", alt = "Project Partner 5")
                        )
                 )
        )
      )

    ),
    
    # ---- Page 4 - Licence ----
    tabPanel(
      title = "Licence",
      
      div(
        class = "container-fluid py-4",
        
        # Software licence
        card(
          card_header("Licence du logiciel"),
          card_body(
            h6("MIT License"),
            "Cette application est distribuée sous licence MIT.",
            
            tags$pre(
              class = "bg-light p-3 rounded",
              "MIT License

Copyright © 2025 Nicolas Andrialovanirina, Emilie Poisson Caillault, Kélig Mahé

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the Software), to deal in the
Software without restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software."
            )
          )
        ),
        
        br(),
        
        # Terms of use
        card(
          card_header("Conditions d'utilisation"),
          card_body(
            h6("Usage autorisé"),
            tags$ul(
              tags$li("Usage éducatif uniquement")
            ),
            
            h6("Limitations"),
            tags$ul(
              tags$li("Les estimations sont données à titre indicatif"),
              tags$li("Validation par un expert recommandée"),
              tags$li("Ne pas utiliser comme seule méthode de détermination d'âge")
            ),
            
            h6("Responsabilité"),
            "Les développeurs ne peuvent être tenus responsables des erreurs d'estimation. 
                Cette application n'est pas un outil d'aide à la décision, il ne remplace pas l'expertise humaine."
          )
        )
        
      )
    ),
    
    # Logos on bottom
    div(
      class = "footer-logos",
      tags$a(href = "https://manchemerdunord.ifremer.fr/", target = "_blank",
             img(src = "logo/ifremer.png", alt = "Ifremer")),
      
      tags$a(href = "https://www.univ-littoral.fr/", target = "_blank",
             img(src = "logo/ulco.png", alt = "ULCO")),
      
      tags$a(href = "https://www-lisic.univ-littoral.fr/", target = "_blank",
             img(src = "logo/lisic.png", alt = "LISIC"))
    ),
    
    # Copyright
    div(
      class = "footer-copyright",
      HTML("Copyright &copy; 2025 Nicolas Andrialovanirina, Emilie Poisson Caillault, Kélig Mahé.")
    )
    
  )
)

# ---- Server (backend) ----
server <- function(input, output, session) {
  
  # Reactive variables
  values <- reactiveValues(
    current_image = NULL,
    image_name = NULL,
    image_data = NULL,
    user_estimation = NULL,
    knn_estimation = NULL,
    real_age = NULL,
    image_path = NULL
  )
  
  # Fonction pour charger une image
  load_image <- function() {
    tryCatch({
      
      random_img <- get_random_image()
      
      # Function to load an image
      values$current_image <- magick::image_read(random_img$path)
      values$current_image <- magick::image_normalize(values$current_image)
      values$image_name <- random_img$name
      values$image_path <- random_img$path
      
      
      # Retrieve univariate data
      img_data_match <- data[data$IDimg == values$image_name, ]
      
      if(nrow(img_data_match) > 0) {
        values$image_data <- img_data_match
      } else {
        values$image_data <- NULL
        showNotification("Image chargée mais données non trouvées dans le dataset", type = "warning", duration = 3)
      }
      
      # Reset estimates
      values$user_estimation <- NULL
      values$knn_estimation <- NULL
      values$real_age <- NULL
      updateNumericInput(session, "user_age", value = 0)
      
      # Reactivate controls if they were disabled
      shinyjs::enable("user_age")
      shinyjs::enable("estimate_btn")
      
    }, error = function(e) {
      print(paste("Erreur:", e$message))  # Debug
      showNotification(paste("Erreur lors du chargement:", e$message), type = "error", duration = 5)
    })
  }
  
  # Reset the application
  observeEvent(input$reset_btn, {
    # Reset all reactive variables
    values$current_image <- NULL
    values$image_name <- NULL
    values$image_data <- NULL
    values$user_estimation <- NULL
    values$knn_estimation <- NULL
    values$real_age <- NULL
    values$image_path <- NULL
    
    # Reset and reactivate inputs
    updateNumericInput(session, "user_age", value = 0)
    shinyjs::enable("user_age")
    shinyjs::enable("estimate_btn")
    
    # Reset notification
    showNotification("Image réinitialisée", type = "message", duration = 2)
  })
  
  # Debug - button to list images
  observeEvent(input$debug_btn, {
    tryCatch({
      img_dir <- "data/img_app"
      print(paste("Dossier de travail:", getwd()))
      print(paste("Vérification du dossier:", img_dir))
      print(paste("Le dossier existe-t-il?", dir.exists(img_dir)))
      
      if(dir.exists(img_dir)) {
        all_files <- list.files(img_dir, full.names = FALSE)
        print(paste("Tous les fichiers dans le dossier:", paste(all_files, collapse = ", ")))
        
        pattern <- "\\.(tif|tiff|png|jpg|jpeg)$"
        img_files <- list.files(img_dir, pattern = pattern, full.names = FALSE, ignore.case = TRUE)
        print(paste("Fichiers images trouvés:", paste(img_files, collapse = ", ")))
        
      } else {
        print("Le dossier n'existe pas!")
        showNotification("Le dossier 'data/img_app' n'existe pas!", type = "error", duration = 5)
      }
    }, error = function(e) {
      print(paste("Erreur debug:", e$message))
      showNotification(paste("Erreur debug:", e$message), type = "error", duration = 5)
    })
  })
  
  # Load an image at start-up (optional)
  observe({
    # Wait for the session to initialise
    invalidateLater(1000, session)
    isolate({
      if(is.null(values$current_image)) {
        load_image()
      }
    })
  })
  
  # Display the name of the current image
  output$current_image_name <- renderText({
    if (!is.null(values$image_name)) {
      paste("Image actuelle :", values$image_name)
    } else {
      "Aucune image chargée"
    }
  })
  
  # Image display
  output$image_display <- renderPlot({
    if (!is.null(values$current_image)) {
      plot(values$current_image)
    } else {
      plot.new()
      text(0.5, 0.5, "Aucune image chargée", cex = 1.5, col = "gray")
    }
  })
  
  # Image information
  output$image_info <- renderText({
    if (!is.null(values$image_name)) {
      if (!is.null(values$image_data)) {
        
      } else {
        paste("Attention : données univariées non extraites pour cette image")
      }
    } else {
      "Aucune image chargée"
    }
  })
  
  # Check whether the data is available
  output$data_available <- reactive({
    !is.null(values$image_data)
  })
  outputOptions(output, "data_available", suspendWhenHidden = FALSE)
  
  # Age estimation
  observeEvent(input$estimate_btn, {
    req(values$image_data, input$user_age)
    
    tryCatch({
      # User rating
      values$user_estimation <- input$user_age
      
      # Disable controls to prevent changing the answer
      shinyjs::disable("user_age")
      shinyjs::disable("estimate_btn")
      
      # Prepare data for KNN
      img_data_test <- values$image_data[1, !(names(values$image_data) %in% c("IDimg", "Side", "Age"))]
      train_features <- train[, !(names(train) %in% c("IDimg", "Side", "Age"))]
      
      # KNN Estimation
      knn_result <- knn.reg(train = train_features, 
                            test = img_data_test, 
                            y = train$Age, 
                            k = 7)
      values$knn_estimation <- round(knn_result$pred)
      
      # Actual age
      values$real_age <- values$image_data$Age[1]
      
    }, error = function(e) {
      showNotification(paste("Erreur lors de l'estimation:", e$message), type = "error")
    })
  })
  
  # Displaying results
  output$show_results <- reactive({
    !is.null(values$user_estimation) && !is.null(values$knn_estimation)
  })
  outputOptions(output, "show_results", suspendWhenHidden = FALSE)
  
  output$results_display <- renderUI({
    if (!is.null(values$user_estimation) && !is.null(values$knn_estimation)) {
      
      # Determine whether the estimates are correct
      user_correct <- values$user_estimation == values$real_age
      knn_correct <- values$knn_estimation == values$real_age
      
      # Colours and icons according to accuracy
      user_color <- if(user_correct) "#28a745" else "#dc3545"  # green ou red
      knn_color <- if(knn_correct) "#28a745" else "#dc3545"
      
      user_icon <- if(user_correct) "check-circle" else "times-circle"
      knn_icon <- if(knn_correct) "check-circle" else "times-circle"
      
      tagList(
        # Actual age
        if(values$real_age<=1){
          div(class = "alert alert-light text-center",
              style = "font-size: 20px; font-weight: bold;",
              icon("bullseye", style = "margin-right: 8px;"),
              paste("Âge réel :", values$real_age, "an"))
        } else {
          div(class = "alert alert-light text-center",
              style = "font-size: 20px; font-weight: bold;",
              icon("bullseye", style = "margin-right: 8px;"),
              paste("Âge réel :", values$real_age, "ans"))
        },
        
        br(),
        
        # Responsive layout for estimates
        layout_columns(
          col_widths = c(12, 12),
          
          # User estimation
          div(class = if(user_correct) "alert alert-success" else "alert alert-danger",
              style = "font-size: 18px; font-weight: bold; text-center;",
              icon(user_icon, style = "margin-right: 8px;"),
              paste("Votre estimation :", values$user_estimation)),
          
          # IA estimation
          div(class = if(knn_correct) "alert alert-success" else "alert alert-danger",
              style = "font-size: 18px; font-weight: bold; text-center;",
              icon(knn_icon, style = "margin-right: 8px;"),
              paste("Estimation de l'IA :", values$knn_estimation))
        ),
        
        # Performance summary between user and IA
        div(class = "text-center",
            style = "font-size: 16px;",
            if(user_correct && knn_correct) {
              div(class = "alert alert-success",
                  icon("trophy", style = "margin-right: 5px;"),
                  "Excellent ! Vous et l'IA avez tous les deux trouvé la bonne réponse !")
            } else if(!user_correct && !knn_correct) {
              div(class = "alert alert-warning",
                  icon("exclamation-triangle", style = "margin-right: 5px;"),
                  "Aucune estimation n'était correcte cette fois.")
            } else if(user_correct) {
              div(class = "alert alert-success",
                  icon("star", style = "margin-right: 5px;"),
                  "Bravo ! Votre estimation était correcte, contrairement à l'IA.")
            } else {
              div(class = "alert alert-info",
                  icon("robot", style = "margin-right: 5px;"),
                  "L'IA a trouvé la bonne réponse cette fois.")
            }
        )
      )
    }
  })
}

# ---- Run the application ----
shinyApp(ui = ui, server = server)