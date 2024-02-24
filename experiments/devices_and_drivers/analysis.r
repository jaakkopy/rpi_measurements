setwd("./measurement_data")

measurements <- lapply(c("^start*", "^no_eth*", "^no_wifi*", "^no_bt*", "^no_hdmi*", "^no_pcie*", "^no_usb*", "^all*"), function(x) {
  lapply(list.files(pattern = x), read.csv)
})
names(measurements) <- c("Alku",
                         "Ethernet",
                         "WiFi",
                         "BT",
                         "HDMI",
                         "PCIE",
                         "USB",
                         "Kaikki")

setwd("..")

measure_time <- 30

energies <- lapply(measurements, function(x) {
  sapply(x, function(y) {
    (tail(y$acc_energy_mWh, 1) - y$acc_energy_mWh[[1]]) * measure_time / tail(y$time_since_start_s, 1)
  })
})

mean_currents <- lapply(measurements, function(x) {
  sapply(x, function(y) mean(y$current_mA))
})

mean_voltages <- lapply(measurements, function(x) {
  sapply(x, function(y) mean(y$voltage_mV))
})


print("Energy")
for (x in names(measurements)) {
  print(x)
  print(summary(energies[[x]]))
}

print("Current")
for (x in names(measurements)) {
  print(x)
  print(summary(mean_currents[[x]]))
}

print("Voltage")
for (x in names(measurements)) {
  print(x)
  print(summary(mean_voltages[[x]]))
}

print("Mean energy consumption change percentage compared to start state")
for (x in names(measurements)) {
  print(x)
  print((mean(energies[[x]]) / mean(energies[["Alku"]]) - 1) * 100)
}

print("Two sided T-test of energy consumption samples compared to start state. confidence level 0.95")
for (x in names(measurements)) {
  print(x)
  print(t.test(energies[[x]], energies[["Alku"]], conf.level = 0.95))
}


png("devices_bars.png")

means <- sapply(energies, mean)
barplot(sort(means), ylim = c(0, max(means) + 1), ylab = "Energiankulutus (mWh)")

dev.off()
