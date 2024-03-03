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

for (size in c(2, 4, 8, 16)) {
  for (interval in c(1, 2, 3)) {
    for (gov in governors) {
      f <- paste(gov, "-", size, "-", interval, ".csv", sep = "")
      measurements <- read.csv(f)
      measurements$governor <- rep(gov, times = nrow(measurements))
      measurements$task_size <- rep(size, times = nrow(measurements))
      measurements$task_interval <- rep(interval, times = nrow(measurements))
      utilization <- read.csv(paste("./utilization/", f, sep = ""))
      measurements$cpu_utilization <- utilization$cpu_utilization_percentage[c(1:nrow(measurements))]
      df <- rbind(df, measurements)
    }
  }
}

setwd("..")

least_power <- list(conservative = 0, ondemand = 0, powersave = 0, performance = 0)
least_energy <- list(conservative = 0, ondemand = 0, powersave = 0, performance = 0)
fastest <- list(conservative = 0, ondemand = 0, powersave = 0, performance = 0)

summarized <- data.frame(matrix(ncol = 6, nrow = 0))
colnames(summarized) <- c("task_size", "task_interval", "mean_power", "total_energy", "mean_utilization", "governor")

print("task_size,interval,governor,mean_power,mean_utilization,time_taken")
for (size in c(2, 4, 8, 16)) {
  for (interval in c(1, 2, 3)) {
    least_p <- -1
    least_p_gov <- ""
    least_e <- -1
    least_e_gov <- ""
    fastest_time <- -1
    fastest_gov <- ""
    for (gov in governors) {
      entry <- df[df$governor == gov & df$task_size == size & df$task_interval == interval,]
      mean_power <- mean(entry$power_mW)
      time_taken <- tail(entry$time_since_start_s, 1) - head(entry$time_since_start_s, 1)
      total_energy <- tail(entry$acc_energy_mWh, 1) - head(entry$acc_energy_mWh, 1)
      if (least_p == -1 || mean_power < least_p) {
        least_p <- mean_power
        least_p_gov <- gov
      }
      if (fastest_time == -1 || time_taken < fastest_time) {
        fastest_time <- time_taken
        fastest_gov <- gov
      }
      if (least_e == -1 || total_energy < least_e) {
        least_e <- total_energy
        least_e_gov <- gov
      }
      summarized <- rbind(summarized,
                          list(task_size = size,
                               task_interval = interval,
                               mean_power = mean_power,
                               total_energy = total_energy,
                               mean_utilization = mean(entry$cpu_utilization),
                               governor = gov))

      print(paste(size,interval,gov,round(mean_power, 3),round(mean(entry$cpu_utilization), 3), round(time_taken, 3), sep = ","))
    }
    least_power[[least_p_gov]] <- least_power[[least_p_gov]] + 1
    least_energy[[least_e_gov]] <- least_energy[[least_e_gov]] + 1
    fastest[[fastest_gov]] <- fastest[[fastest_gov]] + 1
  }
}

print(least_power)
print(least_energy)
print(fastest)

# Correlation plot
library(corrplot)
png("correlations.png")
par(mfrow=c(2,2))
for (gov in governors) {
  c <- df[df$governor == gov,][c("power_mW", "task_size", "task_interval", "cpu_utilization")]
  colnames(c) <- c("Teho (mW)", "Työkoko (milj.)", "Töiden aikaväli (s)", "CPU-käyttötaso (%)")
  corrplot(title = gov,
           corr=cor(c),
           tl.col="black",
           tl.cex=0.6,
           mar=c(0,0,2,0))
}
dev.off()

# Kruskal-Wallis
for (size in c(2, 4, 8, 16)) {
  for (interval in c(1, 2, 3)) {
    print(kruskal.test(lapply(governors, function(g) {
      df[df$governor == g & df$task_size == size & df$task_interval == interval,]$power_mW
    })))
  }
}
# ANOVA
for (size in c(2, 4, 8, 16)) {
  for (interval in c(1, 2, 3)) {
    d <- df[df$task_size == size & df$task_interval == interval,]
    print(summary(aov(power_mW ~ governor, d)))
  }
}


library(plotly)

to_plot <- summarized
colnames(to_plot)[5] <- "Käyttötason keskiarvo (%)"


p1 <- plot_ly(to_plot[to_plot$governor == "conservative",],
              x = ~task_size,
              y = ~task_interval,
              z = ~mean_power,
              color = ~`Käyttötason keskiarvo (%)`,
              scene = "scene1",
              type = "scatter3d", mode = "lines + markers")

p2 <- plot_ly(to_plot[to_plot$governor == "ondemand",],
              x = ~task_size,
              y = ~task_interval,
              z = ~mean_power,
              color = ~`Käyttötason keskiarvo (%)`,
              scene = "scene2",
              type = "scatter3d", mode = "lines + markers")

p3 <- plot_ly(to_plot[to_plot$governor == "powersave",],
              x = ~task_size,
              y = ~task_interval,
              z = ~mean_power,
              color = ~`Käyttötason keskiarvo (%)`,
              scene = "scene3",
              type = "scatter3d", mode = "lines + markers")

p4 <- plot_ly(to_plot[to_plot$governor == "performance",],
              x = ~task_size,
              y = ~task_interval,
              z = ~mean_power,
              color = ~`Käyttötason keskiarvo (%)`,
              scene = "scene4",
              type = "scatter3d", mode = "lines + markers")

fig <- subplot(p1, p2, p3, p4)
fig <- fig %>% layout(title = "Työn koko, töiden saapumisväli, teho, prosessorin käyttötaso ja säätimet",
                      scene = list(domain = list(x = c(0, 0.5), y = c(0, 0.5)),
                                   aspectmode = "cube",
                                   xaxis = list(title = "Työkoko (milj.)"),
                                   yaxis = list(title = "Töiden saapumisväli (s)"),
                                   zaxis = list(title = "Tehon keskiarvo (mW)"),
                                   layout = list(showlegend = FALSE)),
                      scene2 = list(domain = list(x = c(0, 0.5), y = c(0.5, 1)),
                                    aspectmode = "cube",
                                    xaxis = list(title = "Työkoko (milj.)"),
                                    yaxis = list(title = "Töiden saapumisväli (s)"),
                                    zaxis = list(title = "Tehon keskiarvo (mW)")),
                      scene3 = list(domain = list(x = c(0.5, 1), y = c(0, 0.5)),
                                    aspectmode = "cube",
                                    xaxis = list(title = "Työkoko (milj.)"),
                                    yaxis = list(title = "Töiden saapumisväli (s)"),
                                    zaxis = list(title = "Tehon keskiarvo (mW)")),
                      scene4 = list(domain = list(x = c(0.5, 1), y = c(0.5, 1)),
                                    aspectmode = "cube",
                                    xaxis = list(title = "Työkoko (milj.)"),
                                    yaxis = list(title = "Töiden saapumisväli (s)"),
                                    zaxis = list(title = "Tehon keskiarvo (mW)")),
                      annotations = list(
                        list(x = 0.25 , y = 0.45, text = "conservative", showarrow = F, xref='paper', yref='paper'),
                        list(x = 0.25 , y = 0.95, text = "ondemand", showarrow = F, xref='paper', yref='paper'),
                        list(x = 0.75 , y = 0.45, text = "powersave", showarrow = F, xref='paper', yref='paper'),
                        list(x = 0.75 , y = 0.95, text = "performance", showarrow = F, xref='paper', yref='paper')
                      ))
fig
