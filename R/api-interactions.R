#' @title Create API URL for Interactions
#'
#' @export
#' @importFrom methods is
#' @importFrom utils URLencode
#'
#' @param params list of filtering parameters.
#'
#' @return Data frame with food web data.
#'
#' @details Arguments are used to filter the food webs. When
#' no parameters are provided, all food webs are returned.
api_interactions <- function(params = NULL) {
  stopifnot(is(params, "list"))

  api <- getOption("gateway_api")
  if (is.null(api)) stop("API URL is empty, contact the package developer.")
  api <- paste0(api, "interactions")

  if (length(params) >= 1) {
    query_string <- paste(
      sapply(names(params), function(key) {
        paste0(URLencode(key), "=", URLencode(as.character(params[[key]])))
      }), collapse = "&"
    )
    api <- paste(api, query_string, sep = "?")
  }

  return(api)
}


#' @title Download Interactions
#'
#' @export
#' @importFrom methods is
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows
#'
#' @param foodwebID Integer of Food Web ID.
#' @param resourceID Integer of Resource ID.
#' @param consumerID Integer of Consumer ID.
#'
#' @return Data frame with interaction data.
#'
#' @details Arguments are used to filter the interactions. When
#' no parameters are provided, all interactions are returned.
gateway_interactions <- function(
  foodwebID = NULL,
  resourceID = NULL,
  consumerID = NULL
) {
  
  if (length(foodwebID) > 1) {
    foodwebID <- paste(foodwebID, collapse = ",")
  }
  if (length(resourceID) > 1) {
    resourceID <- paste(resourceID, collapse = ",")
  }
  if (length(consumerID) > 1) {
    consumerID <- paste(consumerID, collapse = ",")
  }
  
  params <- list(foodwebID, resourceID, consumerID)
  names(params) <- c("foodwebID", "resourceID", "consumerID")
  params <- params[!sapply(params, is.null) & nzchar(as.character(params))]
  api <- api_interactions(params)
  req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  ans <- json |> bind_rows()
  return(ans)
}
