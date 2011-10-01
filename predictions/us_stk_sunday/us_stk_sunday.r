# us_stk_sunday.r

# I use this script to plot data returned from this sql script:
# us_stk_sunday.sql

# Define the .png file which will hold the output:
png("us_stk_sunday_s.png",width = 1100, height = 1100)

us_stk_sunday = read.csv("us_stk_sunday_s.csv")
# I want to label every 10 days:
labels4sunday = read.csv("labels4sunday.csv")

# Tick labels perp to each axis
ytl_perp = 2
xtl_perp = 2
# plot with ticks turned off:
par()$mar
par(mar=c(6.2, 4.1, 4.1, 2.1))
plot(us_stk_sunday$TDATE
  ,us_stk_sunday$CUM_SUM
  ,xaxt = 'n'
  ,las = ytl_perp
  ,main = "Performance of DanBot Bearish Predictions (Negative Slope is Good Performance)"
  ,ylab = "US Dollars"
  ,type = "n"
)

# Connect the dots:
lines(us_stk_sunday$TDATE
  ,us_stk_sunday$CUM_SUM
  ,type = "o"
)

#  ,xlab = "Dates (Approximately 10 trading days apart)"

# add x-axis with ticks every 10 days and labels for each tick:
axis(1, at=labels4sunday$RROWNUM, labels=labels4sunday$TDATE, las = xtl_perp)
grid()
dev.off()



# Now I plot the bullish predictions.

# Define the .png file which will hold the output:
png("us_stk_sunday_l.png",width = 1100, height = 1100)

# Get the bullish data from the csv file:
us_stk_sunday = read.csv("us_stk_sunday_l.csv")

plot(us_stk_sunday$TDATE
  ,us_stk_sunday$CUM_SUM
  ,xaxt = 'n'
  ,las = ytl_perp
  ,main = "Performance of DanBot Bullish Predictions (Positive Slope is Good Performance)"
  ,ylab = "US Dollars"
  ,type = "n"
)

# Connect the dots:
lines(us_stk_sunday$TDATE
  ,us_stk_sunday$CUM_SUM
  ,type = "o"
)

# add x-axis with ticks every 10 days and labels for each tick:
axis(1, at=labels4sunday$RROWNUM, labels=labels4sunday$TDATE, las = xtl_perp)
grid()
dev.off()
