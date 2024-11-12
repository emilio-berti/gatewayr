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
.api_communities <- function(params = NULL) {
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
      get_foodweb(foodwebID = paste(foodwebID, collapse = ",")),
      by = "foodwebID"
    )

  # retrieve taxa info
  taxa <- paste(ans |> pull("taxonID") |> unique(), collapse = ",")
  taxa <- get_taxon(taxonID = taxa)
  ans <- ans |> left_join(taxa, by = "taxonID")

  # retrieve life stages info
  ans <- ans |> left_join(get_life_stage(), by = "lifeStageID")

  # retrieve movement types info
  ans <- ans |> left_join(get_movement_type(), by = "movementTypeID")

  # retrieve metabolic types info
  ans <- ans |> left_join(get_metabolic_type(), by = "metabolicTypeID")

  # retrieve size methods info
  ans <- ans |> left_join(get_size_method(), by = "sizeMethodID")

  # retrieve references info
  ans <- ans |> left_join(get_reference(), by = "referenceID")

  ans <- ans |>
    relocate(contains("Mass"), .after = "lifeStage") |>
    relocate(contains("Length"), .after = "meanMass")

  return(ans)
}

#' @title Download GATEWAy Communities
#'
#' @export
#' @importFrom methods is
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows any_of
#'
#' @param foodwebID Numeric value of Food Web ID.
#' @param columns Character vector of the columns to return.
#'
#' @return Data frame with food web data.
#'
#' @details Arguments are used to filter the communities. When
#' no parameters are provided, all communities are returned..
get_community <- function(
  foodwebID = NULL,
  columns = c(
    "foodwebName", "acceptedTaxonName",
    "lifeStage", "meanMass", "meanLength", "biomass"
  )
) {
  if (length(foodwebID) == 0) {
    foodwebID <- get_foodweb()[["foodwebID"]]
  }
  if (length(foodwebID) > 1) {
    foodwebID <- paste(foodwebID, collapse = ",")
  }
  params <- list(foodwebID)
  names(params) <- c("foodwebID")
  params <- params[!sapply(params, is.null) & nzchar(as.character(params))]
  api <- .api_communities(params)
  req <- request(api)
  resp <- tryCatch(
    req_perform(req),
    error = function(e) {
      stop(conditionMessage(e), " Try passing fewer IDs.")
    }
  )
  json <- resp |> resp_body_json()
  ans <- json |> bind_rows()

  ans <- .join_communities(ans)
  if (length(columns) > 1 || tolower(columns) != "all") {
    ans <- ans |> select(any_of(columns))
  }

  return(ans)
}
