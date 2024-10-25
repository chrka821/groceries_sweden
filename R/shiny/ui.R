library(shiny)

ui <- fluidPage(
  # Global CSS styles
  tags$style(HTML("
      body {
        background-color: #b30000; /* Red background */
        font-family: 'Arial', sans-serif;
      }
      /* Landing page container centered vertically and horizontally */
      .landing-container {
        max-width: 600px;
        margin: 15% auto;
        padding: 40px;
        background-color: #fff; /* White background for the content */
        border-radius: 12px;
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
        text-align: center;
      }
      h1 {
        color: #b30000;
        font-size: 2.5em;
        font-weight: bold;
      }
      .description {
        font-size: 1.1em;
        margin-bottom: 30px;
        color: #666;
      }
      #ingredient_json {
        width: 100%;
        height: 150px;
        padding: 15px;
        border-radius: 8px;
        border: 1px solid #b30000;
        font-size: 1em;
        color: #333;
        background-color: #fafafa;
      }
      .search-button {
        background-color: #b30000;
        color: white;
        font-size: 1.2em;
        padding: 12px 20px;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        transition: background-color 0.3s;
        box-shadow: 0px 4px 8px rgba(179, 0, 0, 0.3);
      }
      .search-button:hover {
        background-color: #990000;
      }
      .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
      .product-item { border: 1px solid #ddd; padding: 10px; text-align: center; background-color: #fff; border-radius: 8px; }
      .nav-buttons { text-align: center; margin-top: 20px; }
      .btn-nav { background-color: #b30000; color: white; padding: 10px 20px; border-radius: 8px; font-weight: bold; cursor: pointer; }
      .btn-nav:hover { background-color: #990000; }
  ")),
  
  # Placeholder for switching between the landing page and result page
  uiOutput("page_content")
)
