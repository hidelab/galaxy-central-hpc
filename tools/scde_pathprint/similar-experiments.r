#!/usr/bin/env Rscript

#sink(file("/dev/null", "w"), type = "message");

library(pathprint);

# Figure out the relative path to the galaxy-pathprint.r library.
script.args  <- commandArgs(trailingOnly = FALSE);
script.name  <- sub("--file=", "", script.args[grep("--file=", script.args)])
script.base  <- dirname(script.name)
library.path <- file.path(script.base, "galaxy-pathprint.r");
source(library.path)

usage <- function() {
  stop("Usage: similar_experiments.r <input> <output>", call. = FALSE)
}

## Get the command line arguments.
args <- commandArgs(trailingOnly = TRUE)

input     <- ifelse(! is.na(args[1]), args[1], usage())
output    <- ifelse(! is.na(args[2]), args[2], usage())

threshold <- 0.8

fingerprint <- loadFingerprint(input);
consensus <- consensusFingerprint(fingerprint, threshold);
distance <- calculateDistanceToGEO(consensus);

# Display only the first 50 closest experiments
#distance <- distance[1:50,]

generateSimilarExperiments(distance, output);

quit("no", 0)
