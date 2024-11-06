.onLoad <- function(libname, pkgname) {
  op <- options()
  op_gatewayr <- list(
    gateway_api = "http://localhost:8000/gateway/api/"
  )
  toset <- !(names(op_gatewayr) %in% names(op))
  if (any(toset)) options(op_gatewayr[toset])
  invisible()
}
