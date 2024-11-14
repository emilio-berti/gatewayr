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
.api_interactions <- function(params = NULL) {
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

#' @title Join Raw Interaction Table with other Tables
#'
#' @export
#' @importFrom methods is
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr pull select left_join relocate any_of all_of
#' @importFrom dplyr contains join_by mutate rename_with
#'
#' @param df Table with raw community data.
#'
#' @return Data frame with community data.
.join_interactions <- function(df) {
  stopifnot(is(df, "data.frame"))

  # retrieve community info
  drop <- c(
    "communityID", "taxonID", "lifeStageID", "metabolicTypeID",
    "movementTypeID", "sizeMethodID", "referenceID"
  )
  resources <- df |>
    pull("foodwebID") |>
    unique() |>
    get_community(columns = "all") |>
    mutate(resourceID = .data$communityID) |>
    rename_with(
      ~paste("resource", gsub("^([a-z])", "\\U\\1", ., perl = TRUE), sep = ""),
      .cols = "acceptedTaxonName":"reference"
    ) |>
    select(-any_of(drop))

  drop <- c(
    "communityID", "taxonID", "lifeStageID", "metabolicTypeID",
    "movementTypeID", "sizeMethodID", "referenceID",
    "foodwebName", "ecosystemType",
    "decimalLongitude", "decimalLatitude",
    "geographicLocation", "studySite",
    "verbatimElevation", "verbatimDepth",
    "samplingTime", "earliestDateCollected", "latestDateCollected"
  )

  consumers <- df |>
    pull("foodwebID") |>
    unique() |>
    get_community(columns = "all") |>
    mutate(consumerID = .data$communityID) |>
    rename_with(
      ~paste("consumer", gsub("^([a-z])", "\\U\\1", ., perl = TRUE), sep = ""),
      .cols = "acceptedTaxonName":"reference"
    ) |>
    select(-any_of(drop))

  ordered_columns <- c(
    "resourceAcceptedTaxonName", "consumerAcceptedTaxonName",
    "resourceLifeStage", "consumerLifeStage",
    "resourceLowestMass", "resourceHighestMass", "resourceMeanMass",
    "consumerLowestMass", "consumerHighestMass", "consumerMeanMass",
    "resourceShortestLength", "resourceLongestLength", "resourceMeanLength",
    "consumerShortestLength", "consumerLongestLength", "consumerMeanLength",
    "resourceSizeMethod", "consumerSizeMethod",
    "resourceBiomass", "consumerBiomass",
    "resourceMovementType", "consumerMovementType",
    "resourceMetabolicType", "consumerMetabolicType",
    "resourceTaxonRank", "consumerTaxonRank",
    "resourceTaxonomicStatus", "consumerTaxonomicStatus",
    "resourceVernacularName", "consumerVernacularName",
    "resourceReference", "consumerReference",
    "interactionDimensionality", "basisOfRecord",
    "interactionMethod", "interactionType", "interactionRemarks",
    "foodwebName", "ecosystemType", "decimalLongitude", "decimalLatitude",
    "geographicLocation", "studySite",
    "verbatimElevation", "verbatimDepth",
    "samplingTime", "earliestDateCollected", "latestDateCollected"
  )

  ans <- df |>
    left_join(resources, by = c("resourceID", "foodwebID")) |>
    left_join(consumers, by = c("consumerID", "foodwebID")) |>
    left_join(
      get_interaction_method(),
      by = "interactionMethodID"
    ) |>
    left_join(
      get_interaction_type(),
      by = "interactionTypeID"
    ) |>
    select(-contains("ID"))

  missing_columns <- ordered_columns[which(!ordered_columns %in% colnames(ans))]
  for (x in missing_columns) {
    ans[[x]] <- NA
  }
  ans <- ans |> select(all_of(ordered_columns))

  return(ans)
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
get_interaction <- function(
  foodwebID = NULL,
  resourceID = NULL,
  consumerID = NULL
) {

  if (length(foodwebID) == 0) {
    foodwebID <- get_foodweb()[["foodwebID"]]
  }
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
  if (length(params) == 0) {
    stop("No filtering parameters specified.")
  }
  api <- .api_interactions(params)
  req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  if (length(json) == 0) {
    stop("No data found with the specified parameters.")
  }
  ans <- json |> bind_rows()
  ans <- .join_interactions(ans)

  return(ans)
}
