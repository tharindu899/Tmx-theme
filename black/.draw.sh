#!/usr/bin/bash
PUT(){ echo -en "\033[${1};${2}H";}
DRAW(){ echo -en "\033%";echo -en "\033(0";}
WRITE(){ echo -en "\033(B";}
HIDECURSOR(){ echo -en "\033[?25l";}
NORM(){ echo -en "\033[?12l\033[?25h";}

HIDECURSOR
clear
echo -e "\033[35;1m"
#tput setaf 5
echo "┌────────────────────────────────────────────────────────────┐"
for ((i=1; i<=8; i++)); do
echo "│                                                            │"
done
echo "└────────────────────────────────────────────────────────────┘"
PUT 4 0
figlet -c -f ASCII-Shadow -w 62 "..rio.." | lolcat -t
PUT 3 0
echo -e "\033[35;1m"
#tput setaf 5
for ((i=1; i<=7; i++)); do
echo "│"
done
PUT 10 42
echo -e "\e[32mBoot Script \e[33m3.0\e[0m"
PUT 12 0
echo
NORM
