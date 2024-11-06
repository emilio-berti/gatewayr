test_that("metabolic type table returned", {
  expect_s3_class(get_metabolic_type(), "tbl")
})
