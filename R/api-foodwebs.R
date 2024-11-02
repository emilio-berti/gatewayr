#' @title Create API URL for Food Webs
#'
#' @export
#' @importFrom methods is hasArg
#'
#' @param ecosystemType Character of ecosystem type.
#' @param xmin Numeric value of minimum longitude.
#' @param xmax Numeric value of maximum longitude.
#' @param ymin Numeric value of minimum latitude.
#' @param ymax Numeric value of maximum latitude.
#'
#' @return Data frame with food web data.
#'
#' @details Arguments are used to filter the food webs. When
#' no parameters are provided, all food webs are returned.
api_foodwebs <- function(
  ecosystemType = NULL,
  xmin = NULL,
  xmax = NULL,
  ymin = NULL,
  ymax = NULL
) {
  if (!is.null(ecosystemType)) {
    stopifnot(is(ecosystemType, "character"))
    stopifnot(ecosystemType %in% c(
      "terrestrial aboveground", 
      "lakes",
      "marine",
      "terrestrial belowground",
      "streams"
    ))
  }

  api <- getOption("gateway_api")
  stopifnot(!is.null(api))
  api <- paste0(api, "foodwebs/")

  if (any(
    !is.null(ecosystemType),
    !is.null(xmin),
    !is.null(xmax),
    !is.null(ymin),
    !is.null(ymax)
  )) {
    api <- paste0(api, "?")
  }
  if (!is.null(ecosystemType)) {
    api <- paste0(api, "ecosystem=", ecosystemType)
  }
  if (!is.null(xmin)) api <- paste0(api, "&xmin=", xmin)
  if (!is.null(ymin)) api <- paste0(api, "&ymin=", ymin)
  if (!is.null(xmax)) api <- paste0(api, "&xmax=", xmax)
  if (!is.null(ymax)) api <- paste0(api, "&ymax=", ymax)
  return(api)
}


#' @title Download Food Webs
#'
#' @export
#' @importFrom methods is
#' @importFrom httr2 request req_perform resp_body_json
#' @importFrom dplyr bind_rows
#'
#' @param ecosystemType Character of ecosystem type.
#' @param xmin Numeric value of minimum longitude.
#' @param xmax Numeric value of maximum longitude.
#' @param ymin Numeric value of minimum latitude.
#' @param ymax Numeric value of maximum latitude.
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
  api <- api_foodwebs(ecosystemType, xmin, ymin, xmax, ymax)
  req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  ans <- json |> bind_rows()
  return(ans)
}
