% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summarize_kraken_report.R
\name{summarize_report}
\alias{summarize_report}
\title{Summarize the result of a metagenomics report}
\usage{
summarize_report(my_report)
}
\arguments{
\item{my_report}{kraken report}
}
\value{
data.frame with number of raw read, classified at certain levels, etc
}
\description{
Summarize the result of a metagenomics report
}
\examples{
\dontrun{
  summarize_kraken_report(krakenres)
}
}

