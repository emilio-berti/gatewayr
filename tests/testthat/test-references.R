test_that("reference table returned", {
  expect_s3_class(get_reference(), "tbl")
})
