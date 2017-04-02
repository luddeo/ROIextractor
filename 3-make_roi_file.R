################################################################################ 
#                               3-make_roi_file.R                              #
# Used to construct files of the ROIs by reading the ROI from images where one #
# ROI per image is drawn (in Blue).                                            #
################################################################################

source("library.R")

for(t_sample in names(project)) {
  # Get the path to the ROI images and load the position matrix and
  # intensity matrix.
  roi_image_files <- paste(roi_image_folder,
                           sort(list.files(roi_image_folder)), sep="/")

  for(t_file in roi_image_files) {
    print(t_file)
    # Read the ROI image
    roi_image <- readPNG(t_file, native=FALSE)
    
    # Fix anti-analising problem, not garantied to work propertly
    # Was a variable, but do alwaws anyway.
    if(TRUE) {
      roi_image <- anti_analising_fix(roi_image)
    }
    # Get the pixel's names with non-zero blue value, which is the ROI.
    roi_pixels <-  project[[t_sample]]$position_matrix[roi_image[,,3] > 0]
    roi_data <- project[[t_sample]]$intensity_matrix[,unique(roi_pixels)]

    write.table(roi_data, paste(roi_csv_folder, "/",
                                  t_sample, " ", strsplit(basename(t_file),
                                                          split=".png")[[1]],
                                  ".csv", sep=""), sep=";")
  }
}