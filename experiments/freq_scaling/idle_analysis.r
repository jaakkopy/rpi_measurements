setwd("./measurement_data")
cols <- c("time_s",
          "voltage_mV",
          "current_mA",
          "power_mW",
          "acc_energy_mWh",
          "i",
          "freq_GHz")


create_df <- function(filename_prefix, freqs) {
  df <- data.frame(matrix(ncol = length(cols), nrow = 0))
  colnames(df) <- cols
  for (f in freqs) {
    filename <- paste(filename_prefix, f, "00000.csv", sep="")
    d <- read.csv(filename)
    d$i <- c(1:nrow(d))
    d$freq_GHz <- rep(f/10, times = nrow(d))
    df <- rbind(df, d)
  }
  df
}

freqs4 <- c(6:18)
df4 <- create_df("rpi4-idle-freq-", freqs4)

freqs5 <- c(15:24)
df5 <- create_df("rpi5-idle-freq-", freqs5)

setwd("..")

library(ggplot2)
library(dplyr)
require(gridExtra)


create_lineplot <- function(df, title) {
  df %>%
    group_by(freq_GHz) %>%
    summarize(m = mean(power_mW)) %>%
    ggplot(aes(x = freq_GHz, y = m)) +
    geom_line() +
    geom_point() +
    labs(x = "Kellotaajuus (GHz)", y = "Tehon keskiarvo (mW)") +
    ggtitle(title)
}

create_boxplot <- function(df, title) {
  df %>% 
    group_by(freq_GHz) %>% 
    ggplot(aes(x = freq_GHz, y = power_mW, group = freq_GHz)) +
    geom_boxplot() +
    labs(x = "Kellotaajuus (GHz)", y = "Teho (mW)", fill = "Taajuus (GHz)") +
    ggtitle(title)
}

p1 <- create_lineplot(df4, "RPi 4B")
p1

p2 <- create_boxplot(df4, "RPi 4B")
p2

p3 <- create_lineplot(df5, "RPi 5")
p3

p4 <- create_boxplot(df5, "RPi 5")
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