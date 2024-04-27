read_to_df <- function() {
  setwd("./measurement_data")
  cols <- c("time_s",
            "voltage_mV",
            "current_mA",
            "power_mW",
            "acc_energy_mWh",
            "bytes",
            "wait")
  df <- data.frame(matrix(ncol = length(cols), nrow = 0))
  colnames(df) <- cols
  for (b in seq(200, 1400, 200)) {
    for (w in c(2, 4, 8, 10, 12, 14, 16)) {
      d <- read.csv(paste("p", b, "-w", w, ".csv", sep=""))
      d$time_s <- d$time_s - min(d$time_s)
      d$bytes <- rep(b, times=nrow(d))
      d$wait <- rep(w, times=nrow(d))
      d$acc_energy_mWh <- d$acc_energy_mWh - min(d$acc_energy_mWh)
      df <- rbind(df, d) 
    }
  }
  setwd("..")
  df
}

df <- read_to_df()

library(ggplot2)
library(dplyr)
require(gridExtra)

l <- lapply(c(2, 4, 8, 10, 12, 14, 16), function(w) {
  df[df$wait == w,] %>%
      group_by(bytes) %>%
      ggplot(aes(x = time_s, y = acc_energy_mWh, color = factor(bytes))) +
      geom_line() +
      ggtitle(paste("Wait time:", w, "seconds"))
})
grid.arrange(grobs=l, nrow=4)