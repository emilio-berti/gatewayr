#' @title Network dissimlarities
#'
#' @export
#'
#' @param df data.frame subset from GATEWAy.
#'
#' @return Named matrix with the network disimilarity between food webs.
#'
network_dissimilarity <- function(df) {
  stopifnot(is(df, "data.frame"))

  foodwebs <- unique(df[["foodweb.name"]])

  # compute properties for all foodwebs ------------
  props <- as.list(rep(NA, length(foodwebs)))
  names(props) <- foodwebs
  for (fw in foodwebs) {
    A <- adjacency(df[df$foodweb.name == fw, ])
    props[[fw]] <- network_metrics(A)
  }
  props <- do.call(rbind, props)

  # PCA -------------
  hasNA <- unique(which(is.na(props), arr.ind = TRUE)[, "col"])
  message(" - Some network properies have NA values and will be omitted:")
  message("    ", paste(colnames(props)[hasNA], collapse = "\n    "))
  pca <- prcomp(props[, -hasNA], center = TRUE, scale = TRUE)
  message(" - Cumulative variance explained: ")
  message("    First 2 axes: ", round(summary(pca)$importance[3, 1:2], 3))
  message("    First 3 axes: ", round(summary(pca)$importance[3, 1:3], 3))

  # Euclidean distance ---------------
  xy <- pca$x[, 1:2]
  ans <- as.matrix(dist(xy))
  diag(ans) <- NA
  dimnames(ans) <- list(foodwebs, foodwebs)

  return (ans)
}
