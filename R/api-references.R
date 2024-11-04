#' @title GATEWAy References
#'
#' @export
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows
#'
#' @return Character vector.
gateway_references <- function() {
	api <- getOption("gateway_api")
	stopifnot(!is.null(api))
	api <- paste0(api, "references")
	req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  ans <- json |> bind_rows()
  return(ans)
}
