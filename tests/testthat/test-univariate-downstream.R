library(SpatialFeatureExperiment)
library(SingleCellExperiment)
library(bluster)

sfe <- readRDS(system.file("extdata/sfe.rds", package = "Voyager"))
sfe <- runUnivariate(sfe,
    type = "moran.plot", colGraphName = "visium",
    features = c("B", "H"), sample_id = "sample01",
    exprs_values = "counts"
)
sfe <- colDataUnivariate(sfe,
    type = "moran.plot", colGraphName = "visium",
    features = "nCounts", sample_id = "sample01"
)
set.seed(29)
spotPoly(sfe, sample_id = "all")$foo <- rnorm(ncol(sfe))
sfe <- colGeometryUnivariate(sfe,
    type = "moran.plot",
    colGeometryName = "spotPoly",
    colGraphName = "visium", features = "foo",
    sample_id = "sample01"
)

test_that("Moran plot clustering gives right results for gene expression", {
    features <- c("B", "H")
    out <- clusterMoranPlot(sfe, features, KmeansParam(2),
        sample_id = "sample01"
    )
    expect_s3_class(out, "data.frame")
    expect_setequal(names(out), c("sample_id", "B", "H"))
    expect_true(all(vapply(out[, features], is.factor, FUN.VALUE = logical(1))))
    expect_equal(nrow(out), sum(colData(sfe)$sample_id == "sample01"))
    expect_equal(rownames(out), colnames(sfe)[colData(sfe)$sample_id == "sample01"])
})

test_that("Warning when some of the requested features don't have Moran plot", {
    expect_warning(
        out <- clusterMoranPlot(sfe, c("B", "H", "L"), KmeansParam(2),
            sample_id = "sample01"
        ),
        "are absent in"
    )
    expect_s3_class(out, "data.frame")
    expect_setequal(names(out), c("sample_id", "B", "H"))
})

test_that("Error when none of the features have Moran plot", {
    expect_error(
        clusterMoranPlot(sfe, c("Q", "L"), KmeansParam(2), "sample01"),
        "None of the features"
    )
})

test_that("Correct results when doing both gene expression and colData", {
    features <- c("nCounts", "B", "H")
    out <- clusterMoranPlot(sfe, features, KmeansParam(2),
        sample_id = "sample01"
    )
    expect_s3_class(out, "data.frame")
    expect_setequal(names(out), c("sample_id", "B", "H", "nCounts"))
    expect_true(all(vapply(out[, features], is.factor, FUN.VALUE = logical(1))))
    expect_equal(nrow(out), sum(colData(sfe)$sample_id == "sample01"))
    expect_equal(rownames(out), colnames(sfe)[colData(sfe)$sample_id == "sample01"])
})

test_that("Clustering moran plot for multiple samples", {
    features <- c("nCounts", "B", "H")
    out <- clusterMoranPlot(sfe, features, KmeansParam(2),
                            sample_id = "sample01"
    )
    expect_s3_class(out, "data.frame")
    expect_setequal(names(out), c("sample_id", "B", "H", "nCounts"))
    expect_true(all(vapply(out[, features], is.factor, FUN.VALUE = logical(1))))
    expect_equal(nrow(out), sum(colData(sfe)$sample_id == "sample01"))
    expect_equal(rownames(out), colnames(sfe)[colData(sfe)$sample_id == "sample01"])
})

test_that("Correct Moran plot cluster results for colGeometry", {
    out <- clusterMoranPlot(sfe, "foo", KmeansParam(2),
        sample_id = "sample01",
        colGeometryName = "spotPoly"
    )
    expect_s3_class(out, "data.frame")
    expect_setequal(names(out), c("sample_id", "foo"))
    expect_s3_class(out$foo, "factor")
})

test_that("Error when the MoranPlot_sample01 column is absent", {
    rowData(sfe)$MoranPlot_sample01 <- NULL
    expect_error(
        clusterMoranPlot(sfe, c("Q", "L"), KmeansParam(2), "sample01"),
        "None of the features"
    )
})

sfe <- runUnivariate(sfe,
    type = "sp.correlogram", colGraphName = "visium",
    features = rownames(sfe), sample_id = "sample01",
    order = 2, exprs_values = "counts"
)
test_that("Correct clusterCorrelograms output structure", {
    out <- clusterCorrelograms(sfe, rownames(sfe),
        sample_id = "sample01",
        BLUSPARAM = KmeansParam(2)
    )
    expect_s3_class(out, "data.frame")
    expect_named(out, c("feature", "cluster", "sample_id"))
    expect_s3_class(out$cluster, "factor")
})
