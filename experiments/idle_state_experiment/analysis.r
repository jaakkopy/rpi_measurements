setwd("./measurement_data")

data <- lapply(list.files(pattern = "*"), read.csv)

setwd("..")

energy_per_s <- sapply(data, function(x) (tail(x$acc_energy_mWh, 1) - x$acc_energy_mWh[[1]]) / tail(x$time_since_start_s, 1))
mean_currents <- sapply(data, function(x) mean(x$current_mA))
mean_voltages <- sapply(data, function(x) mean(x$voltage_mV))

summary(energy_per_s)
summary(mean_currents)
summary(mean_voltages)

#layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
hist( (energy_per_s - mean(energy_per_s)) / sd(energy_per_s) )