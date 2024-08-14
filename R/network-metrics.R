#' @title Compute network metrics
#'
#' @export
#' @importFrom igraph graph_from_adjacency_matrix similarity transitivity mean_distance motifs
#' @importFrom stats sd
#'
#' @param fw matrix, adjacency matrix of the food web with resources 
# as rows and consumers as columns.
#'
#' @return a data.frame with network metrics.
#'
network_metrics <- function(fw) {
  stopifnot(is(fw, "matrix"))

  TroLev <- function(x) {
    x <- t(x)
    nn <- rowSums(x); nn[nn == 0] <- 1
    ww <- diag(1 / nn)
    L1 <- ww %*% x
    L2 <- L1 - diag(rep(1, length(nn)))
    b <- -1 * rep(1, length(nn))
    Tro.lev <- solve(L2) %*% b
    return(Tro.lev)
  }
  
  S <- ncol(fw) #number of species
  L <- sum(fw) #number of links
  C <- L / (S ^ 2) #connectance
  bas <- sum(colSums(fw) == 0) #number of basals
  frB = bas / S #fraction of basals
  top <- sum(rowSums(fw) == 0) #number of top
  frT <- top / S #fraction of top
  frI <- 1 - frT - frB #fraction of intermediate
  frCB <- sum(diag(fw) == 1) / S#fraction cannibals
  # standard deviation of normalized generality
  genk <- (S / L) * apply(fw, 2, sum)
  sdGen <- sd(genk)
  # standard deviation of normalized vulnerability
  vulk <- (S / L) * apply(fw, 1, sum)
  sdVul <- sd(vulk)
  # max. of TL
  # if empty matrix (0 size in both dimensions), or there is no basal species
  # then just create NA
  TL <- tryCatch(TroLev(fw), error = function(e) rep(NA, S))
  if (any(is.na(TL))) {
    maxTL <- NA
    meanTL <- NA
    sdTL <- NA
    frOmn <- NA
  } else {
    maxTL <- max(TL)
    meanTL <- mean(TL)
    sdTL <- sd(TL)
    omn <- sum(TL %% 1 != 0) #number omnivores
    frOmn <- omn / S  #fraction of omnivores
  }
  g <- graph_from_adjacency_matrix(fw)
  Sim <- similarity(g, mode = "all") #Jaccard similarity
  diag(Sim) <- NA
  meanSim <- apply(Sim, 2, mean, na.rm = TRUE)
  MMSim <- mean(meanSim) #mean across all species
  clust <- transitivity(g) #clustering ceofficient
  CPL <- mean_distance( #characteristic path length
    g, 
    directed = FALSE,
    unconnected = TRUE
  )
  # motifs
  Motifs <- motifs(g, size = 3)
  Motifsm <- matrix(Motifs)
  SumMotifs <- sum(Motifs, na.rm = T)
  PercentMotifs <- Motifs[1:16] / SumMotifs
  PercentMotifsFrame <- as.data.frame(t(PercentMotifs))

  # output of function
  ans <- data.frame(
    connectance = C,
    clust = clust,
    meanSim = MMSim,
    sdGen = sdGen,
    sdVul = sdVul,
    CPL = CPL,
    meanTL = meanTL,
    maxTL = maxTL,
    sdTL = sdTL,
    frB = frB,
    frI = frI,
    frT = frT,
    frOmn = frOmn,
    fColliders = PercentMotifsFrame$V3,
    fChains = PercentMotifsFrame$V5,
    fForks = PercentMotifsFrame$V7,
    fIGPs = PercentMotifsFrame$V8
  )

  return (ans)
}
