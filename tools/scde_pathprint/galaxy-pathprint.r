
## List of arrays supported by PathPrint as of version 1.2.2  This will need to
## be updated/replaced with a better version as PathPrint's support changes.
supportedArrays <- function() {
  return(matrix(c("GPL72",   "DrosGenome1",    "Affymetrix Drosophila Genome Array",                 "drosophila",
                  "GPL85",   "RG_U34A",        "Affymetrix Rat Genome U34 Array",                    "rat",
                  "GPL91",   "HG_U95A",        "Affymetrix Human Genome U95A Array",                 "human",
                  "GPL96",   "HG-U133A",       "Affymetrix Human Genome U133A Array",                "human",
                  "GPL200",  "Celegans",       "Affymetrix C. elegans Genome Array",                 "C.elegans",
                  "GPL339",  "MOE430A",        "Affymetrix Mouse Expression 430A Array",             "mouse",
                  "GPL341",  "RAE230A",        "Affymetrix Rat Expression 230A Array",               "rat",
                  "GPL570",  "HG-U133_Plus_2", "Affymetrix Human Genome U133 Plus 2.0 Array",        "human",
                  "GPL571",  "HG-U133A_2",     "Affymetrix Human Genome U133A 2.0 Array",            "human",
                  "GPL1261", "Mouse430_2",     "Affymetrix Mouse Genome 430 2.0 Array",              "mouse",
                  "GPL1319", "Zebrafish",      "Affymetrix Zebrafish Genome Array",                  "zebrafish",
                  "GPL1322", "Drosophila_2",   "Affymetrix Drosophila Genome 2.0 Array",             "drosophila",
                  "GPL1355", "Rat230_2",       "Affymetrix Rat Genome 230 2.0 Array",                "rat",
                  "GPL2700", "",               "Sentrix HumanRef-8 Expression BeadChip",             "human",
                  "GPL2986", "",               "ABI Human Genome Survey Microarray Version 2",       "human",
                  "GPL2995", "",               "ABI Mouse Genome Survey Microarray",                 "mouse",
                  "GPL3921", "HT_HG-U133A",    "Affymetrix HT Human Genome U133A Array",             "human",
                  "GPL4685", "U133AAofAv2",    "Affymetrix GeneChip HT-HG_U133A Early Access Array", "human",
                  "GPL6102", "",               "Illumina human-6 v2.0 expression beadchip",          "human",
                  "GPL6103", "",               "Illumina mouseRef-8 v1.1 expression beadchip",       "mouse",
                  "GPL6104", "",               "Illumina humanRef-8 v2.0 expression beadchip",       "human",
                  "GPL6105", "",               "Illumina mouse-6 v1.1 expression beadchip",          "mouse",
                  "GPL6333", "",               "Illumina Mouse Ref-6 V1",                            "mouse",
                  "GPL6883", "",               "Illumina HumanRef-8 v3.0 expression beadchip",       "human",
                  "GPL6884", "",               "Illumina HumanWG-6 v3.0 expression beadchip",        "human",
                  "GPL6885", "",               "Illumina MouseRef-8 v2.0 expression beadchip",       "mouse",
                  "GPL6887", "",               "Illumina MouseWG-6 v2.0 expression beadchip",        "mouse",
                  "GPL6947", "",               "Illumina HumanHT-12 V3.0 expression beadchip",       "human",
                  "GPL8300", "HG_U95Av2",      "Affymetrix Human Genome U95 Version 2 Array",        "human",
                  "GPL8321", "Mouse430A_2",    "Affymetrix Mouse Genome 430A 2.0 Array",             "mouse"),
                ncol = 4, byrow = TRUE))
}

fingerprintGSM <- function(geoID) {
  if (is.existingGeoID(geoID)) {
    ## If we've already got the GEO ID in the matrix, don't bother loading it
    ## again, just pull out the data we need.
    gsm.fingerprint <- GEO.fingerprint.matrix[,geoID]
  } else {
    ## We weren't able to find the GEO ID in the matrix so try to load all the
    ## data we need from NCBI.
    try(gsm <- getGEO(geoID, GSElimits = NULL), silent = FALSE)
    if (! exists("gsm")) {
      sink(stderr(), type = "message");
      stop(sprintf("Unable to load GEO id '%s': is the GEO id valid?\n", geoID))
    }
    
    gsm.exprs       <- Table(gsm)
    gsm.platform    <- Meta(gsm)$platform_id
    gsm.species     <- Meta(gsm)$organism_ch1

    ## Compute the fingerprint for the GSM id.
    gsm.fingerprint <- exprs2fingerprint(exprs       = gsm.exprs,
                                         platform    = gsm.platform,
                                         species     = gsm.species,
                                         progressBar = FALSE)
  }

  ## Convert the fingerprint to a data frame.
  gsm.fingerprint <- as.data.frame(gsm.fingerprint)
  
  ## Tag the fingerprint as having been calculated on a GSM id.
  attr(gsm.fingerprint, 'fingerprintType') <- 'GSM'
  attr(gsm.fingerprint, 'fingerprintGEO')  <- geoID
  
  return(gsm.fingerprint)
}

fingerprintGSE <- function(geoID) {
  if (is.existingGeoID(geoID) && 0) {
    ## If we've already got the GEO ID in the matrix, don't bother loading it
    ## again, just pull out the data we need.
    gse             <- na.omit(GEO.metadata.matrix[GEO.metadata.matrix$GSE == geoID,])
    gse.gsm         <- gse[,"GSM"]

    gse.fingerprint <- GEO.fingerprint.matrix[,gse.gsm]
  } else {
    try(gse <- getGEO(geoID), silent = FALSE)
    if (! exists("gse")) {
      sink(stderr(), type = "message");
      stop(sprintf("Unable to load GEO id '%s': is the GEO id valid?\n", geoID))
    } else {
      print(gse)
    }
    
    gse.exprs       <- exprs(gse[[1]])
    gse.platform    <- annotation(gse[[1]])
    gse.species     <- as.character(unique(phenoData(gse[[1]])$organism_ch1))

    ## Compute the fingerprint for the GSE id.
    gse.fingerprint <- exprs2fingerprint(exprs       = gse.exprs,
                                         platform    = gse.platform,
                                         species     = gse.species,
                                         progressBar = FALSE)
  }

  ## Tag the fingerprint as having been calculated on a GSE id.
  attr(gse.fingerprint, 'fingerprintType') <- 'GSE'
  attr(gse.fingerprint, 'fingerprintGEO')  <- geoID
  
  return(gse.fingerprint)
}

generateFingerprint <- function(geoID) {
  if (is.geoID(geoID)) {
    if (is.geoGSM(geoID)) {
      return(fingerprintGSM(geoID))
    } else {
      return(fingerprintGSE(geoID))
    }
  } else {
    sink(stderr(), type = "message");
    stop(paste("not a GEO ID:", geoID))
  }
}

loadFingerprint <- function(file) {
  fingerprint <- read.delim(file, header = TRUE, sep = "\t");
  return(fingerprint);
}

saveFingerprint <- function(fingerprint, file) {
  if (! is.null(attr(fingerprint, 'fingerprintType'))) {
    if ((attr(fingerprint, 'fingerprintType') == 'GSE')) {
      data <- fingerprint[,1:ncol(fingerprint)]
      cols <- colnames(fingerprint);

      write.table(data, row.names = TRUE,
      			col.names = cols,
                        file      = file,
                        quote     = FALSE,
                        sep       = "\t")
    } else {
      	   data <- data.frame(fingerprint[,1])
      	   rownames(data) <- rownames(fingerprint)
      	   write.table(data, row.names = TRUE,
                               col.names = attr(fingerprint, 'fingerprintGEO'),
                               file      = file,
                               quote     = FALSE,
                               sep       = "\t")
    }     
  } else {
    sink(stderr(), type = "message");
    stop("Unable to save fingerprint: unknown fingerprint type")
  }
}

saveConsensus <- function(consensus, file) {
  write.table(consensus, row.names = TRUE,
                       	 col.names = TRUE,
                         file      = file,
                         quote     = FALSE,
                         sep       = "\t")
}

calculateDistanceToGEO <- function(consensus) {
# sample from matrix to	speed it up
# sample <- sample(dim(GEO.fingerprint.matrix)[2], 10000, replace=FALSE)
# GEO.distance  <- consensusDistance(consensus, GEO.fingerprint.matrix[,sample])
  GEO.distance  <- consensusDistance(consensus, GEO.fingerprint.matrix)

  similar.GEO <- GEO.metadata.matrix[
        match(rownames(GEO.distance), GEO.metadata.matrix$GSM),
        c("GSM", "GSE", "GPL", "Source")]
                                             
  similar.GEO <- cbind(similar.GEO[1:sum(GEO.distance$pvalue < 0.01),], 
                         GEO.distance[1:sum(GEO.distance$pvalue < 0.01),])
  return(similar.GEO)

}

calculateDistanceToPluripotent <- function(fingerprint, verbose = 0) {
  #if (ncol(fingerprint) > 1) {
    if (verbose) print("Calculating distances from pluripotent consensus for multiple sample")
    ## Calculate the distance from the pluripotent consensus for a multiple sample.
    pluripotent.consensus <- consensusFingerprint(GEO.fingerprint.matrix[,pluripotents.frame$GSM], 0.9)
    fingerprint.distance  <- consensusDistance(pluripotent.consensus, fingerprint)
    if(ncol(fingerprint)==1) {
	rownames(fingerprint.distance) <- colnames(fingerprint) 
    }    
  #} else {
  #  if (verbose) print("Calculating distances from pluripotent consensus for single sample")
  #  ## Calculate the distance from the pluripotent consensus for a single sample.
  #  pluripotent <- GEO.fingerprint.matrix[,pluripotents.frame$GSM]
  #  fingerprint.distance <- data.frame(consensusDistance(fingerprint, pluripotent))
  #}

  return(fingerprint.distance)
}

saveDistance <- function(distance, file, pvalue = 1) {
  write.table(distance, row.names = TRUE,
                        col.names = TRUE,
                        file      = file,
                        quote     = FALSE,
                        sep       = "\t")
}

loadDistance <- function(file, pvalue = 1) {
  distance <- read.delim(file, header = TRUE, sep = "\t");
  return(distance);
}

generateHistograms <- function(distance, filename) {
  if (nrow(distance) == 0) {
    sink(stderr(), type = "message");
    stop("Unable to generate histogram: no distances to plot - try increasing p-value?")
  }

  pdf(filename, width = 8, height = 8)

  xlab1 <- "Distance of GEO records from pluripotent consensus"
  xlab2 <- "Distance of submitted data from pluripotent consensus"

  ## Calculate the distance of the pluripotent to GEO.
  pluripotent.consensus <- consensusFingerprint(GEO.fingerprint.matrix[,pluripotents.frame$GSM], 0.9)
  geo.distance = calculateDistanceToGEO(pluripotent.consensus)
  
  ## Output the first histogram.
  par(oma = c(5, 2, 2, 2), mfcol = c(2,1), mar = c(0, 4, 4, 2))
  hist(geo.distance[,"distance"], col    ="grey", 
                                  main   = "",
                                  nclass = 50,
                                  xlab   = xlab1,
                                  xlim   = c(0,1))

  ## Output the second histogram.
  par(mar = c(7, 4, 4, 2))
  hist(distance[,"distance"], cex.lab = 0.8,
                              col     = "green",
                              main    = "", 
                              xlab    = xlab2,
                              xlim    = c(0,1)) 
  mtext(cex  = 0.8,
        line = 0.5,
        side = 3,
        text = "Distance of GEO records from pluripotent consensus")

  invisible(dev.off())
}

generateHeatmap <- function(fingerprint, sdev, filename) {

  if(ncol(fingerprint) <= 1) {
    sink(stderr(), type = "message");
    stop("unable to generate heatmap on fingerprint with single column. Requires a dataset with multiple samples.",
          call. = FALSE)
  }

  heatmap.data <- fingerprint[apply(fingerprint, 1, sd) > sdev, ]
  if(dim(heatmap.data)[1] < 2) {
    sink(stderr(), type="message");
    stop("unable to generate heatmap - try lowering the standard deviation cutoff",
	call. = FALSE)
  }  

  library(pheatmap)
  pdf(filename, width = 8, height = 10)
  # make sure row and column names are readable
  fontsize_row = 10 - nrow(heatmap.data) / 15
  if (fontsize_row < 2) {
    show_rownames = FALSE
  }
  else {
    show_rownames = TRUE
  }
  fontsize_col = 10 - ncol(heatmap.data) / 15
  if (fontsize_row < 2) {
    show_colnames = FALSE
  }
  else {
    show_colnames = TRUE
  }
  pheatmap(as.matrix(heatmap.data),
           col = c("blue", "white", "red"),
        	 legend_breaks=c(-1,0,1),
           fontsize_row=fontsize_row,
           fontsize_col=fontsize_col,
           cluster_cols=TRUE,
           main=paste("All samples, sd=", sdev, sep=""),
           show_rownames=show_rownames,
           show_colnames=show_colnames
  )
  invisible(dev.off())
}

loadFingerprintFromCELFile <- function(filename) {
  ## Load the data from the provided CEL file.
  tryCatch({ data <- ReadAffy(filenames = c(filename)) },
             error = function(err) {
                       sink(stderr(), type = "message");
                       stop("unable to parse CEL file - ensure provided file is valid",
                            call. = FALSE)
                     })

  ## Get the reported platform, if any, from the CEL file.
  platform <- getPlatformFromArrayName(cdfName(data))
  if (is.null(platform)) {
    sink(stderr(), type = "message");
    stop(sprintf("Unable to determine from platform from CEL file"));
  };
  if (! is.supportedPlatform(platform)) {
    sink(stderr(), type = "message");
    stop(sprintf("The '%s' platform is not supported by PathPrint", platform))
  }

  ## Create the fingerprint based on the CEL file data.
  cel.fingerprint <- exprs2fingerprint(exprs(rma(data)), platform, getPlatformSpecies(platform))

  ## Convert the fingerprint to a data frame.
  cel.fingerprint <- as.data.frame(cel.fingerprint)
  
  ## Tag the fingerprint as having been calculated on either a GSM or GSE id.
  if (ncol(cel.fingerprint) == 1) {
    attr(cel.fingerprint, 'fingerprintType') <- 'GSM'
  } else {
    attr(cel.fingerprint, 'fingerprintType') <- 'GSE'
  }
  attr(cel.fingerprint, 'fingerprintGEO') <- 'Unknown GEO ID'
  
  ## Return the fingerprint
  return(cel.fingerprint)
}

loadFingerprintFromExprsFile <- function(filename, platform) {
  if (! is.supportedPlatform(platform))
    stop(sprintf("The '%s' platform is not supported by PathPrint", platform))
  
  ## Load the data from the provided expression set file.
  tryCatch({ data <- read.delim(filename, sep=("\t")) },
             error = function(err) {
                       stop(sprintf("Unable to parse expression set file: %s", err),
                            call. = FALSE)
                     })

  species <- getPlatformSpecies(platform);
  print(platform)
  print(species)

  ## Create the fingerprint based on the expression set file data.
  tryCatch({ exprs.fingerprint <- exprs2fingerprint(as.data.frame(data), platform, getPlatformSpecies(platform)) },
           error = function(err) {
	   	   		 print(err);
                       stop(sprintf("Expression set to fingerprint conversion failed.  Please ensure the platform is correct."))
                     })

  ## Convert the fingerprint to a data frame.
  exprs.fingerprint <- as.data.frame(exprs.fingerprint)

  ## Tag the fingerprint as having been calculated on either a GSM or GSE id.
  if (ncol(exprs.fingerprint) == 1) {
    attr(exprs.fingerprint, 'fingerprintType') <- 'GSM'
  } else {
    attr(exprs.fingerprint, 'fingerprintType') <- 'GSE'
  }
  
  ## Return the fingerprint
  return(exprs.fingerprint)
}

##
## Helper functions for validating if a CEL file is supported by PathPrint
## and for accessing data about the platform or species it supports.
##

is.existingGeoID <- function(id) {
  if (is.geoID(id)) {
    if (is.geoGSM(id)) {
      id %in% GEO.metadata.matrix[,"GSM"]
    } else {
      id %in% GEO.metadata.matrix[,"GSE"]
    }
  } else {
    NULL
  }
}

## Check to see if the provided platform is supported by PathPrint.
is.supportedPlatform <- function(platform) {
  platform %in% supportedArrays()[,1]
}

## Check to see if the provided species is supported by PathPrint.
is.supportedSpecies <- function(species) {
  species %in% supportedArrays()[,4]
}
 
## Given the array name, return the corresponding species.
getPlatformSpecies <- function(platform) {
  if (is.supportedPlatform(platform)) {
    return(supportedArrays()[grep(sprintf("^%s$", platform), (supportedArrays()[,1])), 4])
  } else {
    return(NULL)
  }
}

## Lookup the platform using the array name.
getPlatformFromArrayName <- function(array) {
  platform <- supportedArrays()[grep(sprintf("^%s$", array), (supportedArrays()[,2])), 1]

  if (length(platform))
    return(platform)
  else
    return(NULL)
}

generateSimilarExperiments <- function(data, filename) {
  sink(filename, append=FALSE, split=FALSE)

  cat("<html>\n")
  cat("<head>\n")
  cat("<title>Similar Experiments in GEO</title>\n")
  cat("
    <style type='text/css'>


      .data-table {
        border-collapse:       collapse;
        width:                 100%;
      }

      .data-table td, th {
        border:                1px solid lightslategrey;
        color:                 #000080;
        font-family:           Verdana,Geneva,Arial,sans-serif;
        padding:               4px;
        font-size:             75%;
        overflow:              hidden;
        text-overflow:         ellipsis;
      }

      .data-table th {
        font-weight:           bold;
      }
    </style>\n");
  cat("<head>\n")
  cat("<body>\n")
  cat("<table class='data-table'>\n")
  cat("<tr>")
  cat("<th>GSM ID</th>")
  cat("<th>GSE ID</th>")
  cat("<th>GPL ID</th>")
  cat("<th>Source</th>")
  cat("<th>distance</th>")
  cat("<th>p-value</th>")
  cat("</tr>\n")
for(i in 1:nrow(data)) {
    cat("<tr>",
	"<td><a href='", createGEOLink(data$GSM[i]), "' target=0>", data$GSM[i], "</a></td>",
        "<td><a href='", createGEOLink(data$GSE[i]), "' target=0>", data$GSE[i], "</a></td>",
        "<td><a href='", createGEOLink(data$GPL[i]), "' target=0>", data$GPL[i], "</a></td>",
        "<td>", data$Source[i], "</td>",
        "<td>", data$distance[i], "</td>",
        "<td>", data$pvalue[i], "</td>",
        "</tr>\n", sep = '')
  }

  cat("</table>\n")
  cat("</body\n")
  cat("</html>\n")

  sink()
}

##
## Helper functions
##

## Create a link to the GEO ID.
createGEOLink <- function(id) {
  sprintf("http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=%s", id)
}

## Check if the provided ID corresponds to the GEO GSM format.
is.geoGSM <- function(id) {
  length(grep("^GSM\\d+$", id, ignore.case = TRUE)) > 0
}

## Check if the provided ID corresponds to the GEO GSE format.
is.geoGSE <- function(id) {
  length(grep("^GSE\\d+$", id, ignore.case = TRUE)) > 0
}

## Check if the provided ID corresponds to the GEO format.
is.geoID <- function(id) {
  return(is.geoGSM(id) | is.geoGSE(id))
}

