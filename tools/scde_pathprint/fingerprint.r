#!/usr/bin/env Rscript

#sink(file("/dev/null", "w"), type = "message");

library(affy)
library(GEOquery);
library(pathprint);

# Figure out the relative path to the galaxy-pathprint.r library.
script.args  <- commandArgs(trailingOnly = FALSE);
script.name  <- sub("--file=", "", script.args[grep("--file=", script.args)])
script.base  <- dirname(script.name)
library.path <- file.path(script.base, "galaxy-pathprint.r");
source(library.path)

data(GEO.metadata.matrix);

usage <- function() {
  sink(stderr(), type = "message");
  stop("Usage: fingerprint.r [ARGS]", call. = FALSE)
}

## Get the command line arguments.
args <- commandArgs(trailingOnly = TRUE)

type <- ifelse(! is.na(args[1]), args[1], usage())

if (type == "geo") {
   geoID       <- ifelse(! is.na(args[2]), args[2], usage());
   output      <- ifelse(! is.na(args[3]), args[3], usage());

   fingerprint <- generateFingerprint(geoID);
} else if (type == "cel") {
   input       <- ifelse(! is.na(args[2]), args[2], usage());
   output      <- ifelse(! is.na(args[3]), args[3], usage());

   fingerprint <- loadFingerprintFromCELFile(input);
} else if (type == "expr") {
   input       <- ifelse(! is.na(args[2]), args[2], usage());
   platform    <- ifelse(! is.na(args[3]), args[3], usage());
   output      <- ifelse(! is.na(args[4]), args[4], usage());

   fingerprint <- loadFingerprintFromExprsFile(input, platform);
} else {
  usage();
};

saveFingerprint(fingerprint, output);

quit("no", 0)
