setwd("./measurement_data")

data <- lapply(list.files(pattern = "*"), read.csv)

setwd("..")

energy_scaled <- sapply(data, function(x) (tail(x$acc_energy_mWh, 1) - x$acc_energy_mWh[[1]]) * 30 / tail(x$time_since_start_s, 1))
mean_currents <- sapply(data, function(x) mean(x$current_mA))
mean_voltages <- sapply(data, function(x) mean(x$voltage_mV))

summary(energy_scaled)
summary(mean_currents)
summary(mean_voltages)

png("idle_state_hist.png")

par(mfrow=c(1, 3))
he <- hist(energy_scaled, main = "Energiankulutus", ylab = "Frekvenssi", xlab = "Energiankulutus (mWh)", ylim = c(0, 50))
hc <- hist(mean_currents, main = "Virran keskiarvo", ylab = "Frekvenssi", xlab = "Virran keskiarvo (mA)", ylim = c(0, 50))
hv <- hist(mean_voltages, main = "Jännitteen keskiarvo", ylab = "Frekvenssi", xlab = "Jännitteen keskiarvo (mV)", ylim = c(0, 50))

dev.off()

t.test(mean_currents)
t.test(mean_voltages)

max(he$counts) / length(energy_scaled)
