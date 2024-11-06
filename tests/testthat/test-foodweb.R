test_that("foodweb is tibble", {
  ans <- get_foodweb(foodwebID = 1)
  expect_s3_class(ans, "tbl")
})

test_that("multiple foodwebs downloadable", {
  n <- sample(seq_len(15), 1)
  ids <- sample(seq_len(300), n)
  ans <- get_foodweb(foodwebID = ids)
  expect_equal(length(unique(ans[["foodwebID"]])), n)
})
