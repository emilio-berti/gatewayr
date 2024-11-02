#' @title Create API URL for Taxa
#'
#' @export
#' @importFrom methods is
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows pull
#'
#' @param taxonRank Character.
#' @param taxonomicStatus Character.
#'
#' @return Data frame with taxon data.
#'
#' @details Arguments are used to filter the taxa. When
#' no parameters are provided, all taxa are returned.
api_taxa <- function(
  taxonRank = NULL,
  taxonomicStatus = NULL
) {
	api <- getOption("gateway_api")
	stopifnot(!is.null(api))
  api <- paste0(api, "taxa")
  if (all(!is.null(taxonRank), !is.null(taxonomicStatus))) {
    api <- paste0(api, "?taxonRank=", taxonRank, "&taxonomicStatus=", taxonomicStatus)
  } else {
    if (!is.null(taxonRank)) {
      api <- paste0(api, "?taxonRank=", taxonRank)
    }
    if (!is.null(taxonomicStatus)) {
      api <- paste0(api, "?taxonomicStatus=", taxonomicStatus)
    }
  }
  return(api)
}

#' @title Download Taxa
#'
#' @export
#' @importFrom methods is
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows
#'
#' @return Data frame with food web data.
#'
#' @details Arguments are used to filter the food webs. When
#' no parameters are provided, all food webs are returned.
gateway_taxa <- function(
  taxonRank = NULL,
  taxonomicStatus = NULL
) {
  api <- api_taxa(taxonRank, taxonomicStatus)
  req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  ans <- json |> bind_rows()
  return(ans)
}
