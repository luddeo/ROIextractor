################################################################################ 
#                                 library.R                                    #
# Contains functions that are used in (or expected to) more than one script.   #
################################################################################

read.peak.file <- function(l_file) {
  return(read.csv(l_file, sep="\t"))
}

read.header.file <- function(l_file) {
  return(read.csv(l_file, sep="\t", stringsAsFactors = FALSE))
}

read.roi.csv.file <- function(l_file) {
  return(read.csv(l_file, sep=";"))
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