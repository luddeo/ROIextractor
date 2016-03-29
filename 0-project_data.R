################################################################################ 
#                            0-project_data.R                                  #
# Contains the data (defining the COI and pointing to peak and header files    #
# for different samples) needed to run the other things.                       #
# This is where one edits to run another experiment                            #
################################################################################

# List of different experiments, pointing out the different
# folders for the peak files, the header files, where csv files are written,
# where images with drawn ROIs are and where ROI files are written.
# For additional samples, add another list similar to "Brain 1"
project <- list(
  "Test_data" = list("matrix file" = "test_data/test_sn1_170.comb.csv",
                     "header folder" = "test_data/headers",
                     "image out folder" = "test_data/images",
                     "roi images folder" = "test_data/roi_images",
                     "roi csv folder" = "test_data/roi",
                     "check roi folder" = "test_data/roi_check")
)

# The factor that ion image's height is extended with so that the image is
# not as flat.
image_height <- 5

# Should script try to fix Anti-aliasing problems, use check_roi.R script to see
# how the fixed regions compare to the unfixed regions.
aa_fix <- TRUE

# The flow rate used in the experiment, needed to calculate the mol / pixel
# for the COI. The flow rate have to be in l/s.
ROI_flowrate <- 0.45 # here given in micro l/m.
ROI_flowrate <- ROI_flowrate *10^(-6)/60 # convert flow rate to l/s.