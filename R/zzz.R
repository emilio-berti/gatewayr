.onLoad <- function(libname, pkgname){
  op <- options()
  op.gatewayr <- list(
    gateway_api = "http://localhost:8000/gateway/api/"
  )
  toset <- !(names(op.gatewayr) %in% names(op))
  if (any(toset)) options(op.gatewayr[toset])
  invisible()
}