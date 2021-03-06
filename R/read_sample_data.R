
read_sample_data <- function(my_dir, def_filename = "sample_data.csv",
                             ext = c("report","profile")) {

  gd_sample_data <- FALSE

  if (file.exists(file.path(my_dir,def_filename))) {
    sample_data <- read.delim(file.path(my_dir,def_filename), header = TRUE, sep = ";", stringsAsFactors = FALSE)

    if (!"ReportFile" %in% colnames(sample_data)){
      warning("Required column 'ReportFile' not present in ",def_filename)
    } else if (!"Name" %in% colnames(sample_data)){
      warning("Required column 'Name' not present in ",def_filename)
    } else {
      gd_sample_data <- TRUE
    }
  }
  if (!gd_sample_data) {
    ReportFiles <- setdiff(list.files(path = my_dir), list.dirs(my_dir))
    ReportFiles <- ReportFiles[ReportFiles != def_filename]
    if (!is.null(ext))
      ReportFiles <- ReportFiles[sub(".*\\.","",ReportFiles) %in% ext]

    Name = basename(ReportFiles)
    if (length(Name) > 1) {
      while(length(unique(substr(Name, nchar(Name), nchar(Name)))) == 1) {
        Name <- substr(Name, 1, nchar(Name) - 1)
      }
    }

    sample_data <- data.frame(Name,
                              ReportFile = ReportFiles, stringsAsFactors = FALSE)
  }

  if (length(sample_data) == 0 || nrow(sample_data) == 0) {
    return(NULL)
  }

  #if ("Class" %in% colnames(sample_data))
  #  sample_data$Class <- as.factor(sample_data$Class)

  if (!"ReportFilePath" %in% colnames(sample_data))
    sample_data$ReportFilePath <- file.path(my_dir, sample_data$ReportFile)

  if ("CentrifugeOutFile" %in% colnames(sample_data) && !"CentrifugeOutFilePath" %in% colnames(sample_data))
    sample_data$CentrifugeOutFilePath <- file.path(my_dir, sample_data$CentrifugeOutFile)

  if ("KrakenFile" %in% colnames(sample_data) && ! "KrakenFilePath" %in% colnames(sample_data))
    sample_data$KrakenFilePath <- file.path(my_dir, sample_data$KrakenFile)

  if ("FastqFile" %in% colnames(sample_data) && ! "FastqFilePath" %in% colnames(sample_data))
    sample_data$FastqFilePath <- file.path(my_dir, sample_data$FastqFile)

  if (!"Include" %in% colnames(sample_data))
    sample_data <- cbind(Include = file.exists(sample_data$ReportFilePath), sample_data)


  sample_data
}
