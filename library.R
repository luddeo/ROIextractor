################################################################################ 
#                                 library.R                                    #
# Contains functions that are used in (or expected to) more than one script.   #
################################################################################

require(png)
require(gtools)
require(bigmemory)

read_peak_file <- function(l_file) {
  return(read.csv(l_file, sep="\t"))
}

read_header_file <- function(l_file) {
  return(read.csv(l_file, sep="\t", stringsAsFactors = FALSE))
}

read_roi_csv_file <- function(l_file) {
  return(read.csv(l_file, sep=";"))
}

read_intensity_matrix <- function(l_name) {
  return(read.big.matrix(l_name, sep="\t", has.row.names = T,
                         header=TRUE, type="double"))
}

get_tolerance <- function(l_peak_matrix) {
  # Calcualte the values of a and b in FWHM = a * MZ^b by using least squares.
  # To be used for calculations of tolerance for every m/z value
  l_x <- log(l_peak_matrix[,"mz"]) # load m/z values
  l_y <- log(l_peak_matrix[,"fwhm"]) # load FWHM values
  l_n <- dim(l_peak_matrix)[1]
  l_xsum <- sum(l_x)
  l_ysum <- sum(l_y)
  l_x2sum <- sum(l_x^2)
  l_xysum <- sum(l_x*l_y)
  l_b_tolerance <- (l_xysum - l_xsum*l_ysum/l_n)/(l_x2sum - l_xsum*l_xsum/l_n)
  l_a_tolerance <- exp(l_ysum/l_n - l_b_tolerance*l_xsum/l_n)
  return(list("A" = l_a_tolerance, "B" = l_b_tolerance))
}

get_header_data <- function(l_header_files) {
  # Get data from the header files. Currently the max number of scans in a
  # line and the longest time for a scan.
  l_line_max <- 0
  l_time_max <- 0
  for(t_file in l_header_files) {
    t_header <- read.csv(t_file, sep="\t")
    t_line_max <- dim(t_header)[1]
    t_RT_list <- t_header[,"RT"]
    t_time_list <- t_RT_list - c(0, t_RT_list)[1:length(t_RT_list)]
    t_time_max <- max(t_time_list)
    if(l_time_max < t_time_max) {
      l_time_max <- t_time_max
    }
    if(l_line_max < t_line_max) {
      l_line_max <- t_line_max
    }
  }
  return(list("max line" = l_line_max, "max time" = l_time_max))
}

anti_analising_fix <- function(l_roi_image) {
  # A sort-of fix to the problem with anti-analising in images. Not the best
  # solution, but it can help.
  t_roi_values <- c(l_roi_image[,,3])
  t_roi_values <- t_roi_values[t_roi_values > 0.1] # just to get rid of zeros
  t_roi_table <- table(t_roi_values)
  # Find the value with max in blue channel
  t_r <- c(which.max(t_roi_table))
  l_roi_image[l_roi_image[,,3] < as.numeric(names(t_roi_table[t_r - 1]))] <- 0
  return(l_roi_image)
}


make_position_matrix <- function(l_project, l_sample, l_height) {
  # Makes a matrix of the scan number on a line (it is the same as the old scan
  # matrix). Need to add the line too, so that it can be used to make an image
  # with the correct measure of the m/z at the correct position.
  header_files <- paste(l_project[[l_sample]][["header folder"]],
                        sort(list.files(l_project[[l_sample]][["header folder"]])),
                        sep="/")
  
  # Get the max number of scans in a line.
  max_line_length <- get_header_data(header_files)[["max line"]]
  position_matrix <- c()
  
  for(t_line in seq(header_files)) {
    print(paste("Line:", t_line))
    
    header_matrix <- read_header_file(header_files[t_line])
    # Calculate the number of pixels needed to add to the line to make it
    # the same length as the longest line
    extra_lines <- max_line_length - nrow(header_matrix)
    # Get list of the time length of each scan
    time_list <- diff(c(0,header_matrix[,"RT"]))
    # The cutoff the the pixels with time above it will be extended on pixel
    time_cutoff <- ifelse(extra_lines == 0, Inf,
                          min(rev(sort(time_list))[extra_lines]))
    line_vector <- c()
    for(t_scan in header_matrix[,"SN"]) {
      IT <- header_matrix[header_matrix[,"SN"] == t_scan,"IT"]
      scan_rep <- 1
      if((time_list[t_scan] >= time_cutoff) & (extra_lines > 0)) {
        # If there are to many pixels with high IT there will be
        # more pixels with a IT above the cutoff, so only extend the first ones.
        scan_rep <- 2
        extra_lines <- extra_lines - 1
      }
      line_vector <- c(line_vector, rep(paste(t_line, t_scan, sep=":"), 
                                        scan_rep))
    }
    image_line <- c()
    for(i in 1:l_height) {
      # Make the line wider
      image_line <- rbind(image_line, line_vector)
    }
    position_matrix <- rbind(position_matrix, image_line)
  }
  return(position_matrix)
}