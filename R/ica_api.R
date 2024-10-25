library(httr)
library(R6)
library(jsonlite)

Product <- R6Class(
  "product",
  public = list(
    name = NULL,
    brand = NULL,
    price = NULL,
    price_per_unit = NULL,
    size = NULL,
    category_path = NULL,
    image_path = NULL,
    
    initialize = function( name, brand, price, price_per_unit, size, category_path, image_path) {
      self$price <- price
      self$brand <- brand
      self$name <- name
      self$price_per_unit <- price_per_unit
      self$size <- size
      self$category_path <- category_path
      self$image_path <- image_path
    }
  )
)

ICA_API_Handler <- R6Class(
  classname = "ica_api_handler",
  public = list(
    initialize = function() {
      
    },
    
    search_product = function(query_term) {
      url <- "https://handlaprivatkund.ica.se/stores/1003823/api/v5/products/search"
      queryString <- list(offset = "0", term = query_term)
      
      response <- VERB(
        # Make request
        "GET",
        url,
        query = queryString,
        add_headers(
          `accept-language` = 'de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7,sv;q=0.6',
          `client-route-id` = '1b88ec5c-0894-4cc3-b9ef-7bd70990efb6',
          `priority` = 'u=1, i',
          `referer` = 'https://handlaprivatkund.ica.se/stores/1003823/search?q=Laktosfri%20Mj%C3%B6lk',
          `sec-ch-ua` = '"Chromium";v="130", "Google Chrome";v="130", "Not?A_Brand";v="99"',
          `sec-ch-ua-mobile` = '?0',
          `sec-ch-ua-platform` = '"Windows"',
          `sec-fetch-dest` = 'empty',
          `sec-fetch-mode` = 'cors',
          `sec-fetch-site` = 'same-origin',
          `user-agent` = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
        ),
        content_type("application/octet-stream"),
        accept("application/json; charset=utf-8"),
        set_cookies(
          roc_hdr = "23",
          global_sid = "FsATPtMpqp2TVUoehsahmxXFKG8gvck7_KePxp1-OkyF3-uIl9IQXpMjea4xLXElF6rAlhu5ULa1aiZLJm41hgMr5y1aDh07dmZ9og",
          AWSALB = "ZEoPHj2uVmrKVo5yyBwr9jUy62o8DH99H8or2YatiKQvYgo8ff0ARecCUHQS/dISRo+fD9GAfEqph0QaxF6xdIkj6zQj3/Uk1419k8ksd5E5NnMMB1baF44a+HBh",
          AWSALBCORS = "ZEoPHj2uVmrKVo5yyBwr9jUy62o8DH99H8or2YatiKQvYgo8ff0ARecCUHQS/dISRo+fD9GAfEqph0QaxF6xdIkj6zQj3/Uk1419k8ksd5E5NnMMB1baF44a+HBh",
          VISITORID = "XA9GxVl1jGJ3KoTxQWJVhvTzOHkpbksc4GbflpwQyzBk6ur-z8egVceroHc1huHp4vRsYZq13I9mOFDtotjRs-H3CUB6vcfJz6-amQ",
          AWSALB = "krwWQjqHrW+asiFmau3wK7SNApaC2Tu79c8iaW4wa2OOIcvFC0tOyW4hUATcAx5vXNzjN79zECLcvRDf0x9FDd/ehZQ1xMnEI3+Wim4ztRs36HJjJvLU3DEFKpq0",
          AWSALBCORS = "krwWQjqHrW+asiFmau3wK7SNApaC2Tu79c8iaW4wa2OOIcvFC0tOyW4hUATcAx5vXNzjN79zECLcvRDf0x9FDd/ehZQ1xMnEI3+Wim4ztRs36HJjJvLU3DEFKpq0"
        )
      )
      # Parse JSON content
      if (status_code(response) == 200) {
        data <- fromJSON(content(response, "text"))
      } else {
        print("Request failed")
      }
      
      json_products <- data$entities$product
      products <- self$parse_products(json_products)
      return(products)
    },
    
    parse_products = function(json_products) {
      parse_product <- function(json_product){
          name <- json_product$name
          brand <- json_product$brand
          price <- json_product$price$current$amount
          size <- json_product$size$value
          price_per_unit <- json_product$price$unit$current$amount
          category_path <- json_product$categoryPath
          image_path <- json_product$image$src
          product <- Product$new(name = name, 
                                 brand = brand,
                                 price = price,
                                 price_per_unit = price_per_unit,
                                 size=size, 
                                 category_path = category_path, 
                                 image_path =image_path)
          return (product)
      }
      
      products <- lapply(json_products, parse_product)
      return(products)
    }
    
    
  )
)