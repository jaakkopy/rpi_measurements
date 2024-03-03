cols <- c("governor",
          "task_size",
          "task_interval",
          "time_s",
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
      utilization$time_s <- floor(utilization$time_s)
      measurements$time_s <- floor(measurements$time_s)
      measurements <- merge(measurements, utilization, by = "time_s", sort = TRUE)
      df <- rbind(df, measurements)
    }
  }
}

setwd("..")

summarized <- data.frame(matrix(ncol = 6, nrow = 0))
colnames(summarized) <- c("task_size", "task_interval", "mean_power", "total_energy", "mean_utilization", "governor")

print("task_size,interval,conservative,ondemand,powersave,performance")
for (size in c(2, 4, 8, 16)) {
  for (interval in c(1, 2, 3)) {
    
    values <- list()

    for (gov in governors) {
      entry <- df[df$governor == gov & df$task_size == size & df$task_interval == interval,]
      mean_power <- mean(entry$power_mW)
      total_energy <- max(entry$acc_energy_mWh) - min(entry$acc_energy_mWh)

      summarized <- rbind(summarized,
                          list(task_size = size,
                               task_interval = interval,
                               mean_power = mean_power,
                               total_energy = total_energy,
                               mean_utilization = mean(entry$cpu_utilization),
                               governor = gov))

      values[[gov]] <- list(mean_power = round(mean_power, 2),
                            mean_utilization = round(mean(entry$cpu_utilization), 2),
                            total_energy = total_energy)
    }

    cat(paste(size, interval, sep = ","))
    for (gov in governors) {
      m <- values[[gov]][["mean_power"]]
      u <- values[[gov]][["mean_utilization"]]
      e <- values[[gov]][["total_energy"]]
      cat(paste(",", paste(m, "mW"), paste(u, "%"), paste(e, "mWh"), sep = "|"))
    }
    print("")
  }
}

# Least energy per case
for (size in c(2, 4, 8, 16)) {
  for (interval in c(1, 2, 3)) {
    least_e <- -1
    g <- ""
    for (gov in governors) {
      entry <- df[df$governor == gov & df$task_size == size & df$task_interval == interval,]
      e <- max(entry$acc_energy_mWh) - min(entry$acc_energy_mWh)
      if (least_e == -1 || e < least_e) {
        least_e <- e
        g <- gov
      }
    }
    print(paste(size, interval, g))
  }
}


# Correlation plot
library(corrplot)
png("correlations.png")
par(mfrow=c(2,2))
for (gov in governors) {
  c <- df[df$governor == gov,][c("power_mW", "task_size", "task_interval", "cpu_utilization_percentage")]
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
