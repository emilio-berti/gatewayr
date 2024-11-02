#' @title List Available Life Stages
#'
#' @export
#' @importFrom methods is
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows pull
#'
#' @return Character vector.
available_life_stages <- function() {
	api <- getOption("gateway_api")
	stopifnot(!is.null(api))
	api <- paste0(api, "lifeStages")
	req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  ans <- json |> bind_rows() |> pull(lifeStage)
  return(ans)
}
