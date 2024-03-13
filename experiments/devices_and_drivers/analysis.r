phases4 <- c("start", "wifi", "bt",  "hdmi", "pcie", "uart", "random", "cpu", "usb", "eth")
phases3 <- phases[-10]
phases5 <- phases[-9]

setwd("./measurement_data")
measurements3 <- lapply(lapply(phases, function(x) paste("rpi3-", x, ".csv", sep = "")), read.csv)
measurements4 <- lapply(lapply(phases, function(x) paste("rpi4-", x, ".csv", sep = "")), read.csv)
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
df4 <- create_df(measurements4, phases4)
df5 <- create_df(measurements5, phases5)


library(ggplot2)
library(dplyr)
require(gridExtra)

# TODO: Stacked barchart to save space in the graph
# https://r-graph-gallery.com/48-grouped-barplot-with-ggplot2


make_boxplot <- function(df, title, scale) {
  ggplot(data = df, aes(x = vaihe, y = power_mW)) +
    geom_boxplot() +
    scale_x_discrete(limits = scale, guide = guide_axis(n.dodge=3)) +
    labs(x = title, y = "Teho (mW)") +
    ggtitle("RPi 3B+")
}

make_barplot <- function(df, title, scale) {
  df %>% 
    group_by(vaihe) %>%
    summarize(m = mean(power_mW)) %>%
    ggplot(aes(x = vaihe, y = m)) +
    geom_bar(stat = "identity") +
    scale_x_discrete(limits = scale, guide = guide_axis(n.dodge=3)) +
    labs(x = title, y = "Tehon keskiarvo (mW)") +
    ggtitle(title)
}

p1 <- make_boxplot(df3, "RPi 3B+", phases3)
p1

p2 <- make_barplot(df3, "RPi 3B+", phases3)
p2

p3 <- make_boxplot(df4, "RPi 4B", phases4)
p3

p4 <- make_barplot(df4, "RPi 4B", phases4)
p4

p5 <- make_boxplot(df4, "RPi 5", phases5)
p5

p6 <- make_barplot(df4, "RPi 5", phases5)
p6

png("devices.png", width = 800, height = 800)
grid.arrange(p1, p2, p3, p4, nrow=2)
dev.off()

# Comparison with Ethernet, WiFi and Bluetooth off
ewb5 <- read.csv("./measurement_data/rpi5-wifi-bt-eth.csv")
print(mean(ewb5$power_mW))
print(sd(ewb5$power_mW))
print( (mean(ewb5$power_mW) / mean(measurements5[["start"]]$power_mW) - 1) * 100 )


ewb4 <- read.csv("./measurement_data/rpi4-wifi-bt-eth.csv")
print(mean(ewb4$power_mW))
print(sd(ewb4$power_mW))
print( (mean(ewb4$power_mW) / mean(measurements4[["start"]]$power_mW) - 1) * 100 )
