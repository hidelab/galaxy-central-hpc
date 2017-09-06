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
  stop("Usage: heatmap.r <fingerprint> <sdev> <output>", call. = FALSE)
}

## Get the command line arguments.
args <- commandArgs(trailingOnly = TRUE)

input  <- ifelse(! is.na(args[1]), args[1], usage())
sdev <- ifelse(! is.na(args[2]), as.numeric(args[2]), usage())
output    <- ifelse(! is.na(args[3]), args[3], usage())


fingerprint <- loadFingerprint(input);
fingerprint <- data.frame(fingerprint[complete.cases(fingerprint),]);

generateHeatmap(fingerprint, sdev, output);

quit("no", 0)
