% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SFEMethod-class.R
\docType{class}
\name{SFEMethod}
\alias{SFEMethod}
\alias{SFEMethod-class}
\alias{args_not_check}
\alias{fun}
\alias{info}
\alias{is_local}
\alias{reorganize_fun}
\alias{is_joint}
\alias{use_graph}
\alias{use_matrix}
\alias{info,SFEMethod-method}
\alias{is_local,SFEMethod-method}
\alias{fun,SFEMethod-method}
\alias{reorganize_fun,SFEMethod-method}
\alias{args_not_check,SFEMethod-method}
\alias{is_joint,SFEMethod-method}
\alias{use_graph,SFEMethod-method}
\alias{use_matrix,SFEMethod-method}
\title{SFEMethod class}
\usage{
SFEMethod(
  name,
  fun,
  reorganize_fun,
  package,
  variate = c("uni", "bi", "multi"),
  scope = c("global", "local"),
  title = NULL,
  default_attr = NA,
  args_not_check = NA,
  joint = FALSE,
  use_graph = TRUE,
  use_matrix = FALSE,
  dest = c("reducedDim", "colData")
)

\S4method{info}{SFEMethod}(x, type)

\S4method{is_local}{SFEMethod}(x)

\S4method{fun}{SFEMethod}(x)

\S4method{reorganize_fun}{SFEMethod}(x)

\S4method{args_not_check}{SFEMethod}(x)

\S4method{is_joint}{SFEMethod}(x)

\S4method{use_graph}{SFEMethod}(x)

\S4method{use_matrix}{SFEMethod}(x)
}
\arguments{
\item{name}{Name of the method, used by user-facing functions to specify the
method to use, such as "moran" for Moran's I.}

\item{fun}{Function to run the method. See Details.}

\item{reorganize_fun}{Function to reorganize results to add to the SFE
object. See Details.}

\item{package}{Name of the package whose implementation of the method is used
here, used to check if the package is installed.}

\item{variate}{How many variables this method works with, must be one of
"uni" for univariate, "bi" for bivariate, or "multi" for multivariate.}

\item{scope}{Either "global", returning one result for the entire dataset,
or "local", returning one result for each spatial location. For multivariate
methods, this is irrelevant.}

\item{title}{Descriptive title to show when plotting the results.}

\item{default_attr}{For local methods that return multiple fields, such as
local Moran values and their p-values, the default field to use when
plotting.}

\item{args_not_check}{A character vector indicating which argument are not to
be checked when comparing parameters in with those of a previous run.}

\item{joint}{Logical, whether it makes sense to run this method to multiple
samples jointly. If \code{TRUE}, then \code{fun} must be able to handle an
adjacency matrix for the \code{listw} argument because there's no
straightforward way to concatenate \code{listw} objects from multiple
samples.}

\item{use_graph}{Logical, to indicate whether the method uses a spatial
neighborhood graph because unifying the user facing functions have an
argument asking for the graph as most though not all methods require the
graph.}

\item{use_matrix}{Logical, whether the function in slot \code{fun} takes a
matrix as input. The argument is only used for bivariate methods.}

\item{dest}{Whether the results are more appropriate for \code{reducedDim} or
\code{colData}. Only used for multivariate methods. This overrides the
"local" field in \code{info}.}

\item{x}{A \code{SFEMethod} object}

\item{type}{One of the names of the \code{info} slot, see slot documentation.}
}
\value{
The constructor returns a \code{SFEMethod} object. The getters return
  the content of the corresponding slots.
}
\description{
This S4 class is used to wrap spatial analysis methods, taking inspiration
from the \code{caret} and \code{tidymodels} packages.
}
\details{
The \code{fun} slot should be specified as such:

For all methods, there must be arguments \code{x} for a vector, \code{listw}
for a \code{listw} object specifying the spatial neighborhood graph,
\code{zero.policy} specifying what to do with cells without neighbors
(default NULL, use global option value; if TRUE assign zero to the lagged
value of zones without neighbours, if FALSE assign NA), and optionally other
method specific arguments and \code{...} to pass to the underlying imported
function. If the original function implementing the method in the package has
different argument names or orders, write a thin wrapper to rearrange and/or
rename the arguments.

For univariate methods that use a spatial neighborhood graph, the first two
arguments must be \code{x} and \code{listw}. For univariate methods that
don't use a spatial neighborhood graph, such as the variogram, the first two
arguments must be \code{x} for a numeric vector and \code{coords_df} for a
\code{sf} data frame with cell locations and optionally other regressors. The
\code{formula} argument is optional and can have defaults specifying
regressors to use.

For bivariate methods, the first three arguments must be \code{x}, \code{y},
and \code{listw}.

For multivariate methods, the argument \code{x} is mandatory, for the matrix
input. These arguments must be present but can be optional by having
defaults: \code{listw} and \code{ncomponents} to set the number of dimentions
in the output.

The \code{reorganize_fun} slot should be specified as such:

Univariate methods are meant to be run separately for each gene, so the input
to \code{reorganize_fun} in the argument \code{out} should be a list of
outputs; each element of the list corresponds to the output of a gene.

For univariate global methods, different fields of the result should be
columns of a data frame with one row so results for multiple features will be
a data frame. The arguments should be \code{out}, and \code{name} to rename
the primary field if a more informative name is needed, and \code{...} for
other arguments specific to methods. The output of \code{reorganize_fun}
should be a \code{DataFrame} whose rows correspond to the genes and columns
correspond to fields in the output.

For univariate local methods, the arguments should be \code{out}, \code{nb}
for a neighborhood list used for multiple testing correction, and
\code{p.adjust.method} for a method to correct for multiple testing as in
\code{\link{p.adjust}}, and \code{...}. The output of \code{reorganize_fun}
should be a list of reorganized output. Each element of the list corresponds
to a gene, and the reorganized content of the element can be a vector,
matrix, or data frame, but they must all have the same dimensions for all
genes. Each element of the vector, or each row of the matrix or data frame
corresponds to a cell.

For multivariate methods whose results go into \code{reducedDim},
\code{reorganize_fun} should have one argument \code{out} for the raw output.
The output of \code{reorganize_fun} should be the cell embedding matrix ready
to be added to \code{reducedDim}. Other relevant information such as gene
loadings and eigenvalues should be added to the attributes of the cell
embedding matrix.

For multivariate methods whose results can go into \code{colData}, the
arguments should be \code{out}, \code{nb}, and \code{p.adjust.method}. Unlike
the univariate local counterpart, \code{out} takes the raw output instead of
a list of outputs. The output of \code{reorganize_fun} is a vector or a data
frame ready to be added to \code{colData}.
}
\section{Slots}{

\describe{
\item{\code{info}}{A named character vector specifying information about the method.}

\item{\code{fun}}{The function implementing the method. See Details.}

\item{\code{reorganize_fun}}{Function to convert output from \code{fun} into a format
to store in the SFE object. See Details.}

\item{\code{misc}}{Miscellaneous information on how the method interacts with the
rest of the package. This should be a named list.}
}}

\examples{
moran <- SFEMethod(
name = "moran", title = "Moran's I", package = "spdep", variate = "uni",
scope = "global",
fun = function(x, listw, zero.policy = NULL)
    spdep::moran(x, listw, n = length(listw$neighbours), S0 = spdep::Szero(listw),
                 zero.policy = zero.policy),
reorganize_fun = Voyager:::.moran2df
)
}
\concept{Extensibility}
