################################################################################ 
#                              1-make_images.R                                 #
# Used to construct images for the different samples and the mz values in the  #
# sample.                                                                      #
################################################################################

source("library.R")

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