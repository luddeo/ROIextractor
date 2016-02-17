#script.dir <- dirname(sys.frame(1)$ofile)
library(ggplot2)
source("data.R")
source("library.R")

t_sample_whole <- list(
  "Brain 1"   = " Wholeimage",
  "Brain 1_2" = " Whole",
  "Brain 2"   = " Whole",
  "Brain 4"   = " Whole",
  "Brain 5"   = " whole"
)

df_IT_cutoff <- c()
df_brain <- c()
df_ROI <- c()
df_mean <- c()
df_sd <- c()
df_coi <- c()
df_nmean <- c()
df_nerr <- c()
df_nsd <- c()
df_pixlar <- c()
df_type <- c()

for(t_sample in names(project)) {
  t_df_IT_cutoff <- c()
  t_df_brain <- c()
  t_df_ROI <- c()
  t_df_mean <- c()
  t_df_sd <- c()
  t_df_coi <- c()
  t_df_pixlar <- c()
  t_df_type <- c()
  print(t_sample)
  # Get the path to the ROI images and the CSV files
  roi_files <- paste(project[[t_sample]][["roi csv folder"]],
                           sort(list.files(project[[t_sample]][["roi csv folder"]])), sep="/")
  header_files <- paste(project[[t_sample]][["header folder"]],
                        sort(list.files(project[[t_sample]][["header folder"]])), sep="/")
  
  IT_list <- c()
  for(t_file in header_files) {
    t_header <- read_header_file(t_file)
    IT_list <- c(IT_list, t_header[,"IT"])
  }
  IT_cutoff <- min(boxplot.stats(IT_list)$out)
  
  for(t_file in roi_files) {
    t_roi <- read_roi_csv_file(t_file)
    t_test <- (t_roi["IT",] < IT_cutoff)
    t_temp <- strsplit(basename(t_file), t_sample)[[1]][2]
    t_roi_name <- strsplit(t_temp, ".csv")[[1]]
    t_pixlar <- ncol(t_roi)
    print(t_roi_name)
    
    for(t_name in names(mz_list)) {
      t_df_IT_cutoff <- c(t_df_IT_cutoff, IT_cutoff, IT_cutoff)
      t_df_brain <- c(t_df_brain, t_sample, t_sample)
      t_df_ROI <- c(t_df_ROI, t_roi_name, t_roi_name)
      t_df_coi <- c(t_df_coi, t_name, t_name)
      t_df_pixlar <- c(t_df_pixlar, t_pixlar, t_pixlar)
      
      t_data <- as.numeric(t_roi[t_name, t_test])
      t_data_conc <- as.numeric(t_roi[paste(t_name, "conc", sep="_"), t_test])
      t_df_mean <- c(t_df_mean, mean(t_data, na.rm=TRUE), mean(t_data_conc, na.rm=TRUE))
      t_df_sd <- c(t_df_sd, sd(t_data, na.rm=TRUE), sd(t_data_conc, na.rm=TRUE))
      t_df_type <- c(t_df_type, "amount", "conc")
    }
    
  }
  t_whole <- t_sample_whole[[t_sample]]
  t_test <- t_df_ROI == t_whole
  t_nmean <- rep(NA,length(t_df_ROI))
  t_nerr <- rep(NA, length(t_df_ROI))
  t_nsd <- rep(NA, length(t_df_ROI))
  for(t_name in names(mz_list)) {
    for (t_type in c("amount", "conc")) {
      t_test_coi <- (t_df_coi == t_name) & (t_df_type == t_type)
      t_nmean[t_test_coi] <- t_df_mean[t_test_coi]/t_df_mean[t_test_coi & t_test]
      t_nerr[t_test_coi] <- sqrt((1/t_df_mean[t_test_coi & t_test]^2)*t_df_sd[t_test_coi]^2 +
                                   ((t_df_mean[t_test_coi]/(t_df_mean[t_test_coi & t_test])^2)^2)*t_df_sd[t_test_coi & t_test]^2)
      t_nsd[t_test_coi] <- t_df_sd[t_test_coi]/abs(t_df_mean[t_test_coi & t_test])
    }
  }
  
  
  df_IT_cutoff <- c(df_IT_cutoff, t_df_IT_cutoff)
  df_brain <- c(df_brain, t_df_brain)
  df_ROI <- c(df_ROI, t_df_ROI)
  df_mean <- c(df_mean, t_df_mean)
  df_sd <- c(df_sd, t_df_sd)
  df_coi <- c(df_coi, t_df_coi)
  df_nmean <- c(df_nmean, t_nmean)
  df_nerr <- c(df_nerr, t_nerr)
  df_nsd <- c(df_nsd, t_nsd)
  df_pixlar <- c(df_pixlar, t_df_pixlar)
  df_type <- c(df_type, t_df_type)
}
df_ROI[df_ROI %in% unlist(t_sample_whole)] <- " Whole"
t_df <- data.frame(sample = df_brain,
                   ROI = df_ROI,
                   COI = df_coi,
                   type = df_type,
                   mean = df_mean,
                   sd = df_sd,
                   nmean = df_nmean,
                   nsd = df_nsd,
                   nerr = df_nerr,
                   ITcutoff = df_IT_cutoff,
                   pixels = df_pixlar)
write.table(t_df, "data.csv", sep=";")

# pdf("data.pdf", width=14)
# for(t_name in names(mz_list)) {
#   tt_data <- t_df[t_df[,"COI"] == t_name,]
#   #tt_data <- tt_data[tt_data[, "ROI"] != " Whole",]
#   p <- ggplot(tt_data, aes(y=nmean, x=ROI, group=sample, color=sample)) +
#     geom_line(size=1) + geom_point(size=3) + #geom_errorbar(limits) +
#     ggtitle(t_name)
#   print(p)
# }
# dev.off()

pdf("data.pdf", width=14)
for(t_name in names(mz_list)) {
  ttt_data <- t_df[t_df[,"COI"] == t_name,]
  for(t_type in c("amount", "conc")) {
    tryCatch({
      tt_data <- ttt_data[ttt_data[,"type"] == t_type,]
      p <- ggplot(tt_data, aes(y=nmean, x=ROI, group=sample, color=sample)) +
        geom_line(size=1) + geom_point(size=3) + #geom_errorbar(limits) +
        ggtitle(paste(t_name, t_type))
      print(p)
    }, error = function(err) {
    print(paste("Error in ", t_name))
    print(err)
  })
  }
}
dev.off()