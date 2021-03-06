% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/module_comparison.R
\name{comparisonModule}
\alias{comparisonModule}
\title{Server part of comparison module}
\usage{
comparisonModule(input, output, session, sample_data, reports,
  datatable_opts = NULL, filter_func = NULL, search = NULL)
}
\arguments{
\item{input}{Shiny input object.}

\item{output}{Shiny output object.}

\item{session}{Shiny session.}

\item{sample_data}{A \code{data.frame} specifying sample names and file paths (read from a defs.csv file).}

\item{reports}{A list with report \code{data.frame}s.}

\item{datatable_opts}{Additional options for creating the datatable.}

\item{filter_func}{If not NULL, \code{filter_func} is applied to every data.frame in \code{reports}.}

\item{search}{Search term to initialize table with.}
}
\value{
Comparison module server functionality
}
\description{
Server part of comparison module
}

