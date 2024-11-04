#' @title Create API URL for Food Webs
#'
#' @export
#' @importFrom methods is
#' @importFrom utils URLencode
#'
#' @param params list of filtering parameters.
#'
#' @return Data frame with food web data.
#'
#' @details Arguments are used to filter the food webs. When
#' no parameters are provided, all food webs are returned.
api_foodwebs <- function(params = NULL) {
  stopifnot(is(params, "list") || is.null(params))
  if (!is.null(params[["ecosystemType"]])) {
    stopifnot(is(params[["ecosystemType"]], "character"))
    stopifnot(params[["ecosystemType"]] %in% c(
      "terrestrial aboveground", 
      "lakes",
      "marine",
      "terrestrial belowground",
      "streams"
    ))
  }

  api <- getOption("gateway_api")
  if (is.null(api)) stop("API URL is empty, contact the package developer.")
  api <- paste0(api, "foodwebs")

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
  params <- list(ecosystemType, xmin, ymin, xmax, ymax)
  names(params) <- c("ecosystemType", "xmin", "ymin", "xmax", "ymax")
  params <- params[!sapply(params, is.null) & nzchar(as.character(params))]
  api <- api_foodwebs(params)
  req <- request(api)
  resp <- req_perform(req)
  json <- resp |> resp_body_json()
  ans <- json |> bind_rows()
  return(ans)
}
