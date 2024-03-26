measurements_to_df <- function(prefix) {
  cols <- c("time_s",
            "voltage_mV",
            "current_mA",
            "power_mW",
            "acc_energy_mWh",
            "wait_time_s",
            "with_print")
  df <- data.frame(matrix(ncol = length(cols), nrow = 0))
  colnames(df) <- cols
  for (wait_time in c(1, 5, 10, 15)) {
    without_print <- read.csv(paste(prefix, "-", wait_time, "-without_print.csv", sep = ""))
    without_print$wait_time_s <- rep(paste(wait_time, "s"), times = nrow(without_print))
    without_print$with_print <- rep(FALSE, times = nrow(without_print))
    with_print <- read.csv(paste(prefix, "-", wait_time, "-with_print.csv", sep = ""))
    with_print$wait_time_s <- rep(paste(wait_time, "s"), times = nrow(with_print))
    with_print$with_print <- rep(TRUE, times = nrow(with_print))
    df <- rbind(df, without_print, with_print)
  }
  df
}

set_mean_bandwidth <- function(df, df_band) {
  df$mean_transmission_bandwidth_bps <- rep(NA, times = nrow(df))
  for (wait_time in c(1, 5, 10, 15)) {
    x <- paste(wait_time, "s")
    mb <- mean(df_band[df_band$wait_time_s == x,]$transmit_bandwidth_bytes_per_s)
    df[df$wait_time_s == x,]$mean_transmission_bandwidth_bps <- rep(mb, times = nrow(df[df$wait_time_s == x,]))
  }
  df
}

df3 <- measurements_to_df("./measurement_data/rpi3")
df3_bandwidth <- measurements_to_df("./bandwidth_data/rpi3")
df4 <- measurements_to_df("./measurement_data/rpi4")
df4_bandwidth <- measurements_to_df("./bandwidth_data/rpi4")
df5 <- measurements_to_df("./measurement_data/rpi5")
df5_bandwidth <- measurements_to_df("./bandwidth_data/rpi5")

# T-test for cases of messages being sent and not sent
for (wait_time in c(1, 5, 10, 15, 20)) {
  for (df in list(df3, df4, df5)) {
    d <- df[df$wait_time_s == paste(wait_time, "s"),]
    x1 <- d[d$with_print == TRUE,]$power_mW
    x2 <- d[d$with_print == FALSE,]$power_mW
    print(t.test(x1, x2))
  }
}

# ANOVA and Kruskal-Wallis for 10, 15, 20 seconds
print(summary(aov(power_mW ~ wait_time_s, data = df3[df3$with_print == TRUE & (df3$wait_time_s == "10 s" | df3$wait_time_s == "15 s"),])))
print(summary(aov(power_mW ~ wait_time_s, data = df4[df4$with_print == TRUE & (df4$wait_time_s == "10 s" | df4$wait_time_s == "15 s"),])))
print(summary(aov(power_mW ~ wait_time_s, data = df5[df5$with_print == TRUE & (df5$wait_time_s == "10 s" | df5$wait_time_s == "15 s"),])))

print(kruskal.test(power_mW ~ wait_time_s, data = df3[df3$with_print == TRUE & (df3$wait_time_s == "10 s" | df3$wait_time_s == "15 s"),]))
print(kruskal.test(power_mW ~ wait_time_s, data = df4[df4$with_print == TRUE & (df4$wait_time_s == "10 s" | df4$wait_time_s == "15 s"),]))
print(kruskal.test(power_mW ~ wait_time_s, data = df5[df5$with_print == TRUE & (df5$wait_time_s == "10 s" | df5$wait_time_s == "15 s"),]))

# ANOVA with poll wait as explanatory variable
for (x in list(df3, df4, df5)) {
  r <- aov(power_mW ~ wait_time_s, data = x)
  print(summary(r))
}

# Kruskal-Wallis
for (x in list(df3, df4, df5)) {
  r <- kruskal.test(power_mW ~ wait_time_s, data = x)
  print(r)
}

library(ggplot2)
require(gridExtra)
library(dplyr)

phases <- sapply(c(1, 5, 10, 15), function(x) paste(x, "s"))

make_boxplot_for_power <- function(df, title, with_legend) {
  p <- ggplot(data = df, aes(x = wait_time_s, power_mW, colour = with_print))
  if (with_legend) {
      p <- p + geom_boxplot()
  } else {
    p <- p + geom_boxplot(show.legend = FALSE)
  }
  p <- p + scale_x_discrete(limits = phases, labels = phases) +
    labs(x = "Time between messages (s)", y = "Power (mW)") +
    ggtitle(title)
  p 
}

make_boxplot_for_bandwidth <- function(df, title, with_legend) {
  p <- ggplot(data = df, aes(x = wait_time_s, transmit_bandwidth_bytes_per_s, colour = with_print))
  if (with_legend) {
    p <- p + geom_boxplot()
  } else {
    p <- p + geom_boxplot(show.legend = FALSE)
  }
  p <- p + scale_fill_grey() +
    labs(x = "Time between messages (s)", y = "Transmission bandwidth (Bps)") +
    scale_x_discrete(limits = phases, labels = phases) +
    ggtitle(title)
  p
}

make_barplot_for_mean_power <- function(df, title) {
  df %>%
    group_by(wait_time_s, with_print) %>%
    summarize(m = mean(power_mW)) %>%
    ggplot(aes(x = wait_time_s, y = m, fill = with_print)) +
      geom_bar(show.legend = FALSE, stat = "identity", position = "dodge") +
      scale_x_discrete(limits = phases, labels = phases) +
      labs(x = "Time between messages (s)", y = "Mean power consumption (mW)") +
      ggtitle(title)
}

p1 <- make_barplot_for_mean_power(df3, "RPi 3B+")
p2 <- make_boxplot_for_bandwidth(df3_bandwidth, "RPi 3B+", FALSE)
p3 <- make_barplot_for_mean_power(df4, "RPi 4B")
p4 <- make_boxplot_for_bandwidth(df4_bandwidth, "RPi 4B", FALSE)
p5 <- make_barplot_for_mean_power(df5, "RPi 5")
p6 <- make_boxplot_for_bandwidth(df5_bandwidth, "RPi 5", FALSE)

png("power_and_transmission.png", width = 800, heigh = 800)
grid.arrange(p1, p3, p5, p2, p4, p6, ncol = 3)
dev.off()
