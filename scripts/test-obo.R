# test for extracting information from obo files
# to use this file, use source("test-obo.R")


library(testthat)
source("obo.R")

test_that("date from date field", {
  result <- obo.date(c("abc", "date: 2020-06-01"))
  expect_equal(result, "2020-06-01")
})

test_that("date from data version", {
  result <- obo.date(c("abc", "data-version: 2019-08-26"))
  expect_equal(result, "2019-08-26")
})

test_that("date from versionInfo field", {
  obo <- paste("property_value: http://www.w3.org/2002/07/owl#versionInfo",
               "\" 2014-05-28\" xsd:string")
  result <- obo.date(obo)
  expect_equal(result, "2014-05-28")
})

test_that("date from versionInfo field", {
  obo <- paste0("property_value: http://www.w3.org/2002/07/owl#versionInfo ",
                "\"release version - 2020-01-23\" xsd:string")
  result <- obo.date(obo)
  expect_equal(result, "2020-01-23")
})

test_that("date from property field date", {
  obo <- paste0("property_value: http://purl.org/dc/elements/1.1/date ",
                "\"06-14-2020\" xsd:string")
  result <- obo.date(obo)
  expect_equal(result, "2020-06-14")
})
