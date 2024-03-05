setwd("./measurement_data")
cols <- c("time_s",
          "voltage_mV",
          "current_mA",
          "power_mW",
          "acc_energy_mWh",
          "i",
          "freq_GHz")

df4 <- data.frame(matrix(ncol = length(cols), nrow = 0)) # RPi 4B
df5 <- data.frame(matrix(ncol = length(cols), nrow = 0)) # RPi 5
colnames(df4) <- cols
colnames(df5) <- cols
freqs4 <- c(6:18) # RPi 4B
freqs5 <- c(15:24) # RPi 5
# RPi 4B measurements
for (f in freqs4) {
  filename <- paste("rpi4-idle-freq-", f, "00000.csv", sep="")
  d <- read.csv(filename)
  d$i <- c(1:nrow(d))
  d$freq_GHz <- rep(f/10, times = nrow(d))
  df4 <- rbind(df4, d)
}
# RPi 5 measurements
for (f in freqs5) {
  filename <- paste("rpi5-idle-freq-", f, "00000.csv", sep="")
  d <- read.csv(filename)
  d$i <- c(1:nrow(d))
  d$freq_GHz <- rep(f/10, times = nrow(d))
  df5 <- rbind(df5, d)
}
setwd("..")

library(ggplot2)
library(dplyr)
require(gridExtra)

p1 <- df5 %>%
  group_by(freq_GHz) %>%
  summarize(m = mean(power_mW)) %>%
  ggplot(aes(x = freq_GHz, y = m)) +
  geom_line() +
  geom_point() +
  labs(x = "Kellotaajuus (GHz)", y = "Tehon keskiarvo (mW)") +
  ggtitle("RPi 5")

p1

p2 <- df4 %>%
  group_by(freq_GHz) %>%
  summarize(m = mean(power_mW)) %>%
  ggplot(aes(x = freq_GHz, y = m)) +
  geom_line() +
  geom_point() +
  labs(x = "Kellotaajuus (GHz)", y = "Tehon keskiarvo (mW)") +
  ggtitle("RPi 4B")

p2

p3 <- df5 %>% 
  group_by(freq_GHz) %>% 
  ggplot(aes(x = freq_GHz, y = power_mW, group = freq_GHz)) +
  geom_boxplot() +
  labs(x = "Kellotaajuus (GHz)", y = "Teho (mW)", fill = "Taajuus (GHz)") +
  ggtitle("RPi 5")

p3

p4 <- df4 %>% 
  group_by(freq_GHz) %>% 
  ggplot(aes(x = freq_GHz, y = power_mW, group = freq_GHz)) +
  geom_boxplot() +
  labs(x = "Kellotaajuus (GHz)", y = "Teho (mW)", fill = "Taajuus (GHz)") +
  ggtitle("RPi 4B")

p4

png("idle_freq_graphs.png")
grid.arrange(p1, p2, p3, p4, nrow = 2)
dev.off()

for (f in freqs4) {
  print(f)
  print(summary(df4[df4$freq_GHz == f/10,]$power_mW))
}

for (f in freqs5) {
  print(f)
  print(summary(df5[df5$freq_GHz == f/10,]$power_mW))
}

# Linear regression
y4 <- lm(formula = power_mW ~ freq_GHz, data = df4)
summary(y4)

y5 <- lm(formula = power_mW ~ freq_GHz, data = df5)
summary(y5)