################################################################################ 
#                                     data.R                                   #
# Contains the data (defining the COI and pointing to peak and header files    #
# for different samples) needed to run the other things.                       #
# This is where one edits to run another experiment                            #
################################################################################

# List of different experiments, pointing out the different
# folders for the peak files, the header files, where csv files are written,
# where images with drawn ROIs are and where ROI files are written.
# For additional samples, add another list similar to "Brain 1"
project <- list(
  "Brain 1"   = list("peak folder" = "peaks/brain1",
                     "header folder" = "headers/brain1",
                     "csv out folder" = "csv/brain1",
                     "image out folder" = "images/brain1",
                     "roi images folder" = "roi_images/brain1",
                     "roi csv folder" = "roi/brain1"),
  "Brain 1_2"   = list("peak folder" = "peaks/brain1_2",
                       "header folder" = "headers/brain1_2",
                       "csv out folder" = "csv/brain1_2",
                       "image out folder" = "images/brain1_2",
                       "roi images folder" = "roi_images/brain1_2",
                       "roi csv folder" = "roi/brain1_2"),
	"Brain 2"   = list("peak folder" = "peaks/brain2",
                     "header folder" = "headers/brain2",
                     "csv out folder" = "csv/brain2",
                     "image out folder" = "images/brain2",
                     "roi images folder" = "roi_images/brain2",
                     "roi csv folder" = "roi/brain2"),
	"Brain 4"   = list("peak folder" = "peaks/brain4",
                     "header folder" = "headers/brain4",
                     "csv out folder" = "csv/brain4",
                     "image out folder" = "images/brain4",
                     "roi images folder" = "roi_images/brain4",
                     "roi csv folder" = "roi/brain4"),
	"Brain 5"   = list("peak folder" = "peaks/brain5",
                     "header folder" = "headers/brain5",
                     "csv out folder" = "csv/brain5",
                     "image out folder" = "images/brain5",
                     "roi images folder" = "roi_images/brain5",
                     "roi csv folder" = "roi/brain5")
)

# The list of COI (Chemical of interest), defining the endogenous m/z,
# internal standard m/z, concentration of the internal standard,
# the magnitude to multiply calculated concentration (mol / pixel) of
# the endogenous (the exp parameter, result will be multiplied by 10^exp)
# and the name for the mol/pixel (used in graphs)
mz_list <- list("GABA" = list("end" = 142.0264435, "std" = 144.0389709,
                              "conc" = 2*10^(-6), "exp" = 15,
                              "image conc name" = "fmol/pixel"),
                "ACh"  = list("end" = 146.1174   , "std" = 155.1738892,
                              "conc" = 0.1*10^(-9), "exp" = 21,
                              "image conc name" = "zmol/pixel"),
                "Glu"  = list("end" = 186.0162201, "std" = 189.0350189,
                              "conc" = 10*10^(-6), "exp" = 15,
                              "image conc name" = "fmol/pixel"),
				"NaGlu"  = list("end" = 170.042, "std" = 173.0610,
                              "conc" = 10*10^(-6), "exp" = 15,
                              "image conc name" = "fmol/pixel"),
				"NaGABA" = list("end" = 126.0526, "std" = 128.0651,
                              "conc" = 2*10^(-6), "exp" = 15,
                              "image conc name" = "fmol/pixel"))

# The factor that ion image's height is extended with so that the image is
# not as flat.
image_height <- 5

# The number of standard deviations above mean the image is saturated above.
image_saturated <- 3

# Should script try to fix Anti-aliasing problems, use check_roi.R script to see
# how the fixed regions compare to the unfixed regions.
aa_fix <- TRUE

# The flow rate used in the experiment, needed to calculate the mol / pixel
# for the COI. The flow rate have to be in l/s.
ROI_flowrate <- 0.45 # here given in micro l/m.
ROI_flowrate <- ROI_flowrate *10^(-6)/60 # convert flow rate to l/s.