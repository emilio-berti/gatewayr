#' @title Adjaceny matrix
#'
#' @export
#' @importFrom igraph graph_from_data_frame simplify degree
#' @importFrom igraph delete_vertices as_adjacency_matrix
#'
#' @param df data.frame subset from GATEWAy.
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
  adj <- t(as_adjacency_matrix(g, sparse = FALSE))

  return(adj)
}
