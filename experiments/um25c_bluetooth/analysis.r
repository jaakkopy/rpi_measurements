setwd("./measurement_data")
phase1 <- lapply(list.files(pattern = "^1s_*"), read.csv)
phase2 <- lapply(list.files(pattern = "^5s_*"), read.csv)
phase3 <- lapply(list.files(pattern = "^10s_*"), read.csv)
phase4 <- lapply(list.files(pattern = "^15s_*"), read.csv)
setwd("..")

energy_scaled <- function(x) (max(x$acc_energy_mWh) - min(x$acc_energy_mWh)) * (30 / (max(x$time_s) - min(x$time_s)))

p1_energy <- sapply(phase1, energy_scaled)
p2_energy <- sapply(phase2, energy_scaled)
p3_energy <- sapply(phase3, energy_scaled)
p4_energy <- sapply(phase4, energy_scaled)

# Eyeball for normalcy
par(mfrow=c(1,4))
hist(p1_energy)
hist(p2_energy)
hist(p3_energy)
hist(p4_energy)

par(mfrow=c(1,4))
qqnorm(p1_energy)
qqline(p1_energy)
qqnorm(p2_energy)
qqline(p2_energy)
qqnorm(p3_energy)
qqline(p3_energy)
qqnorm(p4_energy)
qqline(p4_energy)

# Shapiro-Wilk test
shapiro.test(p1_energy)
shapiro.test(p2_energy)
shapiro.test(p3_energy)
shapiro.test(p4_energy)

# Kruskal-Wallis
kruskal.test(p1_energy, p2_energy, p3_energy, p4_energy)

# ANOVA
d1 <- data.frame("energy" = p1_energy, "sec" = rep("1s", length(p1_energy)))
d2 <- data.frame("energy" = p2_energy, "sec" = rep("5s", length(p2_energy)))
d3 <- data.frame("energy" = p3_energy, "sec" = rep("10s", length(p3_energy)))
d4 <- data.frame("energy" = p4_energy, "sec" = rep("15s", length(p4_energy)))
d <- rbind(d1, d2, d3, d4)
a <- aov(energy ~ sec, d)
summary(a)

# Summary
summary(p1_energy)
summary(p2_energy)
summary(p3_energy)
summary(p4_energy)

means <- data.frame("mean" = c(mean(p1_energy), mean(p2_energy), mean(p3_energy), mean(p4_energy)),
                    "time" = c("1s", "5s", "10s", "15s"))

library(ggplot2)
library(dplyr)
require(gridExtra)

make_hist <- function(energy_consumed, title) {
  data.frame(val = energy_consumed) %>%
    ggplot(., aes(val)) +
    geom_histogram(bins = 10, color="black", fill="white") +
    labs(x = "Energiankulutus (mWh) 30 s ajanjaksolta", y = "Frekvenssi") +
    ggtitle(title)
}

p1 <- make_hist(p1_energy, "Odotusaika 1 s")
p2 <- make_hist(p2_energy, "Odotusaika 5 s")
p3 <- make_hist(p3_energy, "Odotusaika 10 s")
p4 <- make_hist(p4_energy, "Odotusaika 15 s")

png("average_energy_and_poll_frequency.png", width = 400, height = 400)
grid.arrange(p1, p2, p3, p4)
dev.off()