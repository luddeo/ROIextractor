source("library.R")

t_combos <- list("NA" = c("NAV", "NAH"),
                 "COR" = c("CORH", "CORV"),
                 "CPU" = c("CPUV", "CPUH")
  )

for(t_sample in names(project)) {
  print(t_sample)
  #roi_files <- paste(project[[t_sample]][["roi csv folder"]],
  #                   sort(list.files(project[[t_sample]][["roi csv folder"]])), sep="/")
  roi_files <- list.files(project[[t_sample]][["roi csv folder"]])

  for(t_name in names(t_combos)) {
    print(t_name)
    t_comb <- NULL
    for(tr_name in t_combos[[t_name]]) {
      print(tr_name)
      tt <- grep(tr_name, roi_files)
      if(length(tt) == 1) {
        print(roi_files[tt])
        t_file <- paste(project[[t_sample]][["roi csv folder"]], roi_files[tt], sep="/")
        t_roi <- read_roi_csv.file(t_file)
        colnames(t_roi) <- paste(tr_name, 1:ncol(t_roi))
        if(is.null(t_comb)) {
          t_comb <- t_roi
        } else {
          t_comb <- cbind(t_comb, t_roi[rownames(t_comb),])
        }
      } else {
        print(tt)
      }
    }
    if(!is.null(t_comb)) {
      print(dim(t_comb))
      t_comb <- t(unique(t(t_comb)))
      print(dim(t_comb))
      write.table(t_comb, paste(project[[t_sample]][["roi csv folder"]], "/",
                                t_sample, " ", t_name, ".csv", sep=""), sep=";")
    }
  }
}