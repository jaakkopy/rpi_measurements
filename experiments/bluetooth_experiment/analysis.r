setwd("./measurement_data")

phase1 <- lapply(list.files(pattern = "1s_*"), read.csv)
phase2 <- lapply(list.files(pattern = "5s_*"), read.csv)
phase3 <- lapply(list.files(pattern = "10s_*"), read.csv)

setwd("..")

energy_per_s <- function(x) (tail(x$acc_energy_mWh, 1) - x$acc_energy_mWh[[1]]) / tail(x$time_since_start_s, 1)

p1_energy_per_s <- sapply(phase1, energy_per_s)
p2_energy_per_s <- sapply(phase2, energy_per_s)
p3_energy_per_s <- sapply(phase3, energy_per_s)

p1_mean <- mean(p1_energy_per_s)
p2_mean <- mean(p2_energy_per_s)
p3_mean <- mean(p3_energy_per_s)

png("average_energy_and_poll_frequency.png")

par(mfrow=c(1,2))
barplot(c(p1_mean, p2_mean, p3_mean),
  ylab = "Energiankulutuksen keskiarvo (mWh/s)",
  xlab = "Kyselytiheys (s)",
  names.arg = c("1", "5", "10")
)
boxplot(data.frame("1" = p1_energy_per_s,
                   "5" = p2_energy_per_s,
                   "10" = p3_energy_per_s,
                   check.names = FALSE),
        ylab = "Energiankulutus (mWh/s)",
        xlab = "Kyselytiheys (s)")

dev.off()
