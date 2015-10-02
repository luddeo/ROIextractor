################################################################################ 
#                               quantify.R                                     #
# Used to construct files of the ROIs by reading the ROI from images where one #
# ROI per image is drawn (in Blue).                                            #
################################################################################

require(png)
require(gtools)
source("data.R")
source("library.R")

for(t_sample in names(project)) {
  # Get the path to the ROI images and the CSV files
  roi_image_files <- paste(project[[t_sample]][["roi images folder"]],
                           sort(list.files(project[[t_sample]][["roi images folder"]])), sep="/")
  csv_files <- sort(list.files(project[[t_sample]][["csv out folder"]]))
  
  # Add the CSVs to list
  csv_list <- list()
  for(csv_file in csv_files) {
    t_csv_name <- strsplit(csv_file, split=".csv")[[1]]
    csv_list[[t_csv_name]] <- read.csv(paste(project[[t_sample]][["csv out folder"]],csv_file, sep="/"), header=FALSE, sep=";")
  }
  
  for(t_file in roi_image_files) {
    print(t_file)
    # Read the ROI image
    roi_image <- readPNG(t_file, native=FALSE)
    
    # Fix anti-analysis problem, not garantied to work propertly
    if(aa_fix) {
      roi_image <- anti_analising_fix(roi_image)
    }
    # Get the line numbers in the image that correspond to line number in the
    # measurement (since each line in the measurement correspon to several lines
    # in the image)
    t_lines <- seq(from=1, to=dim(roi_image)[1], by=image_height)
    # Construct the matrix where the values for the ROI are added. Start with
    # a NA column that is removed later.
    t_roi_data <- matrix(rep(NA,length(csv_list) + 1),
                         nrow=(length(csv_list) + 1))
    rownames(t_roi_data) <- c("line", names(csv_list))
    
    for(t_line in 1:length(t_lines)) {
      tt_line <- t_lines[t_line]
      # Get the pixels that are part of the ROI
      t_image_line <- (colSums(roi_image[tt_line:(tt_line+image_height-1),,3]) > 0)
      #if(t_line == 34) {break}
      if(sum(t_image_line) > 0) { # if pixels in the line
        print(paste("line:",t_line))
        t_roi_part <- c()
        for(t_part in rownames(t_roi_data)) {
          t_value <- rep(t_line, sum(t_image_line))
          # line is special since there is no CSV file for is
          if(t_part != "line") {
            t_value <- csv_list[[t_part]][tt_line, t_image_line]
          }
          # Add to the column
          # print(paste("value:",length(t_value), "logic:", sum(t_image_line)))
          t_roi_part <- rbind(t_roi_part, as.numeric(t_value))
        }
        # Add column to the ROI data
        t_roi_data <- cbind(t_roi_data, t_roi_part)
      }
    }
    t_roi_data <- t_roi_data[,-1] # Remove first NA column
    # Since some scans have two pixels in the image, the duplicates must be
    # removed. Transpose before and after since unique only removes duplicated
    # rows (and we want to remove duplicated columns).
    t_roi_data <- t(unique(t(t_roi_data)))
    write.table(t_roi_data, paste(project[[t_sample]][["roi csv folder"]], "/",
                                  t_sample, " ", strsplit(basename(t_file),
                                                          split=".png")[[1]],
                                  ".csv", sep=""), sep=";")
  }
}