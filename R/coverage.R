#' @title Coverage of Table
#'
#' @export
#' @importFrom methods is
#' @importFrom dplyr summarize across where everything mutate select arrange
#' @importFrom tidyr pivot_longer
#'
#' @param df table.
#'
#' @return Data frame with data coverage information.
coverage <- function(df) {
  stopifnot(is(df, "data.frame"))

  ans <- df |>
    summarize(
      across(where(is.character), ~sum(is.na(.x))),
      across(where(is.numeric), ~sum(.x <= 0))
    ) |>
    pivot_longer(
      cols = everything(),
      names_to = "column",
      values_to = "n na"
    ) |>
    mutate(`n rows` = nrow(df)) |>
    mutate(coverage = 1 - .data$`n na` / .data$`n rows`) |>
    select("column", "coverage") |>
    arrange(coverage)

  return(ans)
}
