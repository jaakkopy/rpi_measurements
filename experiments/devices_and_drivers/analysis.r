file_prefix <- c("start", "no_wifi", "no_usb", "no_hdmi", "no_eth", "no_bt", "disabled_cpus", "all")
phases <- c("Alku", "WiFi", "USB", "HDMI", "ETH", "BT", "CPU", "Kaikki")

measurements <- lapply(file_prefix, function(x) read.csv(paste("./measurement_data/", x, ".csv", sep = "")))

names(measurements) <- phases

for (x in phases) {
  print(x)
  print(mean(measurements[[x]]$power_mW))
  print( (mean(measurements[[x]]$power_mW) / mean(measurements[["Alku"]]$power_mW) - 1) * 100 )
  print(t.test(measurements[[x]]$power_mW, measurements[["Alku"]]$power_mW))
}

df <- measurements[["Alku"]]
df$vaihe <- rep("Alku", times = length(nrow(start)))
df$i <- c(1:nrow(df))
for (x in phases[c(2:length(phases))]) {
  p <- measurements[[x]]
  p$vaihe <- rep(x, times = length(nrow(p)))
  p$i <- c(1:nrow(p))
  df <- rbind(df, p)
}


library(ggplot2)
library(dplyr)
require(gridExtra)

p1 <- ggplot(data = df, aes(x = i, y = power_mW, colour = vaihe)) +
  geom_point() +
  labs(x = "Mittaus", y = "Teho (mW)")

p1

ordered_by_power <- lapply(phases, function(x) mean(df[df$vaihe == x,]$power_mW))
names(ordered_by_power) <- phases
ordered_by_power <- ordered_by_power[order(unlist(ordered_by_power))]

p2 <- df %>% 
  group_by(vaihe) %>%
  summarize(m = mean(power_mW)) %>%
  ggplot(aes(x = vaihe, y = m)) +
  geom_bar(stat = "identity") +
  scale_x_discrete(limits = names(ordered_by_power)) +
  labs(x = "Vaihe", y = "Tehon keskiarvo (mW)")

p2

png("devices_graphs.png")
grid.arrange(p1, p2, ncol=2)
dev.off()
