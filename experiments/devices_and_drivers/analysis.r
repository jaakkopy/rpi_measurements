file_prefix <- c("start", "no_wifi", "no_usb", "no_hdmi", "no_eth", "no_bt", "disabled_cpus", "all")
file_prefix5 <- lapply(file_prefix[-3], function(x) paste("rpi5-", x, sep = "")) 
phases <- c("Alku", "WiFi", "USB", "HDMI", "ETH", "BT", "CPU", "Kaikki")
phases5 <- phases[-3] 

measurements4 <- lapply(file_prefix, function(x) read.csv(paste("./measurement_data/", x, ".csv", sep = "")))
measurements5 <- lapply(file_prefix5, function(x) read.csv(paste("./measurement_data/", x, ".csv", sep = "")))

names(measurements4) <- phases
names(measurements5) <- phases5

# RPi 4
for (x in phases) {
  print(x)
  print(mean(measurements4[[x]]$power_mW))
  print( (mean(measurements4[[x]]$power_mW) / mean(measurements4[["Alku"]]$power_mW) - 1) * 100 )
  print(t.test(measurements4[[x]]$power_mW, measurements4[["Alku"]]$power_mW))
}
# RPi 5
for (x in phases5) {
  print(x)
  print(mean(measurements5[[x]]$power_mW))
  print( (mean(measurements5[[x]]$power_mW) / mean(measurements5[["Alku"]]$power_mW) - 1) * 100 )
  print(t.test(measurements5[[x]]$power_mW, measurements5[["Alku"]]$power_mW))
}

df4 <- measurements4[["Alku"]]
df4$vaihe <- rep("Alku", times = length(nrow(measurements4[["Alku"]])))
df4$i <- c(1:nrow(df4))
for (x in phases[-1]) {
  p <- measurements4[[x]]
  p$vaihe <- rep(x, times = length(nrow(p)))
  p$i <- c(1:nrow(p))
  df4 <- rbind(df4, p)
}

df5 <- measurements5[["Alku"]]
df5$vaihe <- rep("Alku", times = length(nrow(measurements5[["Alku"]])))
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


ordered_by_power4 <- lapply(phases, function(x) mean(df4[df4$vaihe == x,]$power_mW))
names(ordered_by_power4) <- phases
ordered_by_power4 <- ordered_by_power4[order(unlist(ordered_by_power4))]

ordered_by_power5 <- lapply(phases5, function(x) mean(df5[df5$vaihe == x,]$power_mW))
names(ordered_by_power5) <- phases5
ordered_by_power5 <- ordered_by_power5[order(unlist(ordered_by_power5))]

p1 <- ggplot(data = df4, aes(x = vaihe, y = power_mW)) +
  geom_boxplot() +
  scale_x_discrete(limits = names(ordered_by_power4)) +
  labs(x = "Vaihe (RPi 4B)", y = "Teho (mW)") +
  ggtitle("RPi 4B")

p1

p2 <- df4 %>% 
  group_by(vaihe) %>%
  summarize(m = mean(power_mW)) %>%
  ggplot(aes(x = vaihe, y = m)) +
  geom_bar(stat = "identity") +
  scale_x_discrete(limits = names(ordered_by_power4)) +
  labs(x = "Vaihe (RPi 4B)", y = "Tehon keskiarvo (mW)") +
  ggtitle("RPi 4B")

p2

p3 <- ggplot(data = df5, aes(x = vaihe, y = power_mW)) +
  geom_boxplot() +
  scale_x_discrete(limits = names(ordered_by_power5)) +
  scale_color_viridis_d() +
  labs(x = "Vaihe (RPi 5)", y = "Teho (mW)") +
  ggtitle("RPi 5")

p3

p4 <- df5 %>% 
  group_by(vaihe) %>%
  summarize(m = mean(power_mW)) %>%
  ggplot(aes(x = vaihe, y = m)) +
  geom_bar(stat = "identity") +
  scale_x_discrete(limits = names(ordered_by_power5)) +
  labs(x = "Vaihe (RPi 5)", y = "Tehon keskiarvo (mW)") +
  ggtitle("RPi 5")

p4

png("devices_graphs.png")
grid.arrange(p3, p1, p4, p2, nrow=2)
dev.off()
