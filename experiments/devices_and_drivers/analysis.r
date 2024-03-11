phases <- c("start", "wifi", "bt",  "cron", "ModemManager", "systemd-timesyncd", "triggerhappy", "hdmi", "pcie", "uart", "random", "cpu", "usb", "eth")
phases5 <- phases[-13]

setwd("./measurement_data")
measurements4 <- lapply(lapply(phases, function(x) paste("rpi4-", x, ".csv", sep = "")), read.csv)
measurements5 <- lapply(lapply(phases5, function(x) paste("rpi5-", x, ".csv", sep = "")), read.csv)
setwd("..")

names(measurements4) <- phases
names(measurements5) <- phases5

# RPi 4
prev <- "start"
for (x in phases) {
  print(x)
  print(mean(measurements4[[x]]$power_mW))
  print(sd(measurements4[[x]]$power_mW))
  print( (mean(measurements4[[x]]$power_mW) / mean(measurements4[[prev]]$power_mW) - 1) * 100 )
  print(t.test(measurements4[[x]]$power_mW, measurements4[[prev]]$power_mW), conf.level = 0.95)
  prev <- x
}

# RPi 5
prev <- "start"
for (x in phases5) {
  print(x)
  print(mean(measurements5[[x]]$power_mW))
  print(sd(measurements5[[x]]$power_mW))
  print( (mean(measurements5[[x]]$power_mW) / mean(measurements5[[prev]]$power_mW) - 1) * 100 )
  print(t.test(measurements5[[x]]$power_mW, measurements5[[prev]]$power_mW), conf.level = 0.95)
  prev <- x
}

df4 <- measurements4[["start"]]
df4$vaihe <- rep("start", times = length(nrow(measurements4[["start"]])))
df4$i <- c(1:nrow(df4))
for (x in phases[-1]) {
  p <- measurements4[[x]]
  p$vaihe <- rep(x, times = length(nrow(p)))
  p$i <- c(1:nrow(p))
  df4 <- rbind(df4, p)
}

df5 <- measurements5[["start"]]
df5$vaihe <- rep("start", times = length(nrow(measurements5[["start"]])))
df5$i <- c(1:nrow(df5))
for (x in phases5[-1]) {
  p <- measurements5[[x]]
  p$vaihe <- rep(x, times = length(nrow(p)))
  p$i <- c(1:nrow(p))
  df5 <- rbind(df5, p)
}

library(ggplot2)
library(dplyr)
require(gridExtra)

p1 <- ggplot(data = df4, aes(x = vaihe, y = power_mW)) +
  geom_boxplot() +
  scale_x_discrete(limits = phases, guide = guide_axis(n.dodge=3)) +
  labs(x = "Vaihe (RPi 4B)", y = "Teho (mW)") +
  ggtitle("RPi 4B")

p1

p2 <- df4 %>% 
  group_by(vaihe) %>%
  summarize(m = mean(power_mW)) %>%
  ggplot(aes(x = vaihe, y = m)) +
  geom_bar(stat = "identity") +
  scale_x_discrete(limits = phases, guide = guide_axis(n.dodge=3)) +
  labs(x = "Vaihe (RPi 4B)", y = "Tehon keskiarvo (mW)") +
  ggtitle("RPi 4B")

p2

p3 <- ggplot(data = df5, aes(x = vaihe, y = power_mW)) +
  geom_boxplot() +
  scale_x_discrete(limits = phases5, guide = guide_axis(n.dodge=3)) +
  labs(x = "Vaihe (RPi 5)", y = "Teho (mW)") +
  ggtitle("RPi 5")

p3

p4 <- df5 %>% 
  group_by(vaihe) %>%
  summarize(m = mean(power_mW)) %>%
  ggplot(aes(x = vaihe, y = m)) +
  geom_bar(stat = "identity") +
  scale_x_discrete(limits = phases5, guide = guide_axis(n.dodge=3)) +
  labs(x = "Vaihe (RPi 5)", y = "Tehon keskiarvo (mW)") +
  ggtitle("RPi 5")

p4

png("devices.png", width = 800, height = 800)
grid.arrange(p1, p2, p3, p4, nrow=2)
dev.off()