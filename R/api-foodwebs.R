#' @title Download All Food Webs
#'
#' @export
#' @importFrom methods is
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows
#'
#' @param ecosystemType Character of ecosystem type.
#' @param xmin Nnumeric value of minimum longitude.
#' @param xmax Nnumeric value of maximum longitude.
#' @param ymin Nnumeric value of minimum latitude.
#' @param ymax Nnumeric value of maximum latitude.
#'
#' @return Data frame with food web data.
#'
#' @details Arguments are used to filter the food webs. When
#' no parameters are provided, all food webs are returned.
gateway_foodwebs <- function(
  ecosystemType = NULL,
  xmin = NULL,
  xmax = NULL,
  ymin = NULL,
  ymax = NULL
) {
  if (hasArg(ecosystemType)) {
    stopifnot(is(ecosystemType, "character"))
    stopifnot(ecosystemType %in% c(
      "terrestrial aboveground", 
      "lakes",
      "marine",
      "terrestrial belowground",
      "streams"
    ))
  }

  api <- "http://localhost:8000/gateway/api/foodwebs"
  if (any(
    hasArg(ecosystemType),
    hasArg(xmin),
    hasArg(xmax),
    hasArg(ymin),
    hasArg(ymax)
  )) {
    api <- paste0(api, "?")
  }
  if (hasArg(ecosystemType)) {
    api <- paste0(api, "ecosystem=", ecosystemType)
  }
  if (!is.null(xmin)) api <- paste0(api, "&xmin=", xmin)
  if (!is.null(ymin)) api <- paste0(api, "&ymin=", ymin)
  if (!is.null(xmax)) api <- paste0(api, "&xmax=", xmax)
  if (!is.null(ymax)) api <- paste0(api, "&ymax=", ymax)
  req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  ans <- json |> bind_rows()
  return(ans)
}
