################################################################################ 
#                            0-project_data.R                                  #
# Contains the data (defining the COI and pointing to peak and header files    #
# for different samples) needed to run the other things.                       #
# This is where one edits to run another experiment                            #
################################################################################

source("library.R")

test_experiment <- make_experiment(l_matrix_file = "test_data_missing/test_matrix_sn1_missing_columns.csv",
                                   l_header_folder = "test_data/Header_Files/",
                                   l_image_out_folder = "test_data_missing/images",
                                   l_roi_image_folder = "test_data_missing/roi_images",
                                   l_roi_csv_folder = "test_data_missing/roi",
                                   l_roi_check_folder = "test_data_missing/roi_check",
                                   l_report_folder = "test_data_missing",
                                   l_roi_csv_targeted_folder = "test_data_missing/targeted_roi/",
                                   l_targets = list(
                                     "GABA" = list("end" = "142.026445121", "std" = "144.03898427",
                                                   "conc" = 2*10^(-6), "exp" = 15,
                                                   "image conc name" = "fmol/pixel"),
                                     "ACh"  = list("end" = "146.117464508", "std" = "155.173889523",
                                                   "conc" = 0.1*10^(-9), "exp" = 21,
                                                   "image conc name" = "zmol/pixel"),
                                     "NaGlu"  = list("end" = "170.0421363085", "std" = "173.061093191",
                                                     "conc" = 10*10^(-6), "exp" = 15,
                                                     "image conc name" = "fmol/pixel")
                                   ),
                                   l_image_height = 5)

project <- list("Test_data_missing" = test_experiment)

# Filter away large IT scans when calculating mean and SD.
remove_high_it <- TRUE

# Use TIC normailization when calculating the mean and
# SD for untargeted.
TIC_normalization <- FALSE

# Should script try to fix Anti-aliasing problems, use check_roi.R script to see
# how the fixed regions compare to the unfixed regions.
aa_fix <- TRUE

# Used for targeted data, keep until it is back in the pipeline.
# The flow rate used in the experiment, needed to calculate the mol / pixel
# for the COI. The flow rate have to be in l/s.
ROI_flowrate <- 0.45 # here given in micro l/m.
ROI_flowrate <- ROI_flowrate *10^(-6)/60 # convert flow rate to l/s.