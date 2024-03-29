measurements3 <- read.csv("./measurement_data/rpi3-experiment2.csv")
phase_times3 <- read.csv("./measurement_data/rpi3-experiment2-phase-times.csv")
measurements4 <- read.csv("./measurement_data/rpi4-experiment2.csv")
phase_times4 <- read.csv("./measurement_data/rpi4-experiment2-phase-times.csv")
measurements5 <- read.csv("./measurement_data/rpi5-experiment2.csv")
phase_times5 <- read.csv("./measurement_data/rpi5-experiment2-phase-times.csv")

phases <- unique(phase_times3$phase)
names(phases) <- c("All enabled", "Nothing enabled", "CPU", "UART", "PCIE", "HDMI", "BT", "WiFi", "ETH", "USB")

create_df <- function(measurements, phase_times) {
  measurements$phase <- rep(NA, times = nrow(measurements))
  phases <- unique(phase_times$phase)
  for (x in phases) {
    start_time <- min(phase_times[phase_times$phase == x,]$time_s)
    end_time <- max(phase_times[phase_times$phase == x,]$time_s)
    m <- measurements[measurements$time_s >= start_time & measurements$time_s <= end_time,]
    measurements[measurements$time_s >= start_time & measurements$time_s <= end_time,]$phase <- rep(x, times = nrow(m))
  }
  measurements[complete.cases(measurements),]
}

library(ggplot2)
library(dplyr)
require(gridExtra)

df3 <- create_df(measurements3, phase_times3)
df3$device <- rep("RPi 3B+", times = length(nrow(df3)))
df4 <- create_df(measurements4, phase_times4)
df4$device <- rep("RPi 4B", times = length(nrow(df4)))
df5 <- create_df(measurements5, phase_times5)
df5$device <- rep("RPi 5", times = length(nrow(df5)))

df <- rbind(df3, df4, df5)

compare_to_all_disabled <- function(df) {
  ps <- unique(df$phase)
  for (x in ps) {
    print(x)
    print(mean(df[df$phase == x,]$power_mW))
    print( (mean(df[df$phase == x,]$power_mW) / mean(df[df$phase == "all",]$power_mW) - 1) * 100 )
    print(t.test(df[df$phase == x,]$power_mW, df[df$phase == "all",]$power_mW), conf.level = 0.95)
  }
}

compare_to_all_disabled(df3)
compare_to_all_disabled(df4)
compare_to_all_disabled(df5)

# How much does enabling WiFi increase the mean standard deviation?
(sd(df3[df3$phase == "wifi",]$power_mW) / sd(df3[df3$phase == "all",]$power_mW) - 1)*100
(sd(df4[df3$phase == "wifi",]$power_mW) / sd(df4[df4$phase == "all",]$power_mW) - 1)*100
(sd(df5[df3$phase == "wifi",]$power_mW) / sd(df5[df5$phase == "all",]$power_mW) - 1)*100


p1 <- df %>%
  group_by(device, phase) %>%
  summarize(m = mean(power_mW)) %>%
  ggplot(aes(fill = device, x = phase, y = m)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_x_discrete(limits = phases, labels = names(phases)) +
  geom_text(aes(label = round(m, 2)), colour = "black", angle = 90, hjust = 1.5, position = position_dodge(width = .9)) +
  guides(fill = guide_legend(title = "Device")) +
  labs(x = "Enabled feature", y = "Mean power consumption (mW)")

p1

p2 <- df %>%
  group_by(device, phase) %>%
  ggplot(aes(color = device, fill = device, x = phase, y = power_mW)) +
  geom_boxplot() +
  scale_x_discrete(limits = phases, labels = names(phases)) +
  guides(fill = guide_legend(title = "Device"), color = guide_legend(title = "Device")) +
  labs(x = "Enabled feature", y = "Power consumption (mW)")

p2

png("devices.png", width = 800, height = 800)
grid.arrange(p1, p2, nrow = 2)
dev.off()
