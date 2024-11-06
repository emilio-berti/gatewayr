#' @title Compute network metrics
#'
#' @export
#' @importFrom igraph graph_from_adjacency_matrix similarity
#' @importFrom igraph transitivity mean_distance motifs
#' @importFrom stats sd
#' @importFrom methods is
#' @importFrom tibble tibble
#'
#' @param fw matrix, adjacency matrix of the food web with resources
# as rows and consumers as columns.
#'
#' @return a data.frame with network metrics.
#'
network_metrics <- function(fw) {
  stopifnot(is(fw, "matrix"))

  trophic_levels <- function(x) {
    x <- t(x)
    nn <- rowSums(x)
    nn[nn == 0] <- 1
    ww <- diag(1 / nn)
    layer_one <- ww %*% x
    layer_two <- layer_one - diag(rep(1, length(nn)))
    b <- -1 * rep(1, length(nn))
    ans <- solve(layer_two) %*% b
    return(ans)
  }

  richness <- ncol(fw) #number of species
  links <- sum(fw) #number of links
  connectance <- links / (richness ^ 2) #connectance
  bas <- sum(colSums(fw) == 0) #number of basals
  fraction_basal <- bas / richness #fraction of basals
  top <- sum(rowSums(fw) == 0) #number of top
  fraction_top <- top / richness #fraction of top
  #fraction of intermediate
  fraction_intermediate <- 1 - fraction_top - fraction_basal
  # standard deviation of normalized generality
  genk <- (richness / links) * apply(fw, 2, sum)
  std_generality <- sd(genk)
  # standard deviation of normalized vulnerability
  vulnerability <- (richness / links) * apply(fw, 1, sum)
  std_vulnerability <- sd(vulnerability)
  # max of trophic level
  # If empty matrix (0 size in both dimensions)
  # or there is no basal species then just create NA
  trophic_level <- tryCatch(
    trophic_levels(fw),
    error = function(e) rep(NA, richness)
  )
  if (any(is.na(trophic_level))) {
    max_trophic_level <- NA
    mean_trophic_level <- NA
    std_trophic_level <- NA
    fraction_omnivores <- NA
  } else {
    max_trophic_level <- max(trophic_level)
    mean_trophic_level <- mean(trophic_level)
    std_trophic_level <- sd(trophic_level)
    omn <- sum(trophic_level %% 1 != 0) #number omnivores
    fraction_omnivores <- omn / richness  #fraction of omnivores
  }
  g <- graph_from_adjacency_matrix(fw)
  sim <- similarity(g, mode = "all") #Jaccard similarity
  diag(sim) <- NA
  mean_sim <- mean(apply(sim, 2, mean, na.rm = TRUE)) #mean across all species
  clust <- transitivity(g) #clustering ceofficient
  char_path_length <- mean_distance( #characteristic path length
    g,
    directed = FALSE,
    unconnected = TRUE
  )
  # motifs
  motifs <- motifs(g, size = 3)
  sum_motifs <- sum(motifs, na.rm = TRUE)
  percent_motifs <- motifs[1:16] / sum_motifs
  percent_motifs_frame <- as.data.frame(t(percent_motifs))

  # output of function
  ans <- tibble(
    connectance = connectance,
    clust = clust,
    mean_sim = mean_sim,
    std_generality = std_generality,
    std_vulnerability = std_vulnerability,
    char_path_length = char_path_length,
    mean_trophic_level = mean_trophic_level,
    max_trophic_level = max_trophic_level,
    std_trophic_level = std_trophic_level,
    fraction_basal = fraction_basal,
    fraction_intermediate = fraction_intermediate,
    fraction_top = fraction_top,
    fraction_omnivores = fraction_omnivores,
    fraction_colliders = percent_motifs_frame$V3,
    fraction_chains = percent_motifs_frame$V5,
    fraction_forks = percent_motifs_frame$V7,
    fraction_IGPs = percent_motifs_frame$V8
  )

  return(ans)
}
