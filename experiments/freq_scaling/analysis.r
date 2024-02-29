
#cols <- c("governor",
#          "task_size",
#          "task_interval",
#          "time_since_start_s",
#          "voltage_mV",
#          "current_mA",
#          "power_mW",
#          "acc_energy_mWh",
#          "mean_cpu_utilization")
#
#df <- data.frame(matrix(ncol = length(cols), nrow = 0))
#colnames(df) <- cols
#
#setwd("./measurement_data")
#
#for (size in c(2, 4, 8)) {
#  for (interval in c(1, 2, 3)) {
#    for (gov in c("conservative", "ondemand", "powersave", "performance")) {
#      for (i in c(1:50)) {
#        f <- paste(gov, "-", size, "-", interval, "-iter", i, ".csv", sep = "")
#        measurements <- read.csv(f)
#        utilization <- read.csv(paste("./utilization/", f, sep = ""))
#        measurements$mean_cpu_utilization <- rep(mean(utilization$cpu_utilization_percentage), times = length(measurements$time_since_start_s))
#        df <- rbind(df, measurements)
#      }
#    }
#  }
#}

# to be continued
# check out: https://plotly.com/r/3d-scatter-plots/