# us_stk_sunday.r

# I use this script to plot data returned from this sql script:
# us_stk_sunday.sql

# Define the .png file which will hold the output:
png("us_stk_sunday.png",width = 900, height = 900)

us_stk_sunday_s = read.csv("us_stk_sunday_s.csv")
# I want to label every 10 days:
labels4sunday = read.csv("labels4sunday.csv")

# Tick labels perp to each axis
ytl_perp = 2
xtl_perp = 2
# plot with ticks turned off:
par()$mar
par(mar=c(6.2, 4.1, 4.1, 2.1))
plot(us_stk_sunday_s$TDATE
  ,us_stk_sunday_s$CUM_SUM
  ,xaxt = 'n'
  ,las = ytl_perp
  ,main = "Performance of DanBot US Stock Predictions (Green = Bullish, Red = Bearish)"
  ,ylab = "US Dollars"
  ,type = "n"
  ,ylim = c(-15000, 15000)
)

# Connect the dots:
lines(us_stk_sunday_s$TDATE
  ,us_stk_sunday_s$CUM_SUM
  ,type = "o"
  ,col="red"
)

# add x-axis with ticks every 10 days and labels for each tick:
axis(1, at=labels4sunday$RROWNUM, labels=labels4sunday$TDATE, las = xtl_perp)

# Now overlay another plot:
# http://pj.freefaculty.org/R/Rtips.html#5.11
par(new = TRUE) 

# Now I plot the bullish predictions.

# Get the bullish data from the csv file:
us_stk_sunday_l = read.csv("us_stk_sunday_l.csv")

plot(us_stk_sunday_l$TDATE
  ,us_stk_sunday_l$CUM_SUM
  ,xaxt = 'n'
  ,yaxt = 'n'
  ,type = "n"
  ,ylim = c(-15000, 15000)
)

# Connect the dots:
lines(us_stk_sunday_l$TDATE
  ,us_stk_sunday_l$CUM_SUM
  ,type = "o"
  ,col="green"
)

grid()
dev.off()
