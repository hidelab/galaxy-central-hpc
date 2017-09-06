#!/usr/bin/env Rscript

#sink(file("/dev/null", "w"), type = "message");

library(pathprint);

# Figure out the relative path to the galaxy-pathprint.r library.
script.args  <- commandArgs(trailingOnly = FALSE);
script.name  <- sub("--file=", "", script.args[grep("--file=", script.args)])
script.base  <- dirname(script.name)
library.path <- file.path(script.base, "galaxy-pathprint.r");
source(library.path)

data(GEO.metadata.matrix);

usage <- function() {
  stop("Usage: distance.r <input> <output> <output2>", call. = FALSE)
}

## Get the command line arguments.
args <- commandArgs(trailingOnly = TRUE)

input  <- ifelse(! is.na(args[1]), args[1], usage())
output <- ifelse(! is.na(args[2]), args[2], usage())
output2 <- ifelse(! is.na(args[3]), args[3], usage())

fingerprint <- loadFingerprint(input);
distance    <- calculateDistanceToPluripotent(fingerprint, verbose = 0);
saveDistance(distance, output);

generateHistograms(distance, output2);

quit("no", 0)
