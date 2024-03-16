phases <- c("start", "wifi", "bt", "hdmi", "pcie", "uart", "cpu", "usb", "eth")
phases3 <- phases[-9]
phases4 <- phases[-8]
phases5 <- phases[-8]

setwd("./measurement_data")
measurements3 <- lapply(lapply(phases3, function(x) paste("rpi3-", x, ".csv", sep = "")), read.csv)
measurements4 <- lapply(lapply(phases4, function(x) paste("rpi4-", x, ".csv", sep = "")), read.csv)
measurements5 <- lapply(lapply(phases5, function(x) paste("rpi5-", x, ".csv", sep = "")), read.csv)
setwd("..")

names(measurements3) <- phases3
names(measurements4) <- phases4
names(measurements5) <- phases5

measure_changes <- function(measurements, phases) {
  prev <- "start"
  for (x in phases) {
    print(x)
    print(mean(measurements[[x]]$power_mW))
    print(sd(measurements[[x]]$power_mW))
    print( (mean(measurements[[x]]$power_mW) / mean(measurements[[prev]]$power_mW) - 1) * 100 )
    print(t.test(measurements[[x]]$power_mW, measurements[[prev]]$power_mW), conf.level = 0.95)
    prev <- x
  }
}

testi <- read.csv("../../testi_pcie.csv")
prev <- "hdmi"
x <- "pcie"
print(mean(testi$power_mW))
print(sd(testi$power_mW))
print( (mean(testi$power_mW) / mean(measurements4[[prev]]$power_mW) - 1) * 100 )
print(t.test(testi$power_mW, measurements4[[prev]]$power_mW), conf.level = 0.95)


# RPi 3B+
measure_changes(measurements3, phases3)
# RPi 4B
measure_changes(measurements4, phases4)
# RPi 5
measure_changes(measurements5, phases5)


create_df <- function(measurements, phases) {
  df <- measurements[["start"]]
  df$vaihe <- rep("start", times = length(nrow(measurements[["start"]])))
  df$i <- c(1:nrow(df))
  for (x in phases[-1]) {
    p <- measurements[[x]]
    p$vaihe <- rep(x, times = length(nrow(p)))
    p$i <- c(1:nrow(p))
    df <- rbind(df, p)
  }
  df
}

df3 <- create_df(measurements3, phases3)
df3$laite <- rep("RPi 3B+", times = length(nrow(df3)))
df4 <- create_df(measurements4, phases4)
df4$laite <- rep("RPi 4B", times = length(nrow(df4)))
df5 <- create_df(measurements5, phases5)
df5$laite <- rep("RPi 5", times = length(nrow(df5)))
df <- rbind(df3, df4, df5)

library(ggplot2)
library(dplyr)
require(gridExtra)

p1 <- df %>%
  group_by(laite, vaihe) %>%
  summarize(m = mean(power_mW)) %>%
  ggplot(aes(fill = laite, x = vaihe, y = m)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_x_discrete(limits = phases) +
  labs(x = "Vaihe", y = "Tehon keskiarvo (mW)")

p1

p2 <- df %>%
  group_by(laite, vaihe) %>%
  ggplot(aes(color = laite, fill = laite, x = vaihe, y = power_mW)) +
  geom_boxplot() +
  scale_x_discrete(limits = phases) +
  labs(x = "Vaihe", y = "Teho (mW)")

p2

png("devices.png", width = 800, height = 800)
grid.arrange(p1, p2, nrow = 2)
dev.off()
