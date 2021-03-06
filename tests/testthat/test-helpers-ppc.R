library(bayesplot)
context("PPC: misc. functions")

source("data-for-ppc-tests.R")

# melt_yrep ---------------------------------------------------------------
expect_molten_yrep <- function(yrep) {
  y <- rnorm(ncol(yrep))
  yrep <- validate_yrep(yrep, y)

  x <- melt_yrep(yrep)
  expect_equal(ncol(x), 3)
  expect_equal(nrow(x), prod(dim(yrep)))
  expect_identical(colnames(x), c("rep_id", "y_id", "value"))
  expect_s3_class(x, "data.frame")
  expect_s3_class(x$rep_id, "factor")
  expect_type(x$y_id, "integer")
  expect_type(x$value, "double")
}

test_that("melt_yrep returns correct structure", {
  expect_molten_yrep(yrep)
  expect_molten_yrep(yrep2)

  load("data-for-binomial.rda")
  expect_molten_yrep(Ey)
  expect_molten_yrep(validate_yrep(yrep, y))
})


# melt_and_stack ----------------------------------------------------------
test_that("melt_and_stack returns correct structure", {
  molten_yrep <- melt_yrep(yrep)
  d <- melt_and_stack(y, yrep)
  expect_s3_class(d, "data.frame")
  expect_equal(nrow(d), nrow(molten_yrep) + length(y))
  expect_identical(colnames(d), c(colnames(molten_yrep), "is_y"))
})


# ppc_group_data ----------------------------------------------------------

d <- ppc_group_data(y, yrep, group)
d_stat <- ppc_group_data(y, yrep, group, stat = "mean")

test_that("ppc_group_data returns correct structure", {
  expect_identical(colnames(d), c("group", "variable", "value"))
  expect_s3_class(d, c("grouped_df", "tbl_df", "tbl", "data.frame"))

  expect_identical(colnames(d_stat), colnames(d))
  expect_s3_class(d, c("grouped_df", "tbl_df", "tbl", "data.frame"))

  nr <- length(unique(d$variable)) * length(unique(group))
  expect_equal(nrow(d_stat), nr)
})

test_that("ppc_group_data with stat returns correct values for y", {
  for (lev in levels(group)) {
    mean_y_group <- with(d_stat, value[group == lev & variable == "y"])
    expect_equal(mean_y_group, mean(y[group == lev]),
                 info = paste("group =", lev))
  }
})

test_that("ppc_group_data with stat returns correct values for yrep", {
  for (lev in levels(group)) {
    for (j in 1:nrow(yrep)) {
      var <- paste0("yrep_", j)
      mean_yrep_group <- with(d_stat, value[group == lev & variable == var])
      expect_equal(mean_yrep_group, mean(yrep[j, group == lev]),
                   info = paste("group =", lev, "|", "rep =", j))
    }
  }
})
