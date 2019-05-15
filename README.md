# MacOS-Hardening-Script
A simple bash script to automated the majority of NIST hardening requirements for MacOS

I've made this script available to save others time.  It's based on the DRAFT NIST Special Publication 800-179 "Guide to securing macOS 10.12"

It doesn't currently include every hardening requirement but I aim to add them in the near future.  

It's been wrote so each hardening control is included as a separate item to make it easier for people to comment out any controls they don't want to apply.

**To run the script:**

Copy it to the Mac, open a terminal, go to the directory where the file is stored and run:

`sudo bash hardening_script.sh`

Whilst the script is running you will be asked to provide the following information:
* A hostname for the machine
* A firmware (BIOS) password
* The username of the local user account

## Hardening Controls

The script currently applies the following hardening/applies the following settings (I will link these back to the specific NIST requirement in the near future):

1. Sets a user defined hostname
2. Prevents users from logging in with iCloud (removes the iCloud login prompt)
3. Disables the infrared receiver
4. Disables Bluetooth
5. Enables automatic updates
6. Turns off the password hints
7. Sets the screenlock timeout to 5 minutes
8. Enables the Firewall
9. Sets a firmware password
10. Confirms that System Integrity Protection is enabled (it is by default.  If it's been turned off you can only enable it through recovery mode so it can't be scripted)
11. Enables GateKeeper
12. Sets the system and userwide umask to 022
13. Stops sending diagnostic information to Apple
14. Adds a logon banner (this should be edited to say whatever you need it to say)
15. Disables console logon from the logon screen
16. Restricts sudo to a single command
17. Removes the list of users from the logon screen
18. Disables Siri
19. Turns on file extentions which are hidden by default
20. Prevents other applications from intercepting text typed in to the terminal
21. Prevents downloaded signed software from receiving incoming connections
22. Enables packetfilter (pf)
23. Configures firewall to block incoming apple file server packets
24. Configures firewall to block incoming Bonjour packets

