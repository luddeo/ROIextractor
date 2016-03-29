################################################################################ 
#                               3-make_roi_file.R                              #
# Used to construct files of the ROIs by reading the ROI from images where one #
# ROI per image is drawn (in Blue).                                            #
################################################################################

require(png)
require(gtools)
source("library.R")

for(t_sample in names(project)) {
  # Get the path to the ROI images and load the position matrix and
  # intensity matrix.
  roi_image_files <- paste(project[[t_sample]][["roi images folder"]],
                           sort(list.files(project[[t_sample]][["roi images folder"]])), sep="/")
  position_matrix <- make_position_matrix(project, t_sample, image_height)
  intensity_matrix <- read_intensity_matrix(project[[t_sample]][["matrix file"]])
  
  for(t_file in roi_image_files) {
    print(t_file)
    # Read the ROI image
    roi_image <- readPNG(t_file, native=FALSE)
    
    # Fix anti-analysis problem, not garantied to work propertly
    if(aa_fix) {
      roi_image <- anti_analising_fix(roi_image)
    }
    # Get the pixel's names with non-zero blue value, which is the ROI.
    roi_pixels <-  position_matrix[roi_image[,,3] > 0]
    roi_data <- intensity_matrix[,unique(roi_pixels)]
    # The quantification has been removed for now, so it is only
    # untargeted.

    write.table(roi_data, paste(project[[t_sample]][["roi csv folder"]], "/",
                                  t_sample, " ", strsplit(basename(t_file),
                                                          split=".png")[[1]],
                                  ".csv", sep=""), sep=";")
  }
}