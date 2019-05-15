# MacOS-Hardening-Script
A simple bash script to automated the majority of NIST hardening requirements for MacOS

I've made this script available to save others time.  It's based on the DRAFT NIST Special Publication 800-179 "Guide to securing macOS 10.12"

It doesn't currently include every hardening requirement but I aim to add them in the near future.  

It's been wrote so each hardening control is included as a separate item to make it easier for people to comment out any controls they don't want to apply.

##To run the script:

Copy it to the Mac, open a terminal, go to the directory where the file is stored and run:

`sudo bash hardening_script.sh`
