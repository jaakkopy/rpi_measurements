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
df3 <- df3[df3$power_mW > 0,]

freqs4 <- c(6:18)
df4 <- combine_cases(
  read_to_df("rpi4-idle-freq-", freqs4),
  create_df_no_wifi_bt(read.csv("./measurement_data/rpi4-freq.csv"),
                       read.csv("./measurement_data/rpi4-changetimes.csv"))
)
df4 <- df4[df3$power_mW > 0,]

freqs5 <- c(15:24)
df5 <- combine_cases(
  read_to_df("rpi5-idle-freq-", freqs5),
  create_df_no_wifi_bt(read.csv("./measurement_data/rpi5-freq.csv"),
                       read.csv("./measurement_data/rpi5-changetimes.csv"))
)
df5 <- df5[df3$power_mW > 0,]


relative_power_increase <- function(data, wifi_bt) {
  df <- data[data$wifi_bt == wifi_bt,]
  freqs <- unique(df$freq_GHz)
  f1 <- freqs[1]
  p1 <- mean(df[df$freq_GHz == f1,]$power_mW)
  for (f2 in freqs[-1]) {
    p2 <- mean(df[df$freq_GHz == f2,]$power_mW)
    print(paste(f1, "to", f2, ":", (p2/p1 - 1) * 100, "%"))
    p1 <- p2
    f1 <- f2
  }
  print("Relative difference between highest and lowest frequencies:")
  f1 <- min(freqs)
  f2 <- max(freqs)
  p1 <- mean(df[df$freq_GHz == f1,]$power_mW)
  p2 <- mean(df[df$freq_GHz == f2,]$power_mW)
  print(paste(f1, "to", f2, ":", (p2/p1 - 1) * 100, "%"))
}

relative_power_increase(df3, TRUE)
relative_power_increase(df4, TRUE)
relative_power_increase(df5, TRUE)

relative_power_increase(df3, FALSE)
relative_power_increase(df4, FALSE)
relative_power_increase(df5, FALSE)

library(ggplot2)
library(dplyr)
require(gridExtra)

kruskal.test(power_mW ~ freq_GHz, data=df3[df3$wifi_bt == FALSE & df3$freq_GHz > 0.6,])
kruskal.test(power_mW ~ freq_GHz, data=df4[df4$wifi_bt == FALSE & df4$freq_GHz > 0.6,])
kruskal.test(power_mW ~ freq_GHz, data=df5[df5$wifi_bt == FALSE & df5$freq_GHz > 0.6,])

create_power_lineplot <- function(df, title) {
  freqs <- seq(min(df$freq_GHz), max(df$freq_GHz), 0.1)
  df %>%
    group_by(freq_GHz, wifi_bt) %>%
    summarize(m = mean(power_mW)) %>%
    ggplot(aes(color = wifi_bt, x = freq_GHz, y = m)) +
    geom_line(show.legend = FALSE) +
    geom_point(show.legend = FALSE) +
    scale_x_continuous("CPU clock frequency (GHz)", labels = as.character(freqs), breaks = freqs) +
    guides(color = guide_legend(title="WiFi and Bluetooth enabled")) +
    labs(y = "Mean power consumption (mW)") +
    ggtitle(title)
}

create_power_boxplot <- function(df, title) {
  ggplot(df, aes(x = factor(freq_GHz), y = power_mW, color = factor(wifi_bt))) +
    geom_boxplot() +
    guides(fill = guide_legend(title="WiFi and Bluetooth enabled"), color = guide_legend(title="WiFi and Bluetooth enabled")) +
    stat_summary(fun.y=mean, geom="point", shape=20, size=3, color="black",
             position = position_dodge2(width = 0.75, preserve = "single")) +
    labs(x = "CPU clock frequency (GHz)", y = "Power consumption (mW)", title = title)
}

create_power_histogram <- function(df, wifi_bt, title) {
  df[df$wifi_bt == wifi_bt,] %>%
    ggplot(aes(x = power_mW, color=freq_GHz)) +
    geom_histogram()
}

png("idle_freq_graphs.png", width = 800, height = 800)
grid.arrange(create_power_lineplot(df3, "RPi 3B+"),
             create_power_lineplot(df4, "RPi 4B"),
             create_power_lineplot(df5, "RPi 5"),
             nrow = 3)
dev.off()

png("idle_freq_boxes.png", width = 800, height = 800)
grid.arrange(create_power_boxplot(df3, "RPi 3B+"),
             create_power_boxplot(df4, "RPi 4B"),
             create_power_boxplot(df5, "RPi 5"),
             nrow = 3)
dev.off()