setwd("./measurement_data")
cols <- c("time_s",
          "voltage_mV",
          "current_mA",
          "power_mW",
          "acc_energy_mWh",
          "i",
          "freq_MHz")

df <- data.frame(matrix(ncol = length(cols), nrow = 0))
colnames(df) <- cols
freqs <- c(6:18)
for (f in freqs) {
  filename <- paste("idle-freq-", f, "00000.csv", sep="")
  d <- read.csv(filename)
  d$i <- c(1:nrow(d))
  d$freq_MHz <- rep(f/10, times = nrow(d))
  df <- rbind(df, d)
}
setwd("..")

library(ggplot2)
library(dplyr)
require(gridExtra)

p1 <- df %>%
  group_by(freq_MHz) %>%
  summarize(m = mean(power_mW)) %>%
  ggplot(aes(x = freq_MHz, y = m)) +
  geom_line() +
  geom_point() +
  labs(x = "Kellotaajuus (MHz)", y = "Tehon keskiarvo (mW)")

p1

p2 <- df %>% 
  group_by(freq_MHz) %>% 
  ggplot(aes(x = freq_MHz, y = power_mW, group = freq_MHz, fill = freq_MHz)) +
  geom_boxplot() +
  labs(x = "Kellotaajuus (MHz)", y = "Teho (mW)", fill = "Taajuus (MHz)")

p2

png("idle_freq_graphs.png")
grid.arrange(p1, p2, nrow = 2)
dev.off()

for (f in freqs) {
  print(f)
  print(summary(df[df$freq_MHz == f/10,]$power_mW))
}

kruskal.test(lapply(freqs, function(f) df[df$freq_MHz == f/10,]$power_mW))
