#' @title Adjaceny matrix
#'
#' @export
#' @importFrom igraph graph_from_data_frame simplify degree delete_vertices as_adjacency_matrix
#'
#' @param name String of the column used for subsetting.
#' @param pattern String to match.
#'
#' @return a data.frame with network metrics.
#'
#' 
adjacency <- function(df) {
  df <- df[, c("res.taxonomy", "con.taxonomy")]
  g <- graph_from_data_frame(df)
  g <- simplify(g)

  # remove isolate species -------
  degs <- degree(g)
  if (any(degs == 0)) {
    g <- delete_vertices(g, which(degs == 0))
  }
  g <- simplify(g)

  # adjacency matrix ---------
  A <- t(as_adjacency_matrix(g, sparse = FALSE))

  return (A)
}
