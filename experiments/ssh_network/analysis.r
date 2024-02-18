setwd("./measurement_data")

phase1_measurement <- lapply(list.files(pattern = "phase1_*"), read.csv)
phase2_measurement <- lapply(list.files(pattern = "phase2_*"), read.csv)

# Subtract the first energy reading from the rest
# to get the energy consumption during the test
total_energy <- function(x) {
  x$acc_energy_mWh <- x$acc_energy_mWh - x$acc_energy_mWh[[1]]
  x
}

energy_scaled <- function(x) {
  l <- tail(x, 1)
  # measurement time was aimed to be 15s
  l$acc_energy_mWh * (15 / l$time_since_start_s)
}

phase1_measurement <- lapply(phase1_measurement, total_energy)
phase2_measurement <- lapply(phase2_measurement, total_energy)

p1_energy <- sapply(phase1_measurement, energy_scaled)
p1_energy_mean <- mean(p1_energy)

p2_energy <- sapply(phase2_measurement, energy_scaled)
p2_energy_mean <- mean(p2_energy)

# T-test for equal means for the populations
t.test(p1_energy, p2_energy, conf.level = 0.95)

setwd("../bandwidth_data")

phase1_bandwidth <- lapply(list.files(pattern = "phase1_*"), read.csv)
phase2_bandwidth <- lapply(list.files(pattern = "phase2_*"), read.csv)

p1_transmit_means <- sapply(phase1_bandwidth, function(x) mean(x$transmit_bandwidth_bytes_per_s))
p2_transmit_means <- sapply(phase2_bandwidth, function(x) mean(x$transmit_bandwidth_bytes_per_s))

setwd("..")

png(filename = "average_energy_ssh.png")

layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
barplot(
  c(p1_energy_mean, p2_energy_mean),
  names.arg = c("SSH ja tuloste", "SSH ilman tulostetta"),
  xlab = "Koevaihe",
  ylab = "Energiankulutuksen keskiarvo (mWh)"
)

boxplot(p1_transmit_means, xlab = "SSH ja tuloste", ylab = "Kaistanleveyden keskiarvo per koe (Bps)")
boxplot(p2_transmit_means, xlab = "SSH ilman tulostetta", ylab = "Kaistanleveyden keskiarvo per koe (Bps)")

dev.off()
