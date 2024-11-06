#' @title Network PCA
#'
#' @export
#' @importFrom methods is
#' @importFrom stats prcomp
#' @importFrom stats dist
#'
#' @param df data.frame subset from GATEWAy.
#' @param ... additional parameters for prcomp.
#'
#' @return Named matrix with the network disimilarity between food webs.
#'
network_pca <- function(df, ...) {
  stopifnot(is(df, "data.frame"))

  # PCA -------------
  has_na <- unique(which(is.na(df), arr.ind = TRUE)[, "col"])
  message(" - Some network properies have NA values and will be omitted:")
  message("    ", paste(colnames(df)[has_na], collapse = "\n    "))
  ans <- prcomp(df[, -has_na], center = TRUE, scale = TRUE)
  if ("axes" %in% ...names()) {
    n_axis <- ...elt(which(...names() == "axes"))
  } else {
    n_axis <- 2
  }
  message(
    " - Cumulative variance explained: ",
    round(summary(ans)$importance[3, n_axis], 3)
  )

  ans$sdev <- ans$sdev[1:n_axis]
  ans$rotation <- ans$rotation[, 1:n_axis]
  ans$x <- ans$x[, 1:n_axis]
  return(ans)
}

#' @title Network dissimlarities
#'
#' @export
#' @importFrom methods is
#' @importFrom stats prcomp
#' @importFrom stats dist
#'
#' @param df data.frame subset from GATEWAy.
#' @param ... additional parameters for prcomp.
#'
#' @return Named matrix with the network disimilarity between food webs.
#'
network_dissimilarity <- function(df, ...) {
  foodwebs <- unique(df$foodweb.name)
  net <- lapply(
    foodwebs, \(fw) {
      adj <- adjacency(df[df$foodweb.name == fw, ])
      return(network_metrics(adj))
    }
  )
  net <- do.call(rbind, net)  # concatenate list into data.frame
  pca <- network_pca(net, ...)

  # Euclidean distance ---------------
  xy <- pca$x
  ans <- as.matrix(dist(xy))
  diag(ans) <- NA
  dimnames(ans) <- list(foodwebs, foodwebs)

  return(ans)
}
