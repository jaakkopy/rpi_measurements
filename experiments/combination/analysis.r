df3 <- read.csv("./measurement_data/rpi3-combo.csv")
times3 <- read.csv("./measurement_data/rpi3-combo-time-marks.csv")
df4 <- read.csv("./measurement_data/rpi4-combo.csv")
times4 <- read.csv("./measurement_data/rpi4-combo-time-marks.csv")
df5 <- read.csv("./measurement_data/rpi5-combo.csv")
times5 <- read.csv("./measurement_data/rpi5-combo-time-marks.csv")

remove_outliers <- function(df) {
  iqr <- IQR(df$power_mW)
  Q <- quantile(df$power_mW, probs=c(0.25, 0.75), na.rm = FALSE)
  df[df$power_mW >= Q[1] - 1.5 * iqr & df$power_mW <= Q[2] + 1.5 * iqr,]
}

prepare <- function(df, times) {
  df <- df[df$time_s >= min(times$time_s) & df$time_s <= max(times$time_s),]
  remove_outliers(df)
}

df3 <- prepare(df3, times3)
df4 <- prepare(df4, times4)
df5 <- prepare(df5, times5)

p1 <- mean(df3$power_mW)
p2 <- mean(df4$power_mW)
p3 <- mean(df5$power_mW)
c1 <- mean(df3$current_mA)
c2 <- mean(df4$current_mA)
c3 <- mean(df5$current_mA)

no_changes3 <- remove_outliers(read.csv("./measurement_data/rpi3-no-changes.csv"))
no_changes4 <- remove_outliers(read.csv("./measurement_data/rpi4-no-changes.csv"))
no_changes5 <- remove_outliers(read.csv("./measurement_data/rpi5-no-changes.csv"))

p4 <- mean(no_changes3$power_mW)
p5 <- mean(no_changes4$power_mW)
p6 <- mean(no_changes5$power_mW)
c4 <- mean(no_changes3$current_mA)
c5 <- mean(no_changes4$current_mA)
c6 <- mean(no_changes5$current_mA)

print( (m1 / m4 - 1) * 100 )
print( (m2 / m5 - 1) * 100 )
print( (m3 / m6 - 1) * 100 )