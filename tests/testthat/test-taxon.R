test_that("taxon is tibble", {
  ans <- get_taxon(taxonID = 1)
  expect_s3_class(ans, "tbl")
})

test_that("multiple taxa downloadable", {
  n <- sample(seq_len(25), 1)
  ids <- sample(seq_len(3e3), n)
  ans <- get_taxon(taxonID = ids)
  expect_equal(length(unique(ans[["taxonID"]])), n)
})
