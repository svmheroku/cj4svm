# us_stk_sunday.r

# I use this script to plot data returned from this sql script:
# us_stk_sunday.sql

us_stk_sunday = read.csv("us_stk_sunday.csv")
# I want to label every 10 days:
labels4sunday = read.csv("labels4sunday.csv")

# How big is this?
tdaynum = length(us_stk_sunday$CUM_SUM)

# Tick labels perp to each axis
ytl_perp = 2
xtl_perp = 2
# plot with ticks turned off:
plot(us_stk_sunday$TDATE,us_stk_sunday$CUM_SUM, xaxt = 'n', las = ytl_perp)
# add x-axis with ticks every 10 days and labels for each tick:
axis (1, at=labels4sunday$RROWNUM, labels=labels4sunday$TDATE, las = xtl_perp)

