read_to_df <- function(filename_prefix, freqs) {
  setwd("./measurement_data")
  cols <- c("time_s",
            "voltage_mV",
            "current_mA",
            "power_mW",
            "acc_energy_mWh",
            "i",
            "freq_GHz")
  df <- data.frame(matrix(ncol = length(cols), nrow = 0))
  colnames(df) <- cols
  for (f in freqs) {
    filename <- paste(filename_prefix, f, "00000.csv", sep="")
    d <- read.csv(filename)
    d$freq_GHz <- rep(f/10, times = nrow(d))
    df <- rbind(df, d)
  }
  setwd("..")
  df
}

create_df_no_wifi_bt <- function(freq_data, change_times) {
  i <- 1
  t1 <- change_times$time_s[[1]]
  freq_data$freq_GHz <- rep(NA, times = nrow(freq_data))
  for (t2 in change_times$time_s[-1]) {
    d <- freq_data[freq_data$time_s >= t1 & freq_data$time_s < t2,]
    freq_data[freq_data$time_s >= t1 & freq_data$time_s < t2,]$freq_GHz <- rep(as.integer(change_times$freq[[i]])/10e5, times = nrow(d))
    t1 <- t2
    i <- i + 1
  }
  freq_data[complete.cases(freq_data),]
}

combine_cases <- function(df_wifi_bt, df_no_wifi_bt) {
  df_wifi_bt$wifi_bt <- rep(TRUE, times = nrow(df_wifi_bt))
  df_no_wifi_bt$wifi_bt <- rep(FALSE, times = nrow(df_no_wifi_bt))
  rbind(df_wifi_bt, df_no_wifi_bt)
}

freqs3 <- c(6:14)
df3 <- combine_cases(
  read_to_df("rpi3-idle-freq-", freqs3),
  create_df_no_wifi_bt(read.csv("./measurement_data/rpi3-freq.csv"),
                       read.csv("./measurement_data/rpi3-changetimes.csv"))
)

freqs4 <- c(6:18)
df4 <- combine_cases(
  read_to_df("rpi4-idle-freq-", freqs4),
  create_df_no_wifi_bt(read.csv("./measurement_data/rpi4-freq.csv"),
                       read.csv("./measurement_data/rpi4-changetimes.csv"))
)

freqs5 <- c(15:24)
df5 <- combine_cases(
  read_to_df("rpi5-idle-freq-", freqs5),
  create_df_no_wifi_bt(read.csv("./measurement_data/rpi5-freq.csv"),
                       read.csv("./measurement_data/rpi5-changetimes.csv"))
)

library(ggplot2)
library(dplyr)
require(gridExtra)

create_power_lineplot <- function(df, title) {
  freqs <- seq(min(df$freq_GHz), max(df$freq_GHz), 0.1)
  df %>%
    group_by(freq_GHz, wifi_bt) %>%
    summarize(m = mean(power_mW)) %>%
    ggplot(aes(color = wifi_bt, x = freq_GHz, y = m)) +
    geom_line() +
    geom_point() +
    scale_x_continuous("Kellotaajuus (GHz)", labels = as.character(freqs), breaks = freqs) +
    guides(color = guide_legend(title="WiFi ja Bluetooth käytössä")) +
    labs(x = "Kellotaajuus (GHz)", y = "Tehon keskiarvo (mW)") +
    ggtitle(title)
}

png("idle_freq_graphs.png", width = 800, height = 800)
grid.arrange(create_power_lineplot(df3, "RPi 3B+"),
             create_power_lineplot(df4, "RPi 4B"),
             create_power_lineplot(df5, "RPi 5"))
dev.off()