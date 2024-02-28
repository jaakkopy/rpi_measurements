setwd("./measurement_data")

phase1 <- read.csv("1s.csv")
phase2 <- read.csv("5s.csv")
phase3 <- read.csv("10s.csv")
phase4 <- read.csv("15s.csv")

setwd("..")

energy_scaled <- function(x) (tail(x$acc_energy_mWh, 1) - x$acc_energy_mWh[[1]]) * (1500 / tail(x$time_since_start_s, 1))

p1_energy <- energy_scaled(phase1)
p2_energy <- energy_scaled(phase2)
p3_energy <- energy_scaled(phase3)
p4_energy <- energy_scaled(phase4)

# Eyeball for normalcy
par(mfrow=c(1,4))
hist(phase1$current_mA)
hist(phase2$current_mA)
hist(phase3$current_mA)
hist(phase4$current_mA)

par(mfrow=c(1,4))
qqnorm(phase1$current_mA)
qqline(phase1$current_mA)
qqnorm(phase2$current_mA)
qqline(phase2$current_mA)
qqnorm(phase3$current_mA)
qqline(phase3$current_mA)
qqnorm(phase4$current_mA)
qqline(phase4$current_mA)

# Shapiro-Wilk test
shapiro.test(phase1$current_mA)
shapiro.test(phase2$current_mA)
shapiro.test(phase3$current_mA)
shapiro.test(phase4$current_mA)

# Kruskal-Wallis
kruskal.test(phase1$current_mA, phase2$current_mA, phase2$current_mA, phase4$current_mA)

# ANOVA
d1 <- data.frame("current" = phase1$current_mA, "sec" = rep(1, length(p1_energy)))
d2 <- data.frame("current" = phase2$current_mA, "sec" = rep(5, length(p2_energy)))
d3 <- data.frame("current" = phase3$current_mA, "sec" = rep(10, length(p3_energy)))
d4 <- data.frame("current" = phase4$current_mA, "sec" = rep(15, length(p4_energy)))
d <- rbind(d1, d2, d3, d4)
a <- aov(energy ~ sec, d)
summary(a)

# Summary
summary(p1_energy)
summary(p2_energy)
summary(p3_energy)
summary(p4_energy)

p1_mean <- mean(p1_energy)
p2_mean <- mean(p2_energy)
p3_mean <- mean(p3_energy)
p4_mean <- mean(p4_energy)

png("average_energy_and_poll_frequency.png")

par(mfrow=c(1,2))
barplot(c(p1_mean, p2_mean, p3_mean, p4_mean),
  ylab = "Energiankulutuksen keskiarvo (mWh)",
  xlab = "Kyselytiheys (s)",
  names.arg = c("1", "5", "10", "15"),
  ylim = c(0, max(p1_mean, p2_mean, p3_mean, p4_mean) + 1)
)
boxplot(data.frame("1" = p1_energy,
                   "5" = p2_energy,
                   "10" = p3_energy,
                   "15" = p4_energy,
                   check.names = FALSE),
        ylab = "Energiankulutus (mWh)",
        xlab = "Kyselytiheys (s)",
        c(0, max(p1_mean, p2_mean, p3_mean, p4_mean) + 1))

dev.off()
