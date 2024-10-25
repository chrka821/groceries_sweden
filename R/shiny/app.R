library(shiny)

# Load the UI and server files
source("ui.R")
source("server.R")
source("global.R")

# Run the Shiny application
shinyApp(ui = ui, server = server)
