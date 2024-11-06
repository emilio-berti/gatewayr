# #' @title Create API URL for Interactions
# #'
# #' @export
# #' @importFrom methods is
# #' @importFrom utils URLencode
# #'
# #' @param params list of filtering parameters.
# #'
# #' @return Data frame with food web data.
# #'
# #' @details Arguments are used to filter the food webs. When
# #' no parameters are provided, all food webs are returned.
# .api_interactions <- function(params = NULL) {
#   stopifnot(is(params, "list"))

#   api <- getOption("gateway_api")
#   if (is.null(api)) stop("API URL is empty, contact the package developer.")
#   api <- paste0(api, "interactions")

#   if (length(params) >= 1) {
#     query_string <- paste(
#       sapply(names(params), function(key) {
#         paste0(URLencode(key), "=", URLencode(as.character(params[[key]])))
#       }), collapse = "&"
#     )
#     api <- paste(api, query_string, sep = "?")
#   }

#   return(api)
# }

# #' @title Join Raw Interaction Table with other Tables
# #'
# #' @export
# #' @importFrom methods is
# #' @importFrom httr2 request req_perform resp_body_json
# #' @importFrom dplyr pull select left_join relocate contains join_by
# #'
# #' @param df Table with raw community data.
# #'
# #' @return Data frame with community data.
# .join_interactions <- function(df) {
#   stopifnot(is(df, "data.frame"))

#   # retrieve community info
#   communities <- df |> 
#     pull(foodwebID) |> 
#     get_community(columns = "all")

#   # retrieve food web info
#   foodwebID <- df |> pull(foodwebID) |> unique()
#   ans <- df |> 
#     left_join(
#       get_foodweb(foodwebID = paste(foodwebID, collapse = ",")) |> 
#         select("foodwebID", "foodwebName"), 
#       by = "foodwebID"
#     ) |> 
#     select(-"foodwebID")

#   # retrieve resource info
#   ans <- ans |> 
#     left_join(
#       communities |> 
#         select("taxonID", "lifeStage", "acceptedTaxonName", "taxonRank"),
#       by = join_by("resourceID" == "taxonID")
#     )

#   # retrieve consumer name
#   consumers <- get_taxon(taxonID = paste(ans |> pull("consumerID"), collapse = ","))
#   ans <- ans |> 
#     left_join(consumers, by = join_by("consumerID" == "taxonID"))

#   # retrieve life stages info

#   ans <- ans |> 
#     left_join(get_life_stage(), by = "lifeStageID") |> 
#     select(-"lifeStageID")

#   # retrieve movement types info
#   ans <- ans |> 
#     left_join(get_movement_type(), by = "movementTypeID") |> 
#     select(-"movementTypeID")

#   # retrieve metabolic types info
#   ans <- ans |> 
#     left_join(get_metabolic_type(), by = "metabolicTypeID") |> 
#     select(-"metabolicTypeID")

#   # retrieve size methods info
#   ans <- ans |> 
#     left_join(get_size_method(), by = "sizeMethodID") |> 
#     select(-"sizeMethodID")

#   # retrieve references info
#   ans <- ans |> 
#     left_join(get_reference(), by = "referenceID") |> 
#     select(-"referenceID")

#   ans <- ans |> 
#     relocate(contains("Mass"), .after = "lifeStage") |> 
#     relocate(contains("Length"), .after = "meanMass")

#   return(ans)
# }

# #' @title Download Interactions
# #'
# #' @export
# #' @importFrom methods is
# #' @importFrom httr2 request req_perform resp_body_json
# #' @importFrom dplyr bind_rows
# #'
# #' @param foodwebID Integer of Food Web ID.
# #' @param resourceID Integer of Resource ID.
# #' @param consumerID Integer of Consumer ID.
# #'
# #' @return Data frame with interaction data.
# #'
# #' @details Arguments are used to filter the interactions. When
# #' no parameters are provided, all interactions are returned.
# get_interaction <- function(
#   foodwebID = NULL,
#   resourceID = NULL,
#   consumerID = NULL
# ) {
  
#   if (length(foodwebID) > 1) {
#     foodwebID <- paste(foodwebID, collapse = ",")
#   }
#   if (length(resourceID) > 1) {
#     resourceID <- paste(resourceID, collapse = ",")
#   }
#   if (length(consumerID) > 1) {
#     consumerID <- paste(consumerID, collapse = ",")
#   }
  
#   params <- list(foodwebID, resourceID, consumerID)
#   names(params) <- c("foodwebID", "resourceID", "consumerID")
#   params <- params[!sapply(params, is.null) & nzchar(as.character(params))]
#   api <- .api_interactions(params)
#   req <- request(api)
#   resp <- req_perform(req)
#   json <- resp |> resp_body_json()
#   ans <- json |> bind_rows()

#   return(ans)
# }
