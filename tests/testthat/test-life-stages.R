test_that("life stage table returned", {
  expect_s3_class(get_life_stage(), "tbl")
})
