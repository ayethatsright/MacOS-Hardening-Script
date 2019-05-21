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

# THIS SECTION GETS A LIST OF USERS FROM THE SUDOERS FILE

echo "[i] The following users are in the sudoers file: "

cat /etc/sudoers | tee -a ./results.txt

sleep 1

######################################################################################################################################

# Getting the hostname and setting it as a variable

echo "[I] Getting the machines hostname:"

set DEVNAME=scutil --get HostName

echo "[i] The machine's hostname is: " $DEVNAME | tee -a ./results.txt

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

echo "[i] Confirming that the password-protected screen lock is enabled and set at 5 minutes"

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

echo "[i] Confirming if the screenlock requires a password after locking"

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

# THIS SECTION CONFIRMS IF THE SYSTEM INTEGRITY PROTECTION IS ENABLED

echo "[i] Confirming if System Integrity Protection is enabled"

csrutil status | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS IF GATEKEEPER IS ENABLED

echo "[i] Confirming the status of gatekeeper"

spctl --status | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT THE SYSTEM AND USER WIDE UMASK IS SET TO 022

echo "[i] Confirming the system wide and user umask"

umaskvar=$(umask -S)
umaskval="022"

if [ "$umaskvar" == "$umaskval" ]; then
	echo "[YES] The umask value is set at 022"
else
	echo "[WARNING] The umask value is NOT set at 022"
	exit 1;
fi

umask | tee -a ./results

sleep 2

######################################################################################################################################

#THIS SECTION CONFIRMS THAT THE MACHINE IS NOT SENDING DIAGNOSTIC INFO TO APPLE

echo "[I] Confirming that the machine is not sending diagnostic info to Apple"

diag=$(defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit)
diagconfirm="FALSE" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS

if [ "$diag" == "$diagconfirm" ]; then
	echo "[YES] The machine isn't sending diagnostic info to Apple"
else
	echo "[WARNING] The machine IS sending diagnostic info to Apple"
	exit 1;
fi

defaults read /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRM THE CONTENTS OF THE LOGON BANNER

echo "[i] The logon banner is set as: "
cat /Library/Security/PolicyBanner.txt | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT CONSOLE LOGON IS DISABLED

echo "[i] Confirming that console logon is disabled "

console=$(defaults read /Library/Preferences/com.apple.loginwindow.plist DisableConsoleAccess)
consoleconfirm="TRUE" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS

if [ "$console" == "$consoleconfirm" ]; then
	echo "[YES] Console logon is currently disabled"
else
	echo "[WARNING] Console login is NOT currently disabled"
	exit 1;
fi

defaults read /Library/Preferences/com.apple.loginwindow.plist DisableConsoleAccess | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT SUDO IS RESTRICTED TO A SINGLE COMMAND

echo "[i] Confirming that sudo is restricted to a single command"

sudores=$(cat /etc/sudoers | grep -i "Defaults timestamp_timeout=" | grep -o '.$')
sudoresconfirm="0"

if [ "$sudores" == "$sudoresconfirm" ]; then
	echo "[YES] sudo is restricted to a single command"
else
	echo "[WARNING] sudo is NOT restricted to a single command"
	exit 1;
fi

cat /etc/sudoers | grep -i "Defaults timestamp_timeout=" | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT THE LIST OF USERS HAS BEEN REMOVED FROM THE LOGIN SCREEN

echo "[i] Confirming that the list of users has been removed from the login screen"

listu=$(defaults read /Library/Preferences/com.apple.loginwindow SHOWFULLNAME)
listuconfirm="1" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS

if [ "$listu" == "$listuconfirm" ]; then
	echo "[YES] The list of users has been removed from the login screen"
else
	echo "[WARNING] This list of users is still displayed on the login screen"
	exit 1;
fi

defaults read /Library/Preferences/com.apple.loginwindow SHOWFULLNAME | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT SIRI HAS BEEN DISABLED

echo "[i] Confirming SIRI has been disabled"

siri=$(defaults read ~/Library/Preferences/com.apple.assistant.support.plist "Assistant Enabled")
siriconfirm="0" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS

if [ "$siri" == "$siriconfirm" ]; then
	echo "[YES] SIRI has been disabled"
else
	echo "[WARNING] SIRI has NOT been disabled"
	exit 1;
fi

defaults read ~/Library/Preferences/com.apple.assistant.support.plist "Assistant Enabled" | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS IF FILE EXTENTIONS ARE TURNED ON

echo "[i] Confirming that hidden file extentions are turned on"

fileex=$(defaults read ~/Library/Preferences/.GlobalPreferences.plist AppleShowAllExtensions)
fileexconfirm="TRUE" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS

if [ "$fileex" == "$fileexconfirm" ]; then
	echo "[YES] Hidden file extensions will be shown"
else
	echo "[WARNING] Hidden file extensions are DISABLED"
	exit 1;
fi

defaults read ~/Library/Preferences/.GlobalPreferences.plist AppleShowAllExtensions | tee -a ./results.txt

sleep 2

######################################################################################################################################

#THIS SECTION CONFIRMS THAT OTHER APPLICATIONS CANNOT INTERCEPT THE TEXT TYPED IN TO THE TERMINAL

echo "[i] Confirming that the secure Terminal keyboard is enabled"

termi=$(defaults read ~/Library/Preferences/com.apple.Terminal.plist SecureKeyboardEntry)
termiconfirm="1" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS

if [ "$termi" == "$termiconfirm" ]; then
	echo "[YES] The secure terminal keyboard is enabled"
else
	echo "[WARNING] The secure terminal keyboard is NOT enabled"
	exit 1;
fi

defaults read ~/Library/Preferences/com.apple.Terminal.plist SecureKeyboardEntry | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT DOWNLOADED SIGNED SOFTWARE CANNOT RECIEVE INCOMING CONNECTIONS

echo "[i] Confirming that signed downloads are prevented from recieving incoming connections"

asigned=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getallowsigned | grep -i "NEED TO KNOW OUTPUT OF THE GETALLOWSIGNED COMMAND AND THEN GREP TO JUST TAKE THE DOWNLOADED SIGNED RESULT AND NOT THE INBUILT SYSTEM SIGNED RESULT")
asignedconfirm="off"  # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS

if [ "$asigned" == "$asignedconfirm" ]; then
	echo "[YES] Downloaded signed software cannot recieve incoming connections by default"
else
	echo "[WARNING] Downloaded signed software CAN recieve incoming connections by default"
	exit 1;
fi

/usr/libexec/ApplicationFirewall/socketfilterfw --getallowsigned | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT PACKET FILTER (PF) IS ENABLED

echo "[i] Confirming that packet filter (pf) is enabled"

pfenab=$(pfctl -s info | egrep -i 'enabled|disabled')
pfenabconfirm="enabled"

if [ "$pfenab" == "$pfenabconfirm" ]; then
	echo "[YES] pf is enabled"
else
	echo "[WARNING] pf is NOT enabled"
	exit 1;
fi

pfctl -s info | egrep -i 'enabled|disabled' | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT THE FIREWALL IS CONFIGURED TO BLOCK INCOMING APPLE FILE SERVER

echo "[i] Confirming that all the necessary FW rules are in place"

ftprule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto { tcp udp } to any port { 20 21 }")
bonjourrule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block proto udp to any port 1900")
fingerrule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block proto tcp to any port 79")
httprule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto { tcp udp } to any port 80")
icmprule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto icmp")
imaprule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto tcp to any port 143")
imapsrule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto tcp to any port 993")
itunesrule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block proto tcp to any port 3689")
mdnsrule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block proto udp to any port 5353")
nfsrule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block proto tcp to any port 2049")
opticalrule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block proto tcp to any port 49152")
pop3rule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto tcp to any port 110")
pop3srule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto tcp to any port 995")
printerrule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto tcp to any port 631")
remoterule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in  proto tcp to any port 3031")
screenrule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto tcp to any port 5900")
smbrule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block proto tcp to any port { 139 445 }; block proto udp to any port {137 138}")
smtprule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto tcp to any port 25")
sshrule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto { tcp udp} to any port 22")
telnetrule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto { tcp udp } to any port 23")
tftprule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block proto { tcp udp } to any port 69")
uucprule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block proto tcp to any port 540")
applerule=$(cat /etc/pf.anchors/sam_pf_anchors | grep -i "block in proto tcp to any port {548}")

ftpruleconfirm="block in proto { tcp udp } to any port { 20 21 }"
bonjourruleconfirm="block proto udp to any port 1900"
fingerruleconfirm="block proto tcp to any port 79"
httpruleconfirm="block in proto { tcp udp } to any port 80"
icmpruleconfirm="block in proto icmp"
imapruleconfirm="block in proto tcp to any port 143"
imapsruleconfirm="block in proto tcp to any port 993"
itunesruleconfirm="block proto tcp to any port 3689"
mdnsruleconfirm="block proto udp to any port 5353"
nfsruleconfirm="block proto tcp to any port 2049"
opticalruleconfirm="block proto tcp to any port 49152"
pop3ruleconfirm="block in proto tcp to any port 110"
pop3sruleconfirm="block in proto tcp to any port 995"
printerruleconfirm="block in proto tcp to any port 631"
remoteruleconfirm="block in  proto tcp to any port 3031"
screenruleconfirm="block in proto tcp to any port 5900"
smbruleconfirm="block proto tcp to any port { 139 445 }; block proto udp to any port {137 138}"
smtpruleconfirm="block in proto tcp to any port 25"
sshruleconfirm="block in proto { tcp udp} to any port 22"
telnetruleconfirm="block in proto { tcp udp } to any port 23"
tftpruleconfirm="block proto { tcp udp } to any port 69"
uucpruleconfirm="block proto tcp to any port 540"
appleruleconfirm="block in proto tcp to any port {548}"

if [ "$ftprule" == "$ftpruleconfirm" ]; then
	echo "[YES] FTP rule is enabled"
else
	echo "[WARNING] FTP rule is NOT enabled"
	exit 1;
fi

if [ "$bonjourrule" == "$bonjourruleconfirm" ]; then
	echo "[YES] Bonjour rule is enabled"
else
	echo "[WARNING] Bonjour rule is NOT enabled"
	exit 1;
fi

if [ "$fingerrule" == "$fingerruleconfirm" ]; then
	echo "[YES] Finger rule is enabled"
else
	echo "[WARNING] Finger rule is NOT enabled"
	exit 1;
fi

if [ "$httprule" == "$httpruleconfirm" ]; then
	echo "[YES] HTTP rule is enabled"
else
	echo "[WARNING] HTTP rule is NOT enabled"
	exit 1;
fi

if [ "$icmprule" == "$icmpruleconfirm" ]; then
	echo "[YES] ICMP rule is enabled"
else
	echo "[WARNING] ICMP rule is NOT enabled"
	exit 1;
fi

if [ "$imaprule" == "$imapruleconfirm" ]; then
	echo "[YES] IMAP rule is enabled"
else
	echo "[WARNING] IMAP rule is NOT enabled"
	exit 1;
fi

if [ "$imapsrule" == "$imapsruleconfirm" ]; then
	echo "[YES] IMAPS rule is enabled"
else
	echo "[WARNING] IMAPS rule is NOT enabled"
	exit 1;
fi

if [ "$itunesrule" == "$itunesruleconfirm" ]; then
	echo "[YES] iTune Sharing rule is enabled"
else
	echo "[WARNING] iTune Sharing rule is NOT enabled"
	exit 1;
fi

if [ "$mdnsrule" == "$mdnsruleconfirm" ]; then
	echo "[YES] mDNSResolver rule is enabled"
else
	echo "[WARNING] mDNSResolver rule is NOT enabled"
	exit 1;
fi

if [ "$nfsrule" == "$nfsruleconfirm" ]; then
	echo "[YES] NFS rule is enabled"
else
	echo "[WARNING] NFS rule is NOT enabled"
	exit 1;
fi

if [ "$opticalrule" == "$opticalruleconfirm" ]; then
	echo "[YES] Optical Sharing rule is enabled"
else
	echo "[WARNING] Optical Sharing rule is NOT enabled"
	exit 1;
fi

if [ "$pop3rule" == "$pop3ruleconfirm" ]; then
	echo "[YES] POP3 rule is enabled"
else
	echo "[WARNING] POP3 rule is NOT enabled"
	exit 1;
fi

if [ "$pop3srule" == "$pop3sruleconfirm" ]; then
	echo "[YES] POP3S rule is enabled"
else
	echo "[WARNING] POP3S rule is NOT enabled"
	exit 1;
fi

if [ "$printerrule" == "$printerruleconfirm" ]; then
	echo "[YES] Printer Sharing rule is enabled"
else
	echo "[WARNING] Printer Sharing rule is NOT enabled"
	exit 1;
fi

if [ "$remoterule" == "$remoteruleconfirm" ]; then
	echo "[YES] Remote support rule is enabled"
else
	echo "[WARNING] Remote support rule is NOT enabled"
	exit 1;
fi

if [ "$screenrule" == "$screenruleconfirm" ]; then
	echo "[YES] Screen Sharing rule is enabled"
else
	echo "[WARNING] Screen Sharing rule is NOT enabled"
	exit 1;
fi

if [ "$smbrule" == "$smbruleconfirm" ]; then
	echo "[YES] SMB rule is enabled"
else
	echo "[WARNING] SMB rule is NOT enabled"
	exit 1;
fi

if [ "$smtprule" == "$smtpruleconfirm" ]; then
	echo "[YES] SMTP rule is enabled"
else
	echo "[WARNING] SMTP rule is NOT enabled"
	exit 1;
fi

if [ "$sshrule" == "$sshruleconfirm" ]; then
	echo "[YES] SSH rule is enabled"
else
	echo "[WARNING] SSH rule is NOT enabled"
	exit 1;
fi

if [ "$telnetrule" == "$telnetruleconfirm" ]; then
	echo "[YES] Telnet rule is enabled"
else
	echo "[WARNING] Telnet rule is NOT enabled"
	exit 1;
fi

if [ "$tftprule" == "$tftpruleconfirm" ]; then
	echo "[YES] TFTP rule is enabled"
else
	echo "[WARNING] TFTP rule is NOT enabled"
	exit 1;
fi

if [ "$uucprule" == "$uucpruleconfirm" ]; then
	echo "[YES] UUCP rule is enabled"
else
	echo "[WARNING] UUCP rule is NOT enabled"
	exit 1;
fi

if [ "$applerule" == "$appleruleconfirm" ]; then
	echo "[YES] Apple Remote Event rule is enabled"
else
	echo "[WARNING] Apple Remote Event rule is NOT enabled"
	exit 1;
fi

echo "########################################################################" >> ./results.txt
echo "The following rules are contained in the firewall ruleset: " >> ./results.txt
echo "#" >> ./results.txt
echo "#" >> ./results.txt
cat /etc/pf.anchors/sam_pf_anchors >> ./results.txt
echo "#" >> ./results.txt
echo "#" >> ./results.txt
echo "########################################################################" >> ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS NO ACTION WILL BE PERFORMED WHEN INSERTING VARIOUS MEDIA

echo "[i] Confirming there is no action when a various media are inserted"

blankcd=$(defaults read ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.blank.cd.appeared)
blankcdconfirm="1" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS
blankdvd=$(defaults read ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.blank.dvd.appeared)
blankdvdconfirm="1" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS
musiccd=$(defaults read ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.cd.music.appeared)
musiccdconfirm="1" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS
picturecd=$(defaults read ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.cd.picture.appeared)
picturecdconfirm="1" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS
videodvd=$(defaults read ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.dvd.video.appeared)
videodvdconfirm="1" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS

if [ "$blankcd" == "$blankcdconfirm" ]; then
	echo "[YES] No action is taken when a blank cd is inserted"
else
	echo "[WARNING] Automatic action will be taken when a blank cd is inserted"
	exit 1;
fi

if [ "$blankdvd" == "$blankdvdconfirm" ]; then
	echo "[YES] No action is taken when a blank dvd is inserted"
else
	echo "[WARNING] Automatic action will be taken when a blank dvd is inserted"
	exit 1;
fi

if [ "$musiccd" == "$musiccdconfirm" ]; then
	echo "[YES] No action is taken when a music cd is inserted"
else
	echo "[WARNING] Automatic action will be taken when a music cd is inserted"
	exit 1;
fi

if [ "$picturecd" == "$picturecdconfirm" ]; then
	echo "[YES] No action is taken when a picture cd is inserted"
else
	echo "[WARNING] Automatic action will be taken when a picture cd is inserted"
	exit 1;
fi

if [ "$videodvd" == "$videodvdconfirm" ]; then
	echo "[YES] No action is taken when a video dvd is inserted"
else
	echo "[WARNING] Automatic action will be taken when a video dvd is inserted"
	exit 1;
fi

defaults read ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.blank.cd.appeared >> ./results.txt
defaults read ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.blank.dvd.appeared >> ./results.txt
defaults read ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.cd.music.appeared >> ./results.txt
defaults read ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.cd.picture.appeared >> ./results.txt
defaults read ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.dvd.video.appeared >> ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT THE FILE SHARING DAEMON IS DISABLED

echo "[i] Confirming that the file sharing daemon is disabled"

fileserver=$(launchctl print system | grep -c smbd; launchctl print system | grep -c AppleFileServer)
fileserverconfirm="enabled" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS

if [ "$fileserver" == "$fileserverconfirm" ]; then
	echo "[YES] Filesharing daemon is disabled"
else
	echo "[WARNING] Filesharing daemon is NOT disabled"
	exit 1;
fi

launchctl print system | grep -c smdb; launchctl print system | grep -c AppleFileServer >> ./results.txt

# might just be able to get away with 'launchctl print system | grep -c smbd; launchctl print system | grep -c AppleFileServer | tee -a ./results.txt' instead of setting the variables and then using the 'if' statement.

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT BONJOUR SERVICE ADVERTISEMENTS ARE PREVENTED FROM BROADCASTING

echo "[i] Confirming that the computer is prevented from broadcasting Bonjour service advertisements"

bonsa=$(defaults read /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements)
bonsaconfirm="true" # WILL NEED TO UPDATE ONCE I KNOW WHAT THE OUTPUT OF THE COMMAND ACTUALLY IS

if [ "$bonsa" == "$bonsaconfirm" ]; then
	echo "[YES] This computer is prevented from broadcasting bonjour service advertisements"
else
	echo "[WARNING] The computer is broadcasting bonjour service advertisements"
	exit 1;
fi

defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements >> ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT THE NFS SERVER DAEMON IS DISABLED

echo "[i] Confirming the NFS server daemon is disabled"

launchctl print system | grep -c nfsd; launchctl print system | grep -c lockd; launchctl print system | grep -c statd.notify | tee -a ./results.txt

# If this doesn't work, will need to run launchctl and set the output as a variable then use the variable in an 'if' statement.

sleep 2
######################################################################################################################################

# THIS SECTION DISABLES THE PUBLIC KEY AUTHENTICATION MECHANISM

echo "[i] Disabling the public key authentication mechanism for SSH"

pubkey=$(grep -E 'PubkeyAuthentication (yes|no)' /etc/ssh/sshd_config)
pubkeyconfirm="no"

if [ "$pubkey" == "pubkeyconfirm" ]; then
	echo "[YES] Public key authentication for SSH is disabled"
else
	echo "[WARNING] Public key authentication for SSH is NOT disabled"
	exit 1;
fi

grep -E 'PubkeyAuthentication (yes|no)' /etc/ssh/sshd_config | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT ROOT LOGIN VIA SSH IS PREVENTED

echo "[i] Confirming that root login via SSH is prevented"

rootlogin=$(grep -E '^[#]PermitRootLogin' /etc/ssh/sshd_config)
rootloginconfirm="no"

if [ "$rootlogin" == "$rootloginconfirm" ]; then
	echo "[YES] Root login via SSH is prevented"
else
	echo "[WARNING] Root login via SSH is NOT being prevented"
	exit 1;
fi

grep -E '^[#]PermitRootLogin' /etc/ssh/sshd_config | tee -a ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THE NUMBER OF CLIENT ALIVE MESSAGES

echo "[i] Confirming that the number of client alive messages that can be sent without the sshd recieving a response is set to 0 before it disconnects"

alive=$(grep 'ClientAliveCountMax' /etc/ssh/sshd_config)

if [ "$alive" -ne "0" ]; then
	echo "[WARNING] The number of client alive messages is greater than 0"
	echo "[WARNING] The current number of client alive messages that will be send without a response is: " $alive
else
	echo "[YES] The number of client alive messages is 0"
	exit 1;
fi

grep 'ClientAliveCountMax' /etc/ssh/sshd_config >> ./results.txt

sleep 2

######################################################################################################################################

# THIS SECTION CONFIRMS THAT THE SSH SERVER WILL LIMIT FAILED LOGON ATTEMPTS TO 4

echo "[i] Confirming the SSH server limits the number of failed logon attempts to four"

maxauth=$(grep 'MaxAuthTries' /etc/ssh/sshd_config)

if [ "$maxauth" != "4" ]; then
	if [ "$maxauth" < "4" ]; then
		echo "[i] The maximum number of tries is less than 4"
		echo "[i] The maximum number of tries is set at: " $maxauth
	else
		echo "[WARNING] The maximum number of tries is MORE THAN 4"
		echo "[WARNING] The maximum number of tries is set at: " $maxauth
	fi
else
	echo "[YES] The maximum number of tries is set at 4"
	exit 1;
fi

grep 'MaxAuthTries' /etc/ssh/sshd_config >> ./results.txt

sleep 2

######################################################################################################################################

currentlocation=$(pwd -P)

echo "[i] The script has now completed. The results are contained in " $pwd "/.results.txt"

done
