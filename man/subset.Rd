% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/subset-gateway.R
\name{subset}
\alias{subset}
\title{Subset GATEWAy}
\usage{
subset(name, pattern, adults.only = TRUE)
}
\arguments{
\item{name}{String of the column used for subsetting.}

\item{pattern}{String to match.}

\item{adults.only}{Logical.}
}
\value{
a data.frame with network metrics.
}
\description{
Subset GATEWAy
}
\examples{
subset("study.site", "Adirondack lakes")

}
