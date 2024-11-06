test_that("movement type table returned", {
  expect_s3_class(get_movement_type(), "tbl")
})
