setwd("./measurement_data")

data <- lapply(list.files(pattern = "^usb*"), read.csv)

setwd("..")

energy_scaled <- sapply(data, function(x) (tail(x$acc_energy_mWh, 1) - x$acc_energy_mWh[[1]]) * 30 / tail(x$time_since_start_s, 1))
mean_currents <- sapply(data, function(x) mean(x$current_mA))
mean_voltages <- sapply(data, function(x) mean(x$voltage_mV))

setwd("../idle_state/measurement_data")

idle_state_data <- lapply(list.files(pattern = "*"), read.csv)
idle_energy_scaled <- sapply(idle_state_data, function(x) (tail(x$acc_energy_mWh, 1) - x$acc_energy_mWh[[1]]) * 30 / tail(x$time_since_start_s, 1))
idle_mean_currents <- sapply(idle_state_data, function(x) mean(x$current_mA))
idle_mean_voltages <- sapply(idle_state_data, function(x) mean(x$voltage_mV))

setwd("../../devices_and_drivers")

# Smummaries
summary(energy_scaled)
summary(mean_currents)
summary(mean_voltages)

# Percentage change in energy
print((1- mean(energy_scaled) / mean(idle_energy_scaled))*100)
# T-test for energy
t.test(energy_scaled, idle_energy_scaled, conf.level = 0.95)

# Percentage change in mean current 
print((1- mean(mean_currents) / mean(idle_mean_currents))*100)
# T-test for current
t.test(mean_currents, idle_mean_currents, conf.level = 0.95)

# Percentage change in mean voltage
print((1- mean(mean_voltages) / mean(idle_mean_voltages))*100)
# T-test for current
t.test(mean_voltages, idle_mean_voltages, conf.level = 0.95)
