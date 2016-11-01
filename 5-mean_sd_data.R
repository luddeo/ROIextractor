source("library.R")
#TODO: add something that filteres out high IT values
# remove_high_it <- FALSE

make_mean_sd_matrix <- function(l_folder, l_sample, l_TIC_norm = FALSE) {
  mean_sd_matrix <- c()
  mean_sd_colnames <- c()
  roi_files <- paste(l_folder, sort(list.files(l_folder)), sep="/")
  
  for(t_file in roi_files) {
    print(basename(t_file))
    roi_name <- substr(basename(t_file),
                       nchar(t_sample)+2,
                       nchar(basename(t_file))-4)
    roi_data <- as.matrix(read_roi_csv_file(t_file)) # ADDED as.matrix HERE INCAS WANT TO CHECK.
    if(l_TIC_norm) {
      apply(roi_data,2,mean, na.rm = TRUE) -> tt
      t(apply(roi_data,1,function(x){x/tt})) -> roi_data
    }
    mean_sd_matrix <- cbind(mean_sd_matrix, apply(roi_data,1,mean, na.rm = TRUE), apply(roi_data,1,sd, na.rm = TRUE))
    mean_sd_colnames <- c(mean_sd_colnames, paste(roi_name, "mean"),paste(roi_name,"sd"))
  }
  colnames(mean_sd_matrix) <- mean_sd_colnames
  return(mean_sd_matrix)
}

for(t_sample in names(project)) {
  write.table(make_mean_sd_matrix(project[[t_sample]]$roi_csv_folder, t_sample, TIC_normalization),
              paste(project[[t_sample]]$report_folder,paste(t_sample,"_untargeted_mean_sd.csv"), sep="/"), sep=";")
  if(!is.null(project[[t_sample]]$roi_csv_targeted_folder)) {
    write.table(make_mean_sd_matrix(project[[t_sample]]$roi_csv_targeted_folder, t_sample),
                paste(project[[t_sample]]$report_folder,paste(t_sample,"_targeted_mean_sd.csv"), sep="/"), sep=";")
  }
  
  
  
}