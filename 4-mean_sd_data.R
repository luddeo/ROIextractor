source("library.R")

TIC_normalization <- FALSE

for(t_sample in names(project)) {
  mean_sd_matrix <- c()
  mean_sd_colnames <- c()
  print(t_sample)
  roi_image_files <- paste(project[[t_sample]]$roi_csv_folder,
                           sort(list.files(project[[t_sample]]$roi_csv_folder)), sep="/")
  
  for(t_file in roi_image_files) {
    print(basename(t_file))
    roi_name <- substr(basename(t_file),
                       nchar(t_sample)+2,
                       nchar(basename(t_file))-4)
    roi_data <- as.matrix(read_roi_csv_file(t_file)) # ADDED as.matrix HERE INCAS WANT TO CHECK.
    if(TIC_normalization) {
      apply(roi_data,2,mean, na.rm = TRUE) -> tt
      t(apply(roi_data,1,function(x){x/tt})) -> roi_data
    }
    mean_sd_matrix <- cbind(mean_sd_matrix, apply(roi_data,1,mean, na.rm = TRUE), apply(roi_data,1,sd, na.rm = TRUE))
    mean_sd_colnames <- c(mean_sd_colnames, paste(roi_name, "mean"),paste(roi_name,"sd"))
  }
  colnames(mean_sd_matrix) <- mean_sd_colnames
  write.table(mean_sd_matrix, paste(t_sample,"mean_sd.csv"), sep=";")
}