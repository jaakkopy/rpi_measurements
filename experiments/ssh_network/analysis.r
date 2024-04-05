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

df3 <- measurements_to_df("./measurement_data/rpi32")
df3_bandwidth <- measurements_to_df("./bandwidth_data/rpi32")
df4 <- measurements_to_df("./measurement_data/rpi42")
df4_bandwidth <- measurements_to_df("./bandwidth_data/rpi42")
df5 <- measurements_to_df("./measurement_data/rpi52")
df5_bandwidth <- measurements_to_df("./bandwidth_data/rpi52")

# T-test for cases of messages being sent and not sent
for (wait_time in c(1, 5, 10, 15)) {
  for (df in list(df3, df4, df5)) {
    d <- df[df$wait_time_s == paste(wait_time, "s"),]
    x1 <- d[d$with_print == TRUE,]$power_mW
    x2 <- d[d$with_print == FALSE,]$power_mW
    print(t.test(x1, x2))
  }
}

# ANOVA and Kruskal-Wallis for 5, 10, 15 seconds
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

make_boxplot_for_bandwidth <- function(df, title, with_legend, xlabel, ylabel) {
  p <- ggplot(data = df, aes(x = wait_time_s, transmit_bandwidth_bytes_per_s, colour = with_print))
  if (with_legend) {
    p <- p + geom_boxplot()
  } else {
    p <- p + geom_boxplot(show.legend = FALSE)
  }
  p <- p + scale_fill_grey() +
    labs(x = xlabel, y = ylabel) +
    scale_x_discrete(limits = phases, labels = phases) +
    ggtitle(title)
  p
}

make_barplot_for_mean_power <- function(df, title, xlabel, ylabel) {
  df %>%
    group_by(wait_time_s, with_print) %>%
    summarize(m = mean(power_mW)) %>%
    ggplot(aes(x = wait_time_s, y = m, fill = with_print)) +
      geom_bar(show.legend = FALSE, stat = "identity", position = "dodge") +
      scale_x_discrete(limits = phases, labels = phases) +
      labs(x = xlabel, y = ylabel) +
      geom_text(aes(label = round(m, 0)), colour = "black", angle = 90, hjust = 1.5, position = position_dodge(width = .9)) +
      ggtitle(title)
}

# In English
xt <- "Time between messages (s)"
yt1 <- "Mean power consumption (mW)"
yt2 <- "Transmission bandwidth (Bps)"
p1 <- make_barplot_for_mean_power(df3, "RPi 3B+", xt, yt1)
p2 <- make_boxplot_for_bandwidth(df3_bandwidth, "RPi 3B+", FALSE, xt, yt2)
p3 <- make_barplot_for_mean_power(df4, "RPi 4B", xt, yt1)
p4 <- make_boxplot_for_bandwidth(df4_bandwidth, "RPi 4B", FALSE, xt, yt2)
p5 <- make_barplot_for_mean_power(df5, "RPi 5", xt, yt1)
p6 <- make_boxplot_for_bandwidth(df5_bandwidth, "RPi 5", FALSE, xt, yt2)

png("power_and_transmission.png", width = 800, heigh = 800)
grid.arrange(p1, p3, p5, p2, p4, p6, ncol = 3)
dev.off()

# Suomeksi 
xt <- "Viestien välinen aika (s)"
yt1 <- "Tehon keskiarvo (mW)"
yt2 <- "Lähetekaistanleveys (Bps)"
p1 <- make_barplot_for_mean_power(df3, "RPi 3B+", xt, yt1)
p2 <- make_boxplot_for_bandwidth(df3_bandwidth, "RPi 3B+", FALSE, xt, yt2)
p3 <- make_barplot_for_mean_power(df4, "RPi 4B", xt, yt1)
p4 <- make_boxplot_for_bandwidth(df4_bandwidth, "RPi 4B", FALSE, xt, yt2)
p5 <- make_barplot_for_mean_power(df5, "RPi 5", xt, yt1)
p6 <- make_boxplot_for_bandwidth(df5_bandwidth, "RPi 5", FALSE, xt, yt2)

png("power_and_transmission_suom.png", width = 800, heigh = 800)
grid.arrange(p1, p3, p5, p2, p4, p6, ncol = 3)
dev.off()
