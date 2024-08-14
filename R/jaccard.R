#' @title Compute species (Jaccard) similarity 
#'
#' @export
#'
#' @param df data.frame subset from GATEWAy.
#'
#' @return Named matrix with the Jaccard similarity between food webs.
#'
species_jaccard <- function(df) {
  stopifnot(is(df, "data.frame"))

  jaccard <- function(x, y) {
    common <- length(intersect(x, y))
    total <- length(union(x, y))
    jaccard <- common / total
    return (jaccard)
  }

  foodwebs <- unique(df[["foodweb.name"]])
  ans <- matrix(NA, nrow = length(foodwebs), ncol = length(foodwebs))
  dimnames(ans) <- list(foodwebs, foodwebs)
  for (x in foodwebs) {
    sp.x <- union(
      df[df$foodweb.name == x, "res.taxonomy"],
      df[df$foodweb.name == x, "con.taxonomy"]
    )
    for (y in setdiff(foodwebs, x)) {
      sp.y <- union(
        df[df$foodweb.name == y, "res.taxonomy"],
        df[df$foodweb.name == y, "con.taxonomy"]
      )
      ans[x, y] <- jaccard(sp.x, sp.y)
    }
  }

  return (ans)
}
