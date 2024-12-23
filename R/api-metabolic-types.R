#' @title GATEWAy Metabolic Types
#'
#' @export
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows
#'
#' @return Character vector.
get_metabolic_type <- function() {
  api <- getOption("gateway_api")
  stopifnot(!is.null(api))
  api <- paste0(api, "metabolicTypes")
  req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  ans <- json |>
    bind_rows() |>
    mutate(
      metabolicType = ifelse(
        .data$metabolicType == "nan",
        NA,
        .data$metabolicType
      )
    )
  return(ans)
}
