#! /bin/bash

# This script will check the status of the hardening level of the machine (against the hardening applied by the 'hardening_script.sh'

# May need to add an extra echo command if the command isn't very verbose and doesn't indicate what the value is related to when writing out ./results.txt

# Easter Egg

date=$(date +%d-%m)
alex="18-01"

if [ "$date" == "alex" ]; then
	echo "[i] IT'S INTERNATIONAL HUG ALEX TAYLOR DAY. DON'T WORRY, YOU WONT CATCH DENGUE FEVER (WE HOPE)"
	exit 1
fi

######################################################################################################################################

# THIS SECTIONS CONFIRMS THAT THE SCRIPT HAS BEEN RUN WITH SUDO

if [[ $UID -ne 0 ]]; then
	echo "Need to run this script as root (with sudo)"
	exit 1
fi

echo "[i] Beginning hardening checks now"

echo "[i] This script will save the results to ./results.txt"

sleep 1

######################################################################################################################################

# Getting the hostname and setting it as a variable

echo "[I] Getting the machines hostname:"

set DEVNAME=scutil --get HostName

echo "[i] The machine's hostname is: " DEVNAME >> ./results.txt
echo "[i] The machine's hostname is: " $DEVNAME

sleep 1

######################################################################################################################################

# Confirming if the iCloud login prompt is turned off

echo "[i] Confirming that iCloud login prompt is turned off:"

icloudoff=$(defaults read /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup)
icloudoffcorrect="true"

if [ "$icloudoff" == "$icloudoffcorrect" ]; then
        echo "[YES] iCloud login is turned off"
else 
	echo "[WARNING] iCloud login is NOT turned off"
	exit 1;
fi

defaults read /System/Library/User\ Template/Enlish.lproj/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup >> ./results.txt

sleep 1

######################################################################################################################################

# THIS SECTION CHECKS THAT THE INFRARED RECEIVER IS DISABLED

echo "[i] Checking infrared receiver is disabled"

infraredoff=$(defaults read /Library/Preferences/com.apple.driver.AppleIRController.plist DeviceEnabled)
infraredoffcorrect="false"

if [ "$infraredoff" == "$infraredoffcorrect" ]; then
	echo "[YES] Infrared Receiver is disabled"
else 
	echo "[WARNING] Infrared Receiver is NOT disabled"
        exit 1;
fi

defaults read /Library/Preferences/com.apple.driver.AppleIRController.plist DeviceEnabled >> ./results.txt

sleep 1

######################################################################################################################################

# THIS SECTION CHECKS THAT BLUETOOTH IS DISABLED

echo "[i] Checking BlueTooth is disabled"

bluetooth=$(defaults read /Library/Preferences/com.apple.Bluetooth.plist  ControllerPowerState)
bluetoothcorrect="0"

if [ "$bluetooth" == "$bluetoothcorrect" ]; then
        echo "[YES] Bluetooth is disabled"
else 
	echo "[WARNING] Bluetooth is NOT disabled"
        exit 1;
fi

defaults read /Library/Preferences/com.apple.Bluetooth.plist  ControllerPowerState >> ./results.txt

sleep 1

######################################################################################################################################

# THIS SECTION CHECKS THAT AUTOMATIC UPDATES ARE ENABLED

echo "[i] Checking that automatic updates are enabled"

updates=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled)
updatescorrect="true"

if [ "$updates" == "$updatescorrect" ]; then
        echo "[YES] Automatic updates are enabled"
else 
	echo "[WARNING] Automatic updates are NOT enabled"
        exit 1;
fi

defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled >> ./results.txt

sleep 1

######################################################################################################################################

# THIS SECTION CHECKS THAT PASSWORD HINTS ARE TURNED OFF

echo "[i] Checking that password hints are turned off"

hints=$(defaults write com.apple.loginwindow RetriesUntilHint)
hintscorrect="0"

if [ "$hints" == "$hintscorrect" ]; then
        echo "[YES] Password hints are disabled"
else 
	echo "[WARNING] Password hints are NOT disabled"
        exit 1;
fi

defaults write com.apple.loginwindow RetriesUntilHint >> ./results.txt

sleep 1

######################################################################################################################################

# THIS SECTION CHECKS THE STATUS OF THE SCREENLOCK TIMEOUT AND CONFIRMS IT IS SET AT 5 MINUTES

echo "[I] Confirming that the password-protected screen lock is enabled and set at 5 minutes"

disname=$(system setup -getdisplaysleep)
disnamecorrect="Display Sleep: after 5 minutes"

if [ "$disname" == "$disnamecorrect" ]; then
	echo "[YES] The screen lock timeout is set at 5 minutes"
else 
	echo "[WARNING] The screen lock timeout is NOT set at 5 minutes"
	systemsetup -getdisplaysleep
	exit 1;
fi

systemsetup -getdisplaysleep >> ./results.txt

askforpassword=$(defaults read com.apple.screensaver askForPassword)
askforpasswordcorrect="1"

if [ "$askforpassword" == "askforpasswordcorrect" ]; then
	echo "[YES] The screenlock asks for the user's password after locking"
else
	echo "[WARNING] The screenlock does NOT ask for the user's password after locking"
	exit 1;
fi

defaults read com.apple.screensaver askForPassword >> ./results.txt

sleep 1

######################################################################################################################################

# THIS SECTION CONFIRMS THE FIREWALL IS TURNED ON
# I need to find out what the output from each command is and then add that to the $_x_correct variables otherwise this probably wont work

echo "[i] Confirming the Firewall is enabled"

firewallon=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate)
firewalloncorrect="on" # WILL NEED CHANGING ONCE I KNOW WHAT THE OUTPUT FROM THE SOCKETFILTER COMMAND IS

if [ "$firewallon" == "firewalloncorrect" ]; then
	echo "[YES] The firewall is enabled"
else
	echo "[WARNING] The firewall is NOT enabled"
	exit 1;
fi

/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate >> ./results.txt

firewalllog=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getloggingmode)
firewalllogcorrect="on" # WILL NEED CHANGING ONCE I KNOW WHAT THE OUTPUT FROM THE SOCKETFILTER COMMAND IS

if [ "$firewalllog" == "firewalllogcorrect" ]; then
	echo "[YES] Firewall logging is enabled"
else
	echo "[WARNING] Firewall logging is NOT enabled"
	exit 1;
fi

/usr/libexec/ApplicationFirewall/socketfilterfw --getloggingmode >> ./results.txt

sleep 1
######################################################################################################################################

# THIS SECTION CONFIRMS THE FIRMWARE PASSWORD IS SET

echo "[I] Confirming that a firmware password is set"

firmware=$(firmwarepasswd -check)
firmwarecorrect="yes" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS

if [ "$firmware" == "$firmwarecorrect" ]; then
	echo "[YES] The firmware password is set"
else
	echo "[WARNING] The firmware password has NOT been set"
	exit 1;
fi

firmwarepasswd -check >> ./results.txt

sleep 1

######################################################################################################################################

#THIS SECTION CONFIRMS IF THE SYSTEM INTEGRITY PROTECTION IS ENABLED

#csrutil status
#sleep 2
######################################################################################################################################

#THIS SECTION ENABLES GATEKEEPER
#spctl --master-enable
#echo "[I] Gatekeeper is now enabled"
#sleep 2
######################################################################################################################################

#THIS SECTION SETS THE SYSTEM AND USERWIDE UMASK TO 022
#echo "[I] Setting system wide and user umask to 022"
#launchctl config system umask 022
#sleep 2
######################################################################################################################################

#THIS SECTION STOPS THE SENDING OF DIAGNOSTIC INFO TO APPLE
#echo "[I] Stopping this machine from sending diagnostic info to Apple"
#defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -bool FALSE
#sleep 2

######################################################################################################################################

#THIS SECTION ADDS THE LOGON BANNER
#echo "[I] Adding the logon banner"
#printf '%s\n' '[REPLACE THIS WITH THE NAME OF YOUR COMPANY i.e. Gihub Plc]' 'Unauthorised use of this system is an offence under the Computer Misuse Act 1990.' 'Unless authorised by [YOUR COMPANY] do not proceed. You must not abuse your' 'own system access or use the system under another User ID.' > /Library/Security/PolicyBanner.txt
#sleep 2
######################################################################################################################################

#THIS SECTION DISABLES CONSOLE LOGON
#echo "[I] Disabling console logon from the logon screen"
#defaults write /Library/Preferences/com.apple.loginwindow.plist DisableConsoleAccess -bool TRUE
#sleep 2
######################################################################################################################################

#THIS SECTION RESTRICTS SUDO TO A SINGLE COMMAND
#echo "[I] Restricting sudo authentication to a single command"
#sed -i.bk 's/^Defaults[[:blank:]]timestamp_timeout.*$//' /etc/sudoers; echo "Defaults timestamp_timeout=0">>/etc/sudoers; rm /etc/sudoers.bk
#sleep 2
######################################################################################################################################

#THIS SECTION REMOVES THE LIST OF USERS FROM THE LOGIN SCREEN
#echo "[I] Removing the list of users from the login screen"
#defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -int 1
#sleep 2
######################################################################################################################################

#THIS SECTION DISABLES SIRI - SOZ NOT SOZ
#echo "[I] Disabling Siri"
#defaults write ~/Library/Preferences/com.apple.assistant.support.plist "Assistant Enabled" -int 0; killall -TERM Siri; killall -TERM cfpre$
#sleep 2
######################################################################################################################################

#THIS SECTION TURNS ON FILE EXTENTIONS
#echo "[I] Turning on file extentions which are hidden by default"
#defaults write ~/Library/Preferences/.GlobalPreferences.plist AppleShowAllExtensions -bool TRUE; killall -HUP Finder; killall -HUP cfprefsd
#sleep 2
######################################################################################################################################

#THIS SECTION PREVENTS OTHER APPLICATIONS FROM INTERCEPTING TEXT TYPED IN TO TERMINAL
#echo "[I] Enabling secure Terminal keyboard to prevent other applications from intercepting anything typed in to terminal"
#defaults write ~/Library/Preferences/com.apple.Terminal.plist SecureKeyboardEntry -int 1
######################################################################################################################################

#THIS SECTION PREVENTS DOWNLOADED SIGNED SOFTWARE FROM RECIEVING INCOMING CONNECTIONS
#echo "[I] Preventing signed downloads from recieving incoming connections"
#/usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
#sleep 2
######################################################################################################################################

#THIS SECTION ENABLES PACKET FILTER (PF)
#echo "[I] Enabling packet filter (pf)"
#pfctl -e 2> /dev/null; cp /System/Library/LaunchDaemons/com.apple.pfctl.plist /Library/LaunchDaemons/sam.pfctl.plist; /usr/libexec/PlistBuddy -c "Add :ProgramArguments:1 string -e" /Library/LaunchDaemons/sam.pfctl.plist; /usr/libexec/PlistBuddy -c "Set:Label sam.pfctl" /Library/LaunchDaemons/sam.pfctl.plist; launchctl enable system/sam.pfctl; launchctl bootstrap system /Library/LaunchDaemons/sam.pfctl.plist; echo 'anchor "sam_pf_anchors"'>>/etc/pf.conf; echo 'load anchor "sam_pf_anchors" from "/etc/pf.anchors/sam_pf_anchors"'>>/etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FIREWALL TO BLOCK INCOMING APPLE FILE SERVER
#echo "[I] Configuring the FW to block incoming Apple file server requests"
#echo "#apple file service pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto tcp to any port {548}">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FIREWALL TO BLOCK BONJOUR PACKETS
#echo "[I] Configuring the FW to block Bonjour packets"
#echo "#bonjour pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block proto udp to any port 1900">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK FINGER PACKETS - GIGGITY
#echo "[I] Configuring the FW to block finger packets"
#echo "#finger pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block proto tcp to any port 79">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK FTP
#echo "[I] Configuring the FW to block FTP traffic"
#echo "#FTP pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto { tcp udp } to any port { 20 21 }">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK HTTP
#echo "[I] Configuring the FW to block incoming HTTP"
#echo "#http pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto { tcp udp } to any port 80">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK ICMP
#echo "[I] Configuring the FW to block icmp packets"
#echo "#icmp pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto icmp">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK IMAP
#echo "[I] Configuring the FW to block IMAP packets"
#echo "#imap pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto tcp to any port 143">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK IMAPS
#echo "[I] Configuring the FW to block IMAPS packets"
#echo "#imaps pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto tcp to any port 993">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK iTUNES SHARING PACKETS
#echo "[I] Configuring the FW to block iTunes sharing packets"
#echo "#iTunes sharing pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block proto tcp to any port 3689">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK mDNSResponder packets
#echo "[I] Configuring the FW to block mDNSResponder packets"
#echo "#mDNSResponder pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block proto udp to any port 5353">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK NFS PACKET
#echo "[I] Configuring the FW to block NFS packets"
#echo "#nfs pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block proto tcp to any port 2049">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK OPTICAL DRIVE SHARING PACKETS
#echo "[I] Configuring the FW to block Optical Drive Sharing packets"
#echo "#optical drive sharing pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block proto tcp to any port 49152">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK POP3 PACKETS
#echo "[I] Configuring the FW to block POP3 packets"
#echo "#pop3 pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto tcp to any port 110">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK POP3S PACKETS
#echo "[I] Configuring the FW to block Optical Drive Sharing packets"
#echo "#pop3s pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto tcp to any port 995">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2

######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK PRINTER SHARING PACKETS
#echo "[I] Configuring the FW to block Printer Sharing packets"
#echo "#printer sharing pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto tcp to any port 631">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2

######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK REMOTE APPLE EVENTS PACKETS
#echo "[I] Configuring the FW to block Remote Apple Events packets"
#echo "#remote apple events pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in  proto tcp to any port 3031">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2

######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK SCREEN SHARING PACKETS
#echo "[I] Configuring the FW to block Screen Sharing packets"
#echo "#screen sharing pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto tcp to any port 5900">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2

######################################################################################################################################

#THIS SECTION CONFIGURES THE FW TO BLOCK SMB PACKETS
#echo "[I] Configuring the FW to block SMB packets"
#echo "#smb pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block proto tcp to any port { 139 445 }; block proto udp to any port {137 138}">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################


#THIS SECTION CONFIGURES THE FW TO BLOCK SMTP PACKETS
#echo "[I] Configuring the FW to block smtp packets"
#echo "#smtp pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto tcp to any port 25">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################


#THIS SECTION CONFIGURES THE FW TO BLOCK SSH PACKETS
#echo "[I] Configuring the FW to block SSH packets"
#echo "#ssh pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto { tcp udp} to any port 22">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################


#THIS SECTION CONFIGURES THE FW TO BLOCK TELNET PACKETS
#echo "[I] Configuring the FW to block telnet"
#echo "#telnet pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block in proto { tcp udp } to any port 23">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################


#THIS SECTION CONFIGURES THE FW TO BLOCK TFTP PACKETS
#echo "[I] Configuring the FW to block tftp packets"
#echo "#tftp pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block proto { tcp udp } to any port 69">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################


#THIS SECTION CONFIGURES THE FW TO BLOCK UUCP PACKETS
#echo "[I] Configuring the FW to block uucp packets"
#echo "#uucp pf firewall rule">>"/etc/pf.anchors/sam_pf_anchors";echo "block proto tcp to any port 540">>"/etc/pf.anchors/sam_pf_anchors";pfctl -f /etc/pf.conf
#sleep 2
######################################################################################################################################

#THIS SECTION PREVENTS ANY ACTION WHEN INSERTING A BLANK CD
#echo "[I] Preventing any actions when a blank CD is inserted"
#defaults write ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.blank.cd.appeared -dict action -int 1; killall -HUP SystemUIServer; killall -HUP cfprefsd
#sleep 2

######################################################################################################################################

#THIS SECTION PREVENTS ANY ACTION WHEN INSERTING A BLANK DVD
#echo "[I] Preventing any actions when a blank DVD is inserted"
#defaults write ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.blank.dvd.appeared -dict action -int 1; killall -HUP SystemUIServer; killall -HUP cfprefsd
#sleep 2
######################################################################################################################################

#THIS SECTION PREVENTS ANY ACTION WHEN INSERTING A MUSIC CD
#echo "[I] Preventing any actions when a music CD is inserted"
#defaults write ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.cd.music.appeared -dict action -int 1; killall -HUP SystemUIServer; killall -HUP cfprefsd
#sleep 2
######################################################################################################################################

#THIS SECTION PREVENTS ANY ACTION WHEN INSERTING A PICTURE CD
#echo "[I] Preventing any actions when a picture CD is inserted"
#defaults write ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.cd.picture.appeared -dict action -int 1; killall -HUP SystemUIServer; killall -HUP cfprefsd
#sleep 2
######################################################################################################################################

#THIS SECTION PREVENTS ANY ACTION WHEN INSERTING A VIDEO DVD
#echo "[I] Preventing any actions when a DVD containing video is inserted"
#defaults write ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.dvd.video.appeared -dict action -int 1; killall -HUP SystemUIServer; killall -HUP cfprefsd
#sleep 2
######################################################################################################################################

#THIS SECTION DISABLES THE FILE SHARING DAEMON
#echo "[I] Disabling the filesharing daemon"
#launchctl disable system/com.apple.smbd; launchctl bootout system/com.apple.smbd; launchctl disable system/com.apple.AppleFileServer; launchctl bootout system/com.apple.AppleFileServer
#sleep 2
######################################################################################################################################

#THIS SECTION DISABLES BLUETOOTH
#echo "[I] Disabling bluetooth"
#launchctl disable system/com.apple.blued; launchctl bootout system/com.apple.blued
#sleep 2
######################################################################################################################################

#THIS SECTION PREVENTS THE COMPUTER FROM BROADCASTING BONJOUR SERVICE ADVERTS
#echo "[I] Preventing the computer from broadcasting Bonjour service advertisements"
#defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true
#sleep 2
######################################################################################################################################

#THIS SECTION DISABLES NFS SERVER DAEMON
#echo "[I] Disabling the NFS server daemon"
#launchctl disable system/com.apple.nfsd; launchctl bootout system/com.apple.nfsd; launchctl disable system/com.apple.lockd; launchctl bootout system/com.apple.lockd; launchctl disable system/com.apple.statd.notify; launchctl bootout system/com.apple.statd.notify
#sleep 2
######################################################################################################################################

#THIS SECTION DISABLES THE PUBLIC KEY AUTHENTICATION MECHANISM
#echo "[I] Disabling the public key authentication mechanism for SSH"
#sed -i.bak 's/.*PubkeyAuthentication.*/PubkeyAuthentication no/' /etc/ssh/sshd_config
#sleep 2
######################################################################################################################################

#THIS SECTION PREVENTS ROOT LOGIN VIA SSH
#echo "[I] Preventing root login via SSH"
#sed -i.bak 's/.*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
#sleep 2
######################################################################################################################################

#THIS SECTION SETS THE NUMBER OF CLIENT ALIVE MESSAGES
#echo "[I] Setting the number of client alive messages that can be sent without the sshd recieving a response to 0 before it disconnects"
#sed -i.bak 's/.*ClientAliveCountMax.*/ClientAliveCountMax 0/' /etc/ssh/sshd_config
#sleep 2
######################################################################################################################################

#THIS SECTION LIMITS THE NUMBER OF AUTHENTICATION ATTEMPTS BEFORE DISCONNECTING THE CLIENT
#echo "[I] Setting the number of authentication attempts before disconnecting the client to four"
#sed -i.bak 's/.*maxAuthTries.*/maxAuthTries 4/' /etc/ssh/sshd_config
#sleep 2
######################################################################################################################################

currentlocation=$(pwd -P)

echo "[i] The script has now completed. The results are contained in " $pwd "/.results.txt"

done
