setwd("./measurement_data")

phase1_measurement <- lapply(list.files(pattern = "phase1_*"), read.csv)
phase2_measurement <- lapply(list.files(pattern = "phase2_*"), read.csv)

# Subtract the first energy reading from the rest
# to get the energy consumption during the test
total_energy <- function(x) x$acc_energy_mWh <- x$acc_energy_mWh - x$acc_energy_mWh[[1]]

energy_per_s <- function(x) {
  l <- tail(x, 1)
  l$acc_energy_mWh / l$time_since_start_s
}

phase1_measurement <- lapply(phase1_measurement, total_energy)
phase2_measurement <- lapply(phase2_measurement, total_energy)

p1_energy_per_second <- sapply(phase1_measurement, energy_per_s)
p1_energy_per_s_mean <- mean(p1_energy_per_second)

p2_energy_per_second <- sapply(phase2_measurement, energy_per_s)
p2_energy_per_s_mean <- mean(p2_energy_per_second)

# T-test for equal means for the populations
t.test(p1_energy_per_second, p2_energy_per_second)

setwd("../bandwidth_data")

phase1_bandwidth <- lapply(list.files(pattern = "phase1_*"), read.csv)
phase2_bandwidth <- lapply(list.files(pattern = "phase2_*"), read.csv)

p1_transmit_means <- sapply(phase1_bandwidth, function(x) mean(x$transmit_bandwidth_bytes_per_s))
p2_transmit_means <- sapply(phase2_bandwidth, function(x) mean(x$transmit_bandwidth_bytes_per_s))

setwd("..")

png(filename = "average_energy_ssh.png")

layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
barplot(
  c(p1_energy_per_s_mean, p2_energy_per_s_mean),
  names.arg = c("SSH ja tuloste", "SSH ilman tulostetta"),
  xlab = "Koevaihe",
  ylab = "Energiankulutuksen keskiarvo (mWh/s)"
)

boxplot(p1_transmit_means, xlab = "SSH ja tuloste", ylab = "Kaistanleveyden keskiarvo per koe (Bps)")
boxplot(p2_transmit_means, xlab = "SSH ilman tulostetta", ylab = "Kaistanleveyden keskiarvo per koe (Bps)")

dev.off()
