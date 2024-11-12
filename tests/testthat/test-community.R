test_that("selecting community columns works", {
  choices <- c(
    "foodwebName", "ecosystemType", "decimalLongitude",
    "decimalLatitude", "geographicLocation", "studySite",
    "verbatimElevation", "verbatimDepth", "acceptedTaxonName",
    "taxonRank", "taxonomicStatus", "vernacularName",
    "lifeStage", "lowestMass", "highestMass",
    "meanMass", "shortestLength", "longestLength",
    "meanLength", "biomass", "movementType",
    "metabolicType", "sizeMethod", "reference"
  )
  n <- sample(seq_along(choices), 1)
  cols <- sample(choices, n)
  ans <- get_community(foodwebID = 1, columns = cols)
  expect_identical(names(ans), cols)
})

test_that("selecting all community columns works", {
  choices <- c(
    "communityID", "foodwebID", "taxonID", "lifeStageID", "metabolicTypeID",
    "movementTypeID", "sizeMethodID", "referenceID",
    "foodwebName", "ecosystemType", "decimalLongitude",
    "decimalLatitude", "geographicLocation", "studySite",
    "verbatimElevation", "verbatimDepth",
    "samplingTime", "earliestDateCollected", "latestDateCollected",
    "acceptedTaxonName", "taxonRank", "taxonomicStatus", "vernacularName",
    "lifeStage", "lowestMass", "highestMass",
    "meanMass", "shortestLength", "longestLength",
    "meanLength", "biomass", "movementType",
    "metabolicType", "sizeMethod", "reference"
  )
  ans <- get_community(foodwebID = 1, columns = "all")
  expect_identical(names(ans), choices)
})

test_that("community is tibble", {
  ans <- get_community(foodwebID = 1, columns = "all")
  expect_s3_class(ans, "tbl")
})
