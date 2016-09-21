################################################################################ 
#                               2-check_roi.R                                  #
# Reads the roi images and construct images with the roi area that will be     #
# used by the later script.                                                    #
################################################################################

source("library.R")

for(t_sample in names(project)) {
  # Get the path to the ROI images and the CSV files
  roi_image_files <- paste(project[[t_sample]]$roi_image_folder,
                           sort(list.files(project[[t_sample]]$roi_image_folder)), sep="/")
  
  for(t_file in roi_image_files) {
    print(t_file)
    roi_image <- readPNG(t_file, native=FALSE)
    # Do this copy in case the image lacks an
    # alpha channel.
    out_image <- array(0, c(dim(roi_image)[1:2],4))
    t_dim <- dim(roi_image)[3]
    out_image[,,1:t_dim] <- roi_image
    out_image[,,4] <- 0.7
    t_lines <- seq(from=1, to=dim(roi_image)[1], by=project[[t_sample]]$image_height)
    
    t_roi_image <- anti_analising_fix(roi_image)
    
    for(t_line in 1:length(t_lines)) {
      tt_line <- t_lines[t_line]
      # Get the pixels that are part of the ROI
      t_image_line <- (colSums(roi_image[tt_line:(tt_line+4),,3]) > 0)
      tt_image_line <- (colSums(t_roi_image[tt_line:(tt_line+4),,3]) > 0)
      out_image[tt_line:(tt_line+project[[t_sample]]$image_height-1),t_image_line | tt_image_line,1:3] <- 0
      out_image[tt_line:(tt_line+project[[t_sample]]$image_height-1),t_image_line | tt_image_line,4] <- 1
      if(sum(t_image_line) > 0) { # if pixels in the line
        print(paste("line:",t_line))
        out_image[tt_line:(tt_line+project[[t_sample]]$image_height-1),t_image_line,3] <- 1
      }
      if(sum(tt_image_line) > 0) { # if pixels in the line
        print(paste("line:",t_line))
        out_image[tt_line:(tt_line+project[[t_sample]]$image_height-1),tt_image_line,2] <- 1
        out_image[tt_line:(tt_line+project[[t_sample]]$image_height-1),tt_image_line,3] <- 0
      }
    }
    writePNG(out_image, paste(project[[t_sample]]$roi_check_folder,"/", t_sample,
                              strsplit(basename(t_file), split=".png")[[1]],
                              ".png", sep=""))
  }
}