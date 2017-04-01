source("library.R")

make_mean_sd_matrix <- function(l_folder, l_sample, l_TIC_norm = FALSE) {
  mean_sd_matrix <- c()
  mean_sd_colnames <- c()
  roi_files <- paste(l_folder, sort(list.files(l_folder)), sep="/")
  
  for(t_file in roi_files) {
    cat(basename(t_file),"\n")
    roi_name <- substr(basename(t_file),
                       nchar(t_sample)+2,
                       nchar(basename(t_file))-4)
    roi_data <- as.matrix(read_roi_csv_file(t_file)) # ADDED as.matrix HERE INCAS WANT TO CHECK.
    t_IT_limit <- NA 
    if(l_TIC_norm) {
      apply(roi_data,2,mean, na.rm = TRUE) -> tt
      t(apply(roi_data,1,function(x){x/tt})) -> roi_data
    }
    if(remove_high_it) {
      t_IT <- project[[l_sample]]$header_matrix[,"IT"]
      t_IT_limit <- min(boxplot.stats(t_IT)$out,max(t_IT)+1)
      t_test <- (t_IT < t_IT_limit)
      cat("\tIT limit:", t_IT_limit,"\n")
      t_valid_ones <- paste(project[[l_sample]]$header_matrix[t_test,"line"],project[[l_sample]]$header_matrix[t_test,"SN"],sep=":")
      roi_data <- roi_data[,intersect(colnames(roi_data),t_valid_ones)]
    }
    
    
    mean_sd_matrix <- cbind(mean_sd_matrix, apply(roi_data,1,mean, na.rm = TRUE),
                            apply(roi_data,1,sd, na.rm = TRUE), ncol(roi_data),
                            format(apply({temp<-(roi_data>0);temp[is.na(temp)]<-0;temp},1,mean, na.rm=TRUE), digits=5), t_IT_limit,
                            TIC_normalization)
    mean_sd_colnames <- c(mean_sd_colnames, paste(roi_name, "mean"),paste(roi_name,"sd"),
                          paste(roi_name,"#scans"), paste(roi_name,"% non-zero scans"),
                          paste(roi_name," IT cutoff"), paste(roi_name," TIC normalized"))

  }
  colnames(mean_sd_matrix) <- mean_sd_colnames
  return(mean_sd_matrix)
}

for(t_sample in names(project)) {
  write.table(make_mean_sd_matrix(roi_csv_folder, t_sample, TIC_normalization),
              paste(report_folder,paste(t_sample,"_untargeted_mean_sd.csv"), sep="/"), sep=";")
  if(!is.null(roi_csv_targeted_folder)) {
    write.table(make_mean_sd_matrix(roi_csv_targeted_folder, t_sample),
                paste(report_folder,paste(t_sample,"_targeted_mean_sd.csv"), sep="/"), sep=";")
  }
}