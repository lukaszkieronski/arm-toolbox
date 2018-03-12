set confirm off
target extended openocd:3333
monitor reset halt
load
monitor reset run
quit
