#' @title GATEWAy Life Stages
#'
#' @export
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows
#'
#' @return Character vector.
get_life_stage <- function() {
  api <- getOption("gateway_api")
  stopifnot(!is.null(api))
  api <- paste0(api, "lifeStages")
  req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  ans <- json |>
    bind_rows() |>
    mutate(
      lifeStage = ifelse(
        .data$lifeStage == "nan",
        NA,
        .data$lifeStage
      )
    )
  return(ans)
}
