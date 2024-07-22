library(shiny)
library(shinyMobile)
library(shinyTime)
library(RPostgreSQL)
library(DBI)
library(dplyr)
library(tidyr)
library(exifr)
library(DT)
library(leaflet)
library(leaflet.extras)
library(htmltools)

current_date <- Sys.Date()
tunisian_cities <- read.csv("./www/port_positions.csv")
gear_list = data.frame(gear = c("Purse Seines", "Trawlers", "Drifting Longlines",
                              "Set Longlines", "Tuna Purse Seines",
                              "Set Gillnets", "Fixed Gear", "Dredge Fishing",
                              "Other"))
# Function to connect to the pelagic database
connectPelagic <- function() {
  dbConnect(PostgreSQL(), user = 'spr', password = 'spr_pass', dbname = 'med_monitoring', host = 'localhost', port = 5432)
}

# Fetch distinct species names from taxonomy3 table
fetchSpeciesNames <- function() {
  con <- connectPelagic()
  if (!is.null(con)) {
    query <- "SELECT DISTINCT main_common_name FROM taxonomy3 ORDER BY main_common_name"
    species_data <- dbGetQuery(con, query)
    species_names <- c("", species_data$main_common_name)
    dbDisconnect(con)
    return(species_names)
  }
  return(character(0))
}

# Custom CSS to fix the dropdown issue, add borders to input fields, style the navbar, and center form inputs
customCSS <- "
.dropdown-menu {
  z-index: 9999 !important;
}

.selectize-input input {
  color: #000000 !important; /* Change text color to black */
}

.shiny-input-container {
  padding-left: 20px;  /* Adjust this value as needed */
  margin-bottom: 15px; /* Add margin between input fields */
}

.shiny-input-container input, 
.shiny-input-container select, 
.shiny-input-container textarea {
  border: 2px solid #ddd !important;
  padding: 10px;
  border-radius: 5px;
}

#submit {
  display: block; /* Make sure the button is a block-level element */
  margin: 0 auto; /* Auto margins on the left and right */
  width: 50%; /* Adjust the width as needed */
  height: 60px; /* Adjust the height as needed */
  font-size: 20px; /* Increase the font size of the button text */
}

/* Optional: Custom CSS to style the image */
.top-image {
  width: 300px;
  height: auto;
  display: block;
  margin-left: 0; /* Align the image to the left */
  margin-right: auto;
  padding: 5px; /* Adjust or remove padding as needed */
  border-radius: 10px; /* This creates rounded corners */
}

.maps-image {
  max-width: 600px;
  height: auto;
  display: block;
  margin-left: 0; /* Align the image to the left */
  margin-right: auto;
  padding: 5px; /* Adjust or remove padding as needed */
  border-radius: 10px; /* This creates rounded corners */
}

.news-item figcaption {
  max-width: 250px; /* Match the max-width of the image */
  word-wrap: break-word; /* Ensure long words are broken to fit the width */
  margin-left: 0; /* Align the caption with the image */
  padding: 5px; /* Optional: add padding for better readability */
}

/* Custom CSS for navbar */
.navbar-nav > li > a {
  padding-top: 10px;
  padding-bottom: 10px;
}

.navbar {
  background-color: white !important;
}

.navbar-brand {
  line-height: 30px;
  height: 60px;
  padding: 1 15px;
}

.navbar-right {
  height: 30px;
  display: flex;
  align-items: center;
}

.navbar-right img {
  height: 40px;
}

/* Centering form inputs */
.centered-form {
  display: flex;
  justify-content: left;
  align-items: left;
}

.centered-form .f7-card {
  width: 100%;
}
"

Sys.setenv(TZ = "America/New_York")
current_time <- Sys.time()
date_str <- format(current_time, "%Y-%m-%d")
current_date <- as.Date(date_str)

# UI definition
ui <- navbarPage(
  title = tags$div(
    class = "navbar-right",
    tags$img(src = "tunisia-flag-round-shape-png.png"),
    "Tunisia Fisheries App"
    ),
  tags$head(
    tags$style(HTML(customCSS)),
    tags$script(HTML("
      $(document).on('click', 'a[href^=\"#\"]', function(event) {
        event.preventDefault();
        var target = this.getAttribute('href').substring(1);
        $('a[data-value=\"' + target + '\"]').tab('show');
      });
    ")) # JavaScript for tab navigation
  ),
  tabPanel(
    title = "Home",
    icon = icon("home"),
    fluidPage(
      h2("Welcome to the Tunisian App for Fisheries Monitoring!"),
      h2("Bienvenue sur l'application tunisienne de surveillance des pêches!"),
      p("Use the navigation bar to access different sections of the app."),
      br(),
      h3("Mission"),
      p("This application provides catch reporting for Tunisian fishermen, vessel activity maps, and emerging news in ocean transparency initiatives."),
      p("Cette application fournit des rapports de captures pour les pêcheurs tunisiens, des cartes d'activité des navires et des nouvelles émergentes sur les initiatives de transparence des océans."),
      p("يوفر هذا التطبيق تقارير عن الصيد للصيادين التونسيين وخرائط نشاط السفن والأخبار الناشئة في مبادرات الشفافية في المحيطات."),
      tags$ul(
        tags$li(tags$a(href = "#NewCatch", "New Catch - Log your fishing data")),
        tags$li(tags$a(href = "#Maps", "Maps - View real-time fishing activity"))
      ),
      br(),
      h4("Recent News"),
      fluidRow(
        column(4,
          tags$div(
            class = "news-item",
            tags$a(
              href = "https://www.theguardian.com/environment/article/2024/may/07/scaling-up-the-app-thats-transforming-lives-in-south-african-fishing-communities",
              tags$img(src = "https://i.guim.co.uk/img/media/f2c1e23b0dba091fd7276bb284344c1f4be7fb73/0_0_1600_2000/master/1600.jpg?width=1140&dpr=2&s=none", class = "top-image"),
              tags$figcaption("Scaling up the app that's transforming lives in South African fishing communities - The Guardian")
            )
          )
        ),
        column(4,
          tags$div(
            class = "news-item",
            tags$a(
              href = "https://www.sharkproject.org/en/protection/white-shark-chase/#:~:text=Among%20the%20most%20heavily%20over,one%20category%20away%20from%20extinction.",
              tags$img(src = "https://www.sharkproject.org/media/y5blqrzb/herbert_futterknecht_white_shark8.jpg?crop=0.063541666666666663,0,0.31145833333333334,0&cropmode=percentage&width=800&height=800&rnd=132800870252900000", class = "top-image"),
              tags$figcaption("White Shark Chase - An international collaboration to find and protect the last remaining white sharks of the Mediterranean Sea.")
            )
          )
        ),
        column(4,
          tags$div(
            class = "news-item",
            tags$a(
              href = "https://www.fao.org/gfcm/news/detail/en/c/1683407/",
              tags$img(src = "https://gfcmsitestorage.blob.core.windows.net/website/6.News/5-june-24/MOR_20190423_Fnideq_PDA_SSF@FAO_GFCM_Claudia_Amico_DSC01430.jpg", class = "top-image"),
              tags$figcaption("Strengthening collective efforts to eradicate IUU fishing and ensure compliance - FAO")
            )
          )
        )
      ),
      br(),
      h4("Sponsors")
    )
  ),
  tabPanel(
    title = "New Catch",
    icon = icon("pencil-square"),
    value = "NewCatch", # Value for tab navigation
    fluidPage(
      tags$div(
        class = "centered-form",
        f7Card(
          title = h3("Record A New Catch"),
          br(),
          br(),
          fluidRow(
          f7List(
            column(4,
            textInput("angler", "Your Name"),
            textInput("boat", "Boat Name"),
            shiny::dateInput("catch_date", "Date", value = current_date),
            # selectizeInput("species", "Shark and Ray Species", choices = NULL, options = list(placeholder = 'Start typing...', create = TRUE)),
            selectizeInput("port", "Port of Use", choices = NULL, options = list(placeholder = 'Type or Select', create = TRUE)),
            selectizeInput("gear", "Fishing Gear", choices = NULL, options = list(placeholder = 'Type or Select', create = TRUE)),

            numericInput("species_richness", "How many species did you catch?", value = NULL),

            numericInput("weight", "Weight of Total Catch (kg)", value = NULL),
            sliderInput("fishing_hours", "How many hours were you fishing?", min = 0, max = 24, value = 0, step = 0.5)
            ),
            column(4,
            radioButtons("ais", "Are you using AIS/VMS?", width = "70%", choices = c("Yes" = "TRUE", "No" = "FALSE", "Not Sure" = "not sure"), selected = character(0)),
            fileInput("file", "Upload an Image of Your Catch!",
            accept = c("image/jpeg", "image/jpg", "image/png", "image/JPG",
                        "image/JPEG", "image/heic", "image/HEIC", "image/heif", "image/HEIF")),
            textAreaInput("notes", "Comments", "", rows = 5, cols = 40)
            ),
            column(4,
            h3("Where were you fishing?"),
            br(),
            numericInput("latitude", "Latitude", value = NULL),
            numericInput("longitude", "Longitude", value = NULL),
            leafletOutput("map", height = 400))
          )
          ),
          style = "font-size: 18px;"
        )
      ),
      f7Button(inputId = "submit", label = "Submit")
    )
  ),
  tabPanel(
    title = "Maps",
    icon = icon("map"),
    value = "Maps", # Value for tab navigation
fluidPage(
  tabsetPanel(
    tabPanel(h4("Fishing Activity"),
             htmlOutput("fishing_activity_map")
    ),
    tabPanel(h4("Fishing Effort"),
             htmlOutput("fishing_effort_grid")
    )
  )
  )
)
)

server <- function(input, output, session) {

  output$fishing_activity_map <- renderUI({
      tags$iframe(src = "fishing_activity_map.html", width = "100%", height = "600px")
    })
  
  output$fishing_effort_grid <- renderUI({
    tags$iframe(src = "fishing_effort_grid.html", width = "100%", height = "600px")
  })

  # Server-side selectize for species
  # updateSelectizeInput(session, 'species', choices = fetchSpeciesNames(), server = TRUE)
  updateSelectizeInput(session, 'port', choices = c("", as.character(tunisian_cities$port), "Other"), server = TRUE)
  updateSelectizeInput(session, 'gear', choices = c("", as.character(gear_list$gear), "Other"), server = TRUE)
  observeEvent(input$submit, {
    # Initialize lat and lon with NA
    lat <- input$latitude
    lon <- input$longitude
    imageName <- NA

    if (!is.null(input$file)) {
      uploadedFile <- input$file
      destPath <- paste0(getwd(), "/www/", uploadedFile$name)
      file.rename(uploadedFile$datapath, destPath)
      imageName <- as.character(uploadedFile$name)
      
      # Attempt to extract EXIF data
      exifData <- read_exif(destPath)
      
      # Check if GPSLatitude and GPSLongitude exist in the exifData
      if ("GPSLatitude" %in% names(exifData) && "GPSLongitude" %in% names(exifData)) {
        lat <- exifData$GPSLatitude
        lon <- exifData$GPSLongitude
      }
    }

    new_entry <- data.frame(
      date = as.Date(input$catch_date),
      port = input$port,
      # species = input$species,
      species_richness = as.numeric(input$species_richness),
      # fl = as.numeric(input$fl),
      weight = as.numeric(input$weight),
      img_name = imageName,
      gear = input$gear,
      fishing_hours = as.numeric(input$fishing_hours),
      latitude = lat,
      longitude = lon,
      angler = input$angler,
      boat = input$boat,
      notes = input$notes,
      ais = input$ais,
      stringsAsFactors = FALSE
    )

    con <- connectPelagic()
    tryCatch({
      dbWriteTable(con, "catch_log", new_entry, append = TRUE, row.names = FALSE)
      dbDisconnect(con)
      shiny::showNotification("Catch logged successfully!", type = "message")
    }, error = function(e) {
      shiny::showNotification(as.character(e), type = "error")
    })
  })

output$map <- renderLeaflet({
  leaflet() %>%
    addTiles() %>%
    setView(lng = 11, lat = 35.8, zoom = 6.5) %>% # Centered around the Tunisian coast
    addDrawToolbar(
      targetGroup = 'selected',
      editOptions = editToolbarOptions(selectedPathOptions = selectedPathOptions()),
      polylineOptions = FALSE,
      polygonOptions = FALSE,
      rectangleOptions = FALSE,
      circleOptions = FALSE,
      markerOptions = drawMarkerOptions(repeatMode = FALSE),
      circleMarkerOptions = FALSE
    ) %>%
    addLayersControl(
      overlayGroups = c('selected'),
      options = layersControlOptions(collapsed = FALSE)
    )
})

observeEvent(input$map_draw_new_feature, {
  # Remove existing markers
  leafletProxy("map") %>% clearGroup("selected")
  
  feature <- input$map_draw_new_feature
  if (!is.null(feature)) {
    # Ensure coordinates are numeric
    lat <- as.numeric(feature$geometry$coordinates[2])
    lon <- as.numeric(feature$geometry$coordinates[1])
    updateNumericInput(session, "latitude", value = lat)
    updateNumericInput(session, "longitude", value = lon)
    
    # Add the new marker
    leafletProxy("map") %>% addMarkers(
      lng = lon, lat = lat, group = "selected"
    )
  }
})

}

shinyApp(ui, server)
