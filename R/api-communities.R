#' @title Create API URL for Communties
#'
#' @export
#' @importFrom methods is
#' @importFrom utils URLencode
#'
#' @param params list of filtering parameters.
#'
#' @return Data frame with food web data.
#'
#' @details Arguments are used to filter the communities. When
#' no parameters are provided, all communities are returned.
api_communities <- function(params = NULL) {
  stopifnot(is(params, "list"))

  api <- getOption("gateway_api")
  if (is.null(api)) stop("API URL is empty, contact the package developer.")
  api <- paste0(api, "communities")

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

#' @title Join Raw Community Table with other Tables
#'
#' @export
#' @importFrom methods is
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr pull select left_join relocate contains
#'
#' @param df Table with raw community data.
#'
#' @return Data frame with community data.
.join_communities <- function(df) {
  stopifnot(is(df, "data.frame"))

 # retrieve food web info
 foodwebID <- df |> pull(foodwebID) |> unique()
  ans <- df |> 
    left_join(
      gateway_foodwebs(foodwebID = paste(foodwebID, collapse = ",")), 
      by = "foodwebID"
    ) |> 
    select(-"foodwebID")

  # retrieve taxa info
  taxa <- gateway_taxa(taxonID = paste(ans |> pull("taxonID"), collapse = ","))
  ans <- ans |> 
    left_join(taxa, by = "taxonID") |> 
    select(-"taxonID")

  # retrieve life stages info
  ans <- ans |> 
    left_join(gateway_life_stages(), by = "lifeStageID") |> 
    select(-"lifeStageID")

  # retrieve movement types info
  ans <- ans |> 
    left_join(gateway_movement_types(), by = "movementTypeID") |> 
    select(-"movementTypeID")

  # retrieve metabolic types info
  ans <- ans |> 
    left_join(gateway_metabolic_types(), by = "metabolicTypeID") |> 
    select(-"metabolicTypeID")

  # retrieve size methods info
  ans <- ans |> 
    left_join(gateway_size_methods(), by = "sizeMethodID") |> 
    select(-"sizeMethodID")

  # retrieve references info
  ans <- ans |> 
    left_join(gateway_references(), by = "referenceID") |> 
    select(-"referenceID")

  ans <- ans |> 
    relocate(contains("Mass"), .after = "lifeStage") |> 
    relocate(contains("Length"), .after = "meanMass")

  return(ans)
}

#' @title Download Food Webs
#'
#' @export
#' @importFrom methods is
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows
#' 
#' @param foodwebID Numeric value of Food Web ID.
#' @param columns Character vector of the columns to return.
#'
#' @return Data frame with food web data.
#'
#' @details Arguments are used to filter the communities. When
#' no parameters are provided, all communities are returned..
gateway_communities <- function(
  foodwebID = NULL,
  columns = c(
    "foodwebName", "acceptedTaxonName",
    "lifeStage", "meanMass", "meanLength", "biomass"
  )
) {
  if (length(foodwebID) > 1) {
    foodwebID <- paste(foodwebID, collapse = ",")
  } else if (length(foodwebID) == 0) {
    stop("You need to provide at least one 'foodwebID'")
  }
  params <- list(foodwebID)
  names(params) <- c("foodwebID")
  params <- params[!sapply(params, is.null) & nzchar(as.character(params))]
  api <- api_communities(params)
  req <- request(api)
  resp <- tryCatch(
    req_perform(req),
    error = function(e) {
      stop(conditionMessage(e), " Try passing fewer IDs.")
  })  
  json <- resp |> resp_body_json()
  ans <- json |> bind_rows()

  ans <- .join_communities(ans)
  ans <- ans |> select(any_of(columns))

  return(ans)
}

