phase1 <- read.csv("./measurement_data/with_print.csv")
phase2 <- read.csv("./measurement_data/without_print.csv")

phase1_bandwidth <- read.csv("./bandwidth_data/with_print.csv")
phase2_bandwidth <- read.csv("./bandwidth_data/without_print.csv")


# T-test for equal means for the current consumption populations
t.test(phase1$power_mW, phase2$power_mW, conf.level = 0.95)

summary(phase1$power_mW)
summary(phase2$power_mW)

print(mean(phase1$power_mW) / mean(phase2$power_mW))

sd(phase1$power_mW)
sd(phase2$power_mW)

summary(phase1_bandwidth$transmit_bandwidth_bytes_per_s)
summary(phase2_bandwidth$transmit_bandwidth_bytes_per_s)

sd(phase1_bandwidth$transmit_bandwidth_bytes_per_s)
sd(phase2_bandwidth$transmit_bandwidth_bytes_per_s)

library(ggplot2)
require(gridExtra)

phase1$vaihe <- rep("1", times = length(phase1$time_since_start_s))
phase1$i <- c(1:length(phase1$time_since_start_s))
phase2$vaihe <- rep("2", times = length(phase2$time_since_start_s))
phase2$i <- c(1:length(phase2$time_since_start_s))
phases <- rbind(phase1, phase2)

phase1_bandwidth$vaihe <- rep("1", times = length(phase1_bandwidth$time_since_start_s))
phase2_bandwidth$vaihe <- rep("2", times = length(phase2_bandwidth$time_since_start_s))
band <- rbind(phase1_bandwidth, phase2_bandwidth)

p1 <- ggplot(data = phases, aes(x = i, y = power_mW, colour = vaihe)) +
  geom_point() +
  labs(x = "Mittaus", y = "Teho (mW)")

p1

p2 <- ggplot(data = phases, aes(x = vaihe, y = power_mW, colour = vaihe)) +
  geom_boxplot() +
  labs(x = "Vaihe", y = "Teho (mW)")

p2

p3 <- ggplot(data = band, aes(x = vaihe, y = transmit_bandwidth_bytes_per_s, colour = vaihe)) +
  geom_boxplot() +
  labs(x = "Vaihe", y = "Transmission kaistanleveys (Bps)")

p3

png("power_and_transmission_bw.png")
grid.arrange(p1, p2, p3, ncol=2)
dev.off()
