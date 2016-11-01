#Temp stuff for identifying targets

for(t_sample in names(project)) {
  print(t_sample)
  roi_image_files <- paste(project[[t_sample]]$roi_csv_folder,
                           sort(list.files(project[[t_sample]]$roi_csv_folder)), sep="/")
  for(t_file in roi_image_files) {
    print(basename(t_file))
    roi_name <- substr(basename(t_file),
                       nchar(t_sample)+2,
                       nchar(basename(t_file))-4)
    roi_data <- as.matrix(read_roi_csv_file(t_file))
    value_order <- colnames(roi_data)
    t_all_it <- project[[t_sample]]$header_matrix[,"IT"]
    names(t_all_it) <- paste(project[[t_sample]]$header_matrix[,"line"],project[[t_sample]]$header_matrix[,"SN"], sep=":")
    t_IT <- t_all_it[value_order]

    targeted_matrix <- c()
    targeted_rownames <- c()
    for(t_coi in names(project[[t_sample]]$targets)) {
      t_conc <- project[[t_sample]]$targets[[t_coi]]$conc
      t_exp  <- 10^(project[[t_sample]]$targets[[t_coi]]$exp)
      t_mz_end <- project[[t_sample]]$targets[[t_coi]]$end
      t_mz_std <- project[[t_sample]]$targets[[t_coi]]$std

      t_end <- roi_data[t_mz_end,]
      t_std <- roi_data[t_mz_std,]
      # Calcualte the mol / pixel value
      t_value <- t_conc * ROI_flowrate * (t_IT / 1000) * t_exp * (t_end / t_std)
      
      t_norm <- t_end/t_std
      
      t_coi_conc <- t_conc * t_norm
      # If either is zero there is no point in calculate the mol /pixel or
      # nomralized value, NA the calcualted value
      t_test <- (t_end == 0) | (t_std == 0) | is.na(t_end) | is.na(t_std)
      t_value[t_test] <- NA
      t_norm[t_test] <- NA
      t_coi_conc[t_test] <- NA
      
      targeted_matrix <- rbind(targeted_matrix, t_norm, t_coi_conc, t_value)
      targeted_rownames <- c(targeted_rownames, 
                             paste(t_coi, c("Norm", "Conc", "Amount")))
    }
    rownames(targeted_matrix) <- targeted_rownames
    write.table(targeted_matrix, paste(project[[t_sample]]$roi_csv_targeted_folder,
                                       paste(substr(basename(t_file),1,nchar(t_file)-4),"targeted", ".csv", sep="_"), sep="/") , sep=";")
  }
}