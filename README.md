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
23. Configures firewall to block apple file server packets
24. Configures firewall to block Bonjour packets
25. Configures firewall to block finger
26. Configures firewall to block FTP 
27. Configures firewall to block HTTP
28. Configures firewall to block ICMP
29. Configures firewall to block IMAP
30. Configures firewall to block IMAPS
31. Configures firewall to block iTunes Sharing 
32. Configures firewall to block mDNSResponder
33. Configures firewall to block NFS
34. Configures firewall to block Optical Sharing
35. Configures firewall to block POP3
36. Configures firewall to block POP3S
37. Configures firewall to block Printer Sharing
38. Configures firewall to block Remote Apple Events
39. Configures firewall to block Screen Sharing
40. Configures firewall to block SMB
41. Configures firewall to block SMTP
42. Configures firewall to block SSH
43. Configures firewall to block Telnet
44. Configures firewall to block TFTP
45. Configures firewall to block UUCP
46. Prevents any action when a blank CD is inserted
47. Prevents any action when a blank DVD is inserted
48. Prevents any action when a music CD is inserted
49. Prevents any action when a picture CD is inserted
50. Prevents any action when a video DVD is inserted
51. Disables the SMB file sharing daemon
52. Prevents the computer from broadcasting bonjour service advertisements
53. Disables the NFS server daemon
54. Disables the public key authentication mechanism for SSH
55. Prevents root login via SSH
56. Sets the number of 'client alive messages' (that can be sent before disconnecting the client) to 4
57. Reboots to ensure the settings take effect
