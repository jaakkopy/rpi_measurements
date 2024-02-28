setwd("./measurement_data/idle")

freqs <- c(6:18)
freq_strs <- lapply(freqs, function(x) paste(x, "00000", sep=""))

idle_data <- lapply(freq_strs, function(f) lapply(list.files(pattern = paste("idle-freq-", f, "*", sep = "")), read.csv))
names(idle_data) <- freq_strs

setwd("../..")

mean_currents <- lapply(idle_data, function(x) {
  mean(sapply(x, function(y) {
    mean(y$current_mA)
  }))
})

mean_voltages <- lapply(idle_data, function(x) {
  mean(sapply(x, function(y) {
    mean(y$voltage_mV)
  }))
})

energies <- lapply(idle_data, function(x) {
  sapply(x, function(y) {
    (tail(y$acc_energy_mWh, 1) - y$acc_energy_mWh[[1]]) * 30 / tail(y$time_since_start_s, 1)
  })
})

mean_energies <- lapply(energies, mean)

for (x in freq_strs) {
    print(x)
    print(mean_currents[[x]])
    print(mean_voltages[[x]])
    print(mean_energies[[x]])
}

prev <- freq_strs[[1]]
for (x in freq_strs[c(2:length(freq_strs))]) {
    print(t.test(energies[[prev]], energies[[x]]))
    prev <- x
}


png("energy_current_voltage_vs_frequency.png")

par(mfrow=c(1,3))
plot(freqs/10,
     mean_energies,
     yaxt = "n",
     xlab = "Kellotaajuus (MHz)",
     ylab = "Energiankulutuksen keskiarvo (mWh)")
axis(2, seq(floor(min(unlist(mean_energies))), ceiling(max(unlist(mean_energies))), 0.5))
lines(freqs/10, mean_energies)

plot(freqs/10,
     mean_currents,
     xlab = "Kellotaajuus (MHz)",
     ylab = "Virrankulutuksen keskiarvojen keskiarvo (mA)")
lines(freqs/10, mean_currents)

plot(freqs/10,
     mean_voltages,
     xlab = "Kellotaajuus (MHz)",
     ylab = "Jännitteen keskiarvojen keskiarvo (mV)")
lines(freqs/10, mean_voltages)

dev.off()

cor(sapply(names(mean_energies), as.integer), unlist(mean_energies))
