#' @title GATEWAy Interaction Methods
#'
#' @export
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows
#'
#' @return Character vector.
get_interaction_method <- function() {
  api <- getOption("gateway_api")
  stopifnot(!is.null(api))
  api <- paste0(api, "interactionMethods")
  req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  ans <- json |>
    bind_rows() |>
    mutate(
      interactionMethod = ifelse(
        interactionMethod == "nan",
        NA,
        interactionMethod
      )
    )
  return(ans)
}
