#' @title GATEWAy Interaction Types
#'
#' @export
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows
#'
#' @return Character vector
get_interaction_type <- function() {
  api <- getOption("gateway_api")
  stopifnot(!is.null(api))
  api <- paste0(api, "interactionTypes")
  req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  ans <- json |>
    bind_rows() |>
    mutate(
      interactionType = ifelse(
        .data$interactionType == "nan",
        NA,
        .data$interactionType
      )
    )
  return(ans)
}
