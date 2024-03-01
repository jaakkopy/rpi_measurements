cols <- c("governor",
          "task_size",
          "task_interval",
          "time_since_start_s",
          "voltage_mV",
          "current_mA",
          "power_mW",
          "acc_energy_mWh",
          "cpu_utilization")

df <- data.frame(matrix(ncol = length(cols), nrow = 0))
colnames(df) <- cols

setwd("./measurement_data")

governors <- c("conservative", "ondemand", "powersave", "performance")

for (size in c(2, 4, 8)) {
  for (interval in c(1, 2, 3)) {
    for (gov in governors) {
      f <- paste(gov, "-", size, "-", interval, ".csv", sep = "")
      measurements <- read.csv(f)
      measurements$governor <- rep(gov, times = nrow(measurements))
      measurements$task_size <- rep(size, times = nrow(measurements))
      measurements$task_interval <- rep(interval, times = nrow(measurements))
      utilization <- read.csv(paste("./utilization/", f, sep = ""))
      measurements$cpu_utilization <- rep(mean(utilization$cpu_utilization_percentage), times = nrow(measurements))
      df <- rbind(df, measurements)
    }
  }
}

setwd("..")

least_power <- list(conservative = 0, ondemand = 0, powersave = 0, performance = 0)
fastest <- list(conservative = 0, ondemand = 0, powersave = 0, performance = 0)

summarized <- data.frame(matrix(ncol = 5, nrow = 0))
colnames(summarized) <- c("task_size", "task_interval", "mean_power", "mean_utilization", "governor")

print("task_size,interval,governor,mean_power,time_taken")
for (size in c(2, 4, 8)) {
  for (interval in c(1, 2, 3)) {
    least_p <- -1
    least_gov <- ""
    fastest_time <- -1
    fastest_gov <- ""
    for (gov in governors) {
      entry <- df[df$governor == gov & df$task_size == size & df$task_interval == interval,]
      mean_power <- mean(entry$power_mW)
      time_taken <- tail(entry$time_since_start_s, 1) - head(entry$time_since_start_s, 1)
      if (least_p == -1 || mean_power < least_p) {
        least_p <- mean_power
        least_gov <- gov
      }
      if (fastest_time == -1 || time_taken < fastest_time) {
        fastest_time <- time_taken
        fastest_gov <- gov
      }

      summarized <- rbind(summarized,
                          list(task_size = size,
                               task_interval = interval,
                               mean_power = mean_power,
                               mean_utilization = head(entry$cpu_utilization, 1),
                               governor = gov))

      print(paste(size,interval,gov,round(mean_power, 3),round(time_taken, 3), sep = ","))
    }
    least_power[[least_gov]] <- least_power[[least_gov]] + 1
    fastest[[fastest_gov]] <- fastest[[fastest_gov]] + 1
  }
}

# Kruskal-Wallis
for (size in c(2, 4, 8)) {
  for (interval in c(1, 2, 3)) {
    print(kruskal.test(lapply(governors, function(g) {
      df[df$governor == g & df$task_size == size & df$task_interval == interval,]$power_mW
    })))
  }
}
# ANOVA
for (size in c(2, 4, 8)) {
  for (interval in c(1, 2, 3)) {
    d <- df[df$task_size == size & df$task_interval == interval,]
    print(summary(aov(power_mW ~ governor, d)))
  }
}


print(least_power)
print(fastest)

library(plotly)
require(reticulate)

fig <- plot_ly(summarized,
               x = ~task_size,
               y = ~task_interval,
               z = ~mean_power,
               color = ~governor)
fig <- fig %>% layout(title = "Työn koko, töiden saapumisintervalli ja teho per säädin",
                      scene = list(xaxis = list(title = "Työn koko (milj.)"),
                                   yaxis = list(title = "Töiden saapumisväli (s)"),
                                   zaxis = list(title = "Tehon keskiarvo (mW)")))

fig

colnames(summarized)[4] <- "Käyttötason keskiarvo (%)"
fig <- plot_ly(summarized,
               x = ~task_size,
               y = ~task_interval,
               z = ~mean_power,
               color = ~`Käyttötason keskiarvo (%)`)
fig <- fig %>% layout(title = "Työn koko, töiden saapumisintervalli, teho ja prosessorin käyttötaso",
                      scene = list(xaxis = list(title = "Työn koko (milj.)"),
                                   yaxis = list(title = "Töiden saapumisväli (s)"),
                                   zaxis = list(title = "Tehon keskiarvo (mW)")))


fig
