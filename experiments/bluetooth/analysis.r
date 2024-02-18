setwd("./measurement_data")

phase1 <- lapply(list.files(pattern = "1s_*"), read.csv)
phase2 <- lapply(list.files(pattern = "5s_*"), read.csv)
phase3 <- lapply(list.files(pattern = "10s_*"), read.csv)

setwd("..")

energy_scaled <- function(x) (tail(x$acc_energy_mWh, 1) - x$acc_energy_mWh[[1]]) * (30 / tail(x$time_since_start_s, 1))

p1_energy <- sapply(phase1, energy_scaled)
p2_energy <- sapply(phase2, energy_scaled)
p3_energy <- sapply(phase3, energy_scaled)

p1_mean <- mean(p1_energy)
p2_mean <- mean(p2_energy)
p3_mean <- mean(p3_energy)

png("average_energy_and_poll_frequency.png")

par(mfrow=c(1,2))
barplot(c(p1_mean, p2_mean, p3_mean),
  ylab = "Energiankulutuksen keskiarvo (mWh)",
  xlab = "Kyselytiheys (s)",
  names.arg = c("1", "5", "10")
)
boxplot(data.frame("1" = p1_energy,
                   "5" = p2_energy,
                   "10" = p3_energy,
                   check.names = FALSE),
        ylab = "Energiankulutus (mWh)",
        xlab = "Kyselytiheys (s)")

dev.off()
