#' @title Subset GATEWAy
#'
#' @export
#' @importFrom methods is
#' @importFrom utils data
#'
#' @param name String of the column used for subsetting.
#' @param pattern String to match.
#' @param adults.only Logical.
#'
#' @return a data.frame with network metrics.
#'
#' @examples
#' subset("study.site", "Adirondack lakes")
#' 
subset <- function(name, pattern, adults.only = TRUE) {
  stopifnot(is(name, "character"))
  stopifnot(is(pattern, "character"))
  stopifnot(is(adults.only, "logical"))

  # load and subset ------------
  gateway <- NULL #silence NOTE on global variable
  data("gateway", envir = environment())
  matches <- with(gateway, eval(parse(text = name)) == pattern)
  message(" - ", sum(matches), " records found.")
  if (sum(matches) == 0) {
    message(
      " - Available options are:\n   ",
      paste(with(gateway, unique(eval(parse(text = name)))), collapse = "\n   ")
    )
    return(NULL)
  }

  ans <- gateway[matches, ]

  # remove non-adults -----------
  if (adults.only) {
    res_adults <- with(ans, res.lifestage == "adults" | is.na(res.lifestage))
    con_adults <- with(ans, con.lifestage == "adults" | is.na(con.lifestage))
    adults <- res_adults & con_adults
    message(" - ", sum(matches) - sum(adults), " records not for adults and removed.")
    ans <- ans[adults, ]
    message(" - ", nrow(ans), " final records.")
  }
  
  return (ans)
}
