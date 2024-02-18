setwd("./measurement_data")

data <- lapply(list.files(pattern = "*"), read.csv)

setwd("..")

energy_scaled <- sapply(data, function(x) (tail(x$acc_energy_mWh, 1) - x$acc_energy_mWh[[1]]) * 30 / tail(x$time_since_start_s, 1))
mean_currents <- sapply(data, function(x) mean(x$current_mA))
mean_voltages <- sapply(data, function(x) mean(x$voltage_mV))

summary(energy_scaled)
summary(mean_currents)
summary(mean_voltages)