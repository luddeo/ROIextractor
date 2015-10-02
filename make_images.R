################################################################################ 
#                              make_images.R                                   #
# Used to construct images for the different samples and chemical of interest  #
# (COI) combinations. For each sample and COI an image is constructed of the   #
# endogenous m/z, internal standard m/z, normalized values, mol/pixel values   #
# and also the IT values and scan number.                                      #
# For the normalized COI values and mol / pixel values, overlay images are     #
# constructed with the three channels in an image (Red, Green and Blue)        #
# contain the image of one COI each.                                           #
################################################################################

# Load the required librarys and R-files.
require(png)
require(gtools)
source("data.R")
source("library.R")

make_image_data <- function(l_sample, l_project, l_mz_list,
                            l_height, l_flowrate) {
  # Return a list of matrices to be used for ion images. Use l_mz_list for the
  # different matrixes to construct (one for the endogenous, one for the
  # internal standard, one for the normalized COI and one for the mol / pixel)
  # Also makes matrices of the IT and scan. Each matrix has extended lines since
  # Nano-DESI does not have the same number of scans per line.
  
  # Make vectors of the peak files and the header files
  l_peak_files   <- paste(l_project[[l_sample]][["peak folder"]],
                     sort(list.files(l_project[[l_sample]][["peak folder"]])),
                     sep="/")
  l_header_files <- paste(l_project[[l_sample]][["header folder"]],
                     sort(list.files(l_project[[l_sample]][["header folder"]])),
                     sep="/")
  
  # The list of matrices
  l_mass_image_list <- list()
  # Get the max number of scans in a line.
  l_line_max <- get_header_data(l_header_files)[["max line"]]
  
  # Add elements in the list for each COI
  for (t_coi in names(l_mz_list)) {
    # Add a NA line in the begining to avoid problem later
    l_mass_image_list[[as.character(l_mz_list[[t_coi]]$end)]] <-
      matrix(rep(NA,l_line_max), nrow=1)
    l_mass_image_list[[as.character(l_mz_list[[t_coi]]$std)]] <-
      matrix(rep(NA,l_line_max), nrow=1)
    l_mass_image_list[[t_coi]] <-
      matrix(rep(NA,l_line_max), nrow=1)
    l_mass_image_list[[paste(t_coi, "norm", sep="_")]] <-
      matrix(rep(NA,l_line_max), nrow=1)
    l_mass_image_list[[paste(t_coi, "conc", sep="_")]] <-
      matrix(rep(NA,l_line_max), nrow=1)
  }
  
  # Add a IT matrix and scan matrix
  l_mass_image_list[["IT"]]   <- matrix(rep(NA,l_line_max), nrow=1)
  l_mass_image_list[["scan"]] <- matrix(rep(NA,l_line_max), nrow=1)
  
  for(t_line in 1:length(l_peak_files)) {
    print(paste("Line:", t_line))
    
    # Read header file and peak file for the line
    t_header_matrix <- read.header.file(l_header_files[t_line])
    t_peak_matrix <-   read.peak.file(l_peak_files[t_line])
    
    # Calculate the tolerance for the line
    t_tolerance <- get_tolerance(t_peak_matrix)
    
    t_scans <- sort(unique(t_peak_matrix[,"scan_num"]))
    # Temp list of vectors for storing the lines
    t_mass_image_vector <- list()
    for(t_name in names(l_mass_image_list)) {
      t_mass_image_vector[[t_name]] <- c()
    }
    # Get the time per scan
    t_RT_list <- t_header_matrix[,"RT"]
    t_time_list <- t_RT_list - c(0, t_RT_list)[1:length(t_RT_list)]

    # Calculate the number of pixels needed to add to the line to make it
    # the same length as the longest line
    t_extra <- l_line_max - length(t_RT_list)
    
    # The cutoff the the pixels with time above it will be extended on pixel
    t_time_cutoff <- min(rev(sort(t_time_list))[t_extra])
    if(t_extra == 0 ) {
      t_time_cutoff <- Inf
    }
    
    for(t_scan in t_scans) {
      # Get the reduced peak matrix for ust this scan
      t_scan_peak_matrix <- t_peak_matrix[(t_peak_matrix$scan_num == t_scan),]
      t_IT <- t_header_matrix[t_header_matrix[,"SN"] == t_scan,"IT"]
      t_rep <- 1
      if((t_time_list[t_scan] >= t_time_cutoff) & (t_extra > 0)) {
        # If there are to many pixels with high IT (saturation) there will be
        # more pixels with a IT above the cutoff, so only extend the first ones.
        t_rep <- 2
        t_extra <- t_extra - 1
      }
      # Make IT and scan lines
      t_mass_image_vector[["IT"]] <-
        c(t_mass_image_vector[["IT"]], rep(t_IT, t_rep))
      t_mass_image_vector[["scan"]] <-
        c(t_mass_image_vector[["scan"]], rep(t_scan, t_rep))
      
      # Go through the COI
      for(t_coi in names(l_mz_list)) {
        t_conc <- l_mz_list[[t_coi]]$conc
        t_exp  <- 10^(l_mz_list[[t_coi]]$exp)
        t_mz_end <- l_mz_list[[t_coi]]$end
        t_mz_std <- l_mz_list[[t_coi]]$std
        
        # Calculate the intensity for the endogenous and the internal standard.
        t_end_tolerance <- t_tolerance$A * (t_mz_end^t_tolerance$B)/2
        t_end_mins <- which(abs(t_scan_peak_matrix[,"mz"] - t_mz_end) <
                              t_end_tolerance, arr.ind=TRUE)
        t_end <- sum(t_scan_peak_matrix[t_end_mins, "intensity"])
        
        t_std_tolerance <- t_tolerance$A * (t_mz_std^t_tolerance$B)/2
        t_std_mins <- which(abs(t_scan_peak_matrix[,"mz"] - t_mz_std) <
                              t_std_tolerance, arr.ind=TRUE)
        t_std <- sum(t_scan_peak_matrix[t_std_mins, "intensity"])
        
        # Calcualte the mol / pixel value
        t_value <- t_conc * l_flowrate * (t_IT / 1000) * t_exp * (t_end / t_std)
        t_norm <- t_end/t_std
        t_coi_conc <- t_conc * t_norm
        if((t_end == 0) | (t_std == 0)) {
          # If either is zero there is no point in calculate the mol /pixel or
          # nomralized value, NA the calcualted value
          t_value <- NA
          t_norm <- NA
          t_coi_conc <- NA
        }
        
        # Add to the temp vector lines.
        t_mass_image_vector[[as.character(t_mz_end)]] <- 
          c(t_mass_image_vector[[as.character(t_mz_end)]],
            rep(t_end, t_rep))
        t_mass_image_vector[[as.character(t_mz_std)]] <- 
          c(t_mass_image_vector[[as.character(t_mz_std)]],
            rep(t_std, t_rep))
        t_mass_image_vector[[t_coi]] <-
          c(t_mass_image_vector[[t_coi]],
            rep(t_value, t_rep))
        t_mass_image_vector[[paste(t_coi, "norm", sep="_")]] <-
          c(t_mass_image_vector[[paste(t_coi, "norm", sep="_")]],
            rep(t_norm, t_rep))
        t_mass_image_vector[[paste(t_coi, "conc", sep="_")]] <-
          c(t_mass_image_vector[[paste(t_coi, "conc", sep="_")]],
            rep(t_coi_conc, t_rep))
      }
    }
    # Add the templines to the matrices
    for(t_name in names(l_mass_image_list)) {
      t_image_line <- c()
      for(i in 1:l_height) {
        # Make the line wider
        t_image_line <- rbind(t_image_line,
                              t_mass_image_vector[[t_name]])
      }
      l_mass_image_list[[t_name]] <- rbind(
        l_mass_image_list[[t_name]], t_image_line)
    }
  }
  # Remove the first line (the NA line) that was added
  for(t_name in names(l_mass_image_list)) {
    l_mass_image_list[[t_name]] <- l_mass_image_list[[t_name]][-1,]
  }
  return(l_mass_image_list)
}

make_single_image <- function(l_intensity_matrix, l_saturated) {
  # Make image based on the intensity matrix. Use a cutoff of l_saturated
  # standard deviations above the mean (everything above that is saturated).
  # Will use a gradient from 0 (black) through 0.5 (red) to 1 (yellow).
  # Return a 3 dimentional matrix representing the image in three channels
  t_mean <- mean(as.numeric(l_intensity_matrix), na.rm=TRUE)
  t_sd <- sd(as.numeric(l_intensity_matrix), na.rm=TRUE)
  l_intensity_matrix[is.na(l_intensity_matrix)] <- 0 # zero the NAs
  l_intensity_matrix[l_intensity_matrix > t_mean + l_saturated * t_sd] <-
    t_mean + l_saturated * t_sd
  l_image_matrix <- array(0, c(dim(l_intensity_matrix), 3)) # The image
  # Scale the intensities to [0,1]
  l_image_matrix_scaled <- l_intensity_matrix / 
    max(as.numeric(l_intensity_matrix), na.rm=TRUE)
  # Construct the gradient (this should be able to be done better)
  l_image_matrix_scaled[l_image_matrix_scaled > 1] <- 1
  l_image_matrix[,,1] <- 2*l_image_matrix_scaled
  l_image_matrix[l_image_matrix > 1] <- 1
  l_image_matrix_scaled <- 2*(l_image_matrix_scaled - 0.5)
  l_image_matrix_scaled[l_image_matrix_scaled < 0] <- 0
  l_image_matrix[,,2] <- l_image_matrix_scaled
  return(l_image_matrix)
}

make_overlay_image <- function(r_matrix, g_matrix, b_matrix, l_saturated) {
  # Make an image based on the three intensity matrices (r_matrix, g_matrix and
  # b_matrix) each in one of the different channels (Red, Green and Blue).
  # Uses an cutoff in the same way as make_single_image.
  r_mean <- mean(as.numeric(r_matrix), na.rm=TRUE)
  g_mean <- mean(as.numeric(g_matrix), na.rm=TRUE)
  b_mean <- mean(as.numeric(b_matrix), na.rm=TRUE)
  r_sd   <- sd(as.numeric(r_matrix), na.rm=TRUE)
  g_sd   <- sd(as.numeric(g_matrix), na.rm=TRUE)
  b_sd   <- sd(as.numeric(b_matrix), na.rm=TRUE)
  
  r_matrix[is.na(r_matrix)] <- 0
  g_matrix[is.na(g_matrix)] <- 0
  b_matrix[is.na(b_matrix)] <- 0
  
  r_matrix[r_matrix > r_mean + l_saturated * r_sd] <-
    r_mean + l_saturated * r_sd
  g_matrix[g_matrix > g_mean + l_saturated * g_sd] <-
    g_mean + l_saturated * g_sd
  b_matrix[b_matrix > b_mean + l_saturated * b_sd] <-
    b_mean + l_saturated * b_sd
  l_image_matrix <- array(0, c(dim(r_matrix), 3))
  
  r_matrix_scaled <- r_matrix / max(as.numeric(r_matrix), na.rm=TRUE)
  g_matrix_scaled <- g_matrix / max(as.numeric(g_matrix), na.rm=TRUE)
  b_matrix_scaled <- b_matrix / max(as.numeric(b_matrix), na.rm=TRUE)
  
  l_image_matrix[,,1] <- r_matrix_scaled
  l_image_matrix[,,2] <- g_matrix_scaled
  l_image_matrix[,,3] <- b_matrix_scaled
  return(l_image_matrix)
}

for(t_sample in names(project)) {
  print(t_sample)
  
  # Construct the list of matrices.
  t_image <- make_image_data(t_sample, project, mz_list,
                             image_height, ROI_flowrate)
  for(t_name in names(t_image)) {
    # Make an image for each element in the image list.
    t_intensity_matrix <- t_image[[t_name]]
    if(dim(t_intensity_matrix)[1] > 0) {
      writePNG(make_single_image(t_intensity_matrix, image_saturated),
               paste(project[[t_sample]][["image out folder"]], "/",
                     t_name, ".png", sep=""))
    }
  }
  # Make images for the different combinations of three COI from all
  # possible COIs. This will probably crash for less than three COI.
  combinations <- permutations(length(names(mz_list)), 3, v = names(mz_list))
  for(i in 1:(dim(combinations)[1])) {
    t_comb <- combinations[i,]
    la_im <- 
    writePNG(make_overlay_image(t_image[[t_comb[1]]],
                                t_image[[t_comb[2]]],
                                t_image[[t_comb[3]]],
                                image_saturated),
             paste(project[[t_sample]][["image out folder"]],"/R_",
                   t_comb[1], " G_", t_comb[2], " B_", t_comb[3],
                   ".png", sep=""))

    writePNG(make_overlay_image(t_image[[paste(t_comb[1], "norm", sep="_")]],
                                t_image[[paste(t_comb[2], "norm", sep="_")]],
                                t_image[[paste(t_comb[3], "norm", sep="_")]],
                                image_saturated),
             paste(project[[t_sample]][["image out folder"]],"/Norm R_",
                   t_comb[1], " G_", t_comb[2]," B_", t_comb[3],
                   ".png", sep=""))
  }
  
  # For element in the image list, write a CSV file. Used later when finding
  # the scan in a specific pixel
  for(t_name in names(t_image)) {
    write.table(t_image[[t_name]],
                paste(project[[t_sample]][["csv out folder"]], "/" ,t_name,
                      ".csv", sep=""),
                sep=";", qmethod = "double", col.names = FALSE,
                row.names = FALSE)
  }
}