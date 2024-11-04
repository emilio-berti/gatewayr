#' @title Create API URL for Taxa
#'
#' @export
#' @importFrom methods is
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows pull
#'
#' @param params list of filtering parameters.
#'
#' @return Data frame with taxon data.
#'
#' @details Arguments are used to filter the taxa. When
#' no parameters are provided, all taxa are returned.
api_taxa <- function(params = NULL) {
  stopifnot(is(params, "list") || is.null(params))
	
  api <- getOption("gateway_api")
	if (is.null(api)) stop("API URL is empty, contact the package developer.")
  api <- paste0(api, "taxa")

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

#' @title Download Taxa
#'
#' @export
#' @importFrom methods is
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows
#'
#' @param taxonRank Character.
#' @param taxonomicStatus Character.
#'
#' @return Data frame with food web data.
#'
#' @details Arguments are used to filter the food webs. When
#' no parameters are provided, all food webs are returned.
gateway_taxa <- function(
  taxonRank = NULL,
  taxonomicStatus = NULL
) {
  params <- list(taxonRank, taxonomicStatus)
  names(params) <- c("taxonRank", "taxonomicStatus")
  params <- params[!sapply(params, is.null) & nzchar(as.character(params))]
  api <- api_taxa(params)
  req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  ans <- json |> bind_rows()
  return(ans)
}
