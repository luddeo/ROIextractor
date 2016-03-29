################################################################################ 
#                              1-make_images.R                                 #
# Used to construct images for the different samples and the mz values in the  #
# sample.                                                                      #
################################################################################

require(png)
require(gtools)
source("library.R")

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

make_intensity_image_matrix <- function(l_position_matrix,l_intensity_values) {
  outlier_limit <- boxplot.stats(as.numeric(l_intensity_values))$stats[5]
  print(outlier_limit)
  l_intensity_values[l_intensity_values > outlier_limit] <- NA
  return(matrix(l_intensity_values[l_position_matrix],
                nrow=nrow(l_position_matrix)))
}

make_image_array <- function(l_intensity_matrix) {
  image_matrix <- array(0, c(dim(l_intensity_matrix), 3)) # The image
  # Scale the intensities to [0,1]
  image_matrix_scaled <- l_intensity_matrix / 
    max(as.numeric(l_intensity_matrix), na.rm=TRUE)
  image_matrix_scaled[is.na(image_matrix_scaled)] <- 1
  
  image_matrix[,,1] <- 2 * image_matrix_scaled
  image_matrix[image_matrix > 1] <- 1
  image_matrix_scaled <- 2*(image_matrix_scaled - 0.5)
  image_matrix_scaled[image_matrix_scaled < 0] <- 0
  image_matrix[,,2] <- image_matrix_scaled
  
  return(image_matrix)
}

for(t_sample in names(project)) {
  print(t_sample)
  
  position_matrix <- make_position_matrix(project, t_sample, image_height)
  intensity_matrix <- read_intensity_matrix(project[[t_sample]][["matrix file"]])
  for(t_name in rownames(intensity_matrix)) {
    intensity_values <- as.numeric(intensity_matrix[t_name,])
    names(intensity_values) <- colnames(intensity_matrix)
    
    writePNG(make_image_array(make_intensity_image_matrix(position_matrix,
                                                          intensity_values)),
             paste(project[[t_sample]][["image out folder"]], "/",
                   t_name, ".png", sep=""))
  }
}