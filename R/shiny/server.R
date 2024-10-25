library(shiny)
library(jsonlite)
library(stringr)

server <- function(input, output, session) {
  
  # Create a reactive value to track the current page
  current_page <- reactiveVal("landing")  # Initially set to "landing" page
  
  # Store the ingredient list and products
  ingredients <- reactiveVal(data.frame(name = character(), quantity = numeric(), unit = character()))
  products <- reactiveVal(list())
  
  # Track selected ingredient for the results page
  selected_ingredient <- reactiveVal(NULL)
  
  # Define the landing page UI
  output$page_content <- renderUI({
    if (current_page() == "landing") {
      # Landing Page UI
      div(
        class = "landing-container",
        h1("ICA Produkt Sökning"),
        
        div(
          class = "description",
          "Välkommen! Ange dina ingredienser i JSON-format för att hitta relevanta ICA-produkter."
        ),
        
        textAreaInput("ingredient_json", NULL, placeholder = '[{"name": "Kycklingfilé", "quantity": 600, "unit": "g"}, {"name": "Broccoli", "quantity": 300, "unit": "g"}]'),
        
        actionButton("submit_ingredients", "Sök Produkter", class = "search-button")
      )
    } else if (current_page() == "results") {
      # Results Page UI
      fluidPage(
        tags$style(HTML("
            body { background-color: #b30000; color: white; }
            .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
            .product-item { border: 1px solid #ddd; padding: 10px; text-align: center; background-color: #fff; border-radius: 8px; color: black; }
            .product-item h5, .product-item p { color: black; }
            .nav-buttons { text-align: center; margin-top: 20px; }
            .btn-nav { background-color: #b30000; color: white; padding: 10px 20px; border-radius: 8px; font-weight: bold; cursor: pointer; }
            .btn-nav:hover { background-color: #990000; }
        ")),
        
        # Navigation buttons for ingredients
        fluidRow(
          div(class = "nav-buttons", lapply(names(products()), function(ingredient_name) {
            actionButton(inputId = paste0("select_", ingredient_name),
                         label = ingredient_name,
                         class = "btn-nav",
                         onclick = paste("Shiny.setInputValue('selected_ingredient', '", ingredient_name, "', {priority: 'event'});"))
          }))
        ),
        
        # Product grid for selected ingredient
        uiOutput("product_grid")
      )
    }
  })
  
  # Process ingredient search
  observeEvent(input$submit_ingredients, {
    # Parse JSON input
    ingredient_list <- fromJSON(input$ingredient_json, simplifyDataFrame = FALSE)
    ingredients(do.call(rbind, lapply(ingredient_list, as.data.frame)))
    
    # Fetch products for each ingredient (replace with actual API call)
    product_list <- list()
    for (ingredient in ingredient_list) {
      product_list[[ingredient$name]] <- ica_api_handler$search_product(ingredient$name)
    }
    products(product_list)
    
    # Set the first ingredient as selected and switch to results page
    selected_ingredient(names(product_list)[1])
    current_page("results")  # Switch to the results page
    
    # Trigger rendering of the first ingredient's products
    update_product_grid()
  })
  
  # Update product grid when ingredient is selected
  observeEvent(input$selected_ingredient, {
    selected_ingredient(input$selected_ingredient)
    update_product_grid()
  })
  
  # Render the product grid for the selected ingredient
  update_product_grid <- function() {
    output$product_grid <- renderUI({
      req(selected_ingredient())
      ingredient_products <- products()[[trimws(selected_ingredient())]]
      ingredient_required_quantity <- ingredients()$quantity[ingredients()$name == selected_ingredient()]
      # Display products in a grid layout
      div(class = "grid", lapply(ingredient_products, function(product) {
        
        # Calculate how many units of the product are needed
        units_required <- ceiling(ingredient_required_quantity / product$size$value)
        
        # Calculate the price for the recipe
        price_for_recipe <- product$price * units_required
        
        div(class = "product-item",
            tags$img(src = product$image_path, height = "100px"),
            h5(product$name),
            p(paste("Märke:", product$brand)),
            p(paste("Pris:", product$price, "SEK")),
            p(paste("Pris per enhet:", product$price_per_unit)),
            p(paste("Storlek:", product$size$value, product$size$unit)),
            p(paste("För recept: ", units_required, "x", product$size$value, product$size$unit, " = ", price_for_recipe, "SEK"))
        )
      }))
    })
  }
}
