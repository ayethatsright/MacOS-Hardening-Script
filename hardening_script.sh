#! /bin/bash

echo "[WARNING] THIS SCRIPT IS STILL UNDER DEV AND HASNT BEEN TESTED AT ALL YET"
echo "[WARNING] USE THE SCRIPT FROM THE MASTER BRANCH UNLESS YOU HAVE THE TIME TO TROUBLESHOOT THIS"

# MacOs 10.12 Hardening Script which will apply all the 'DRAFT NIST 800-179r1 macOS 10.12 Security
# Baseline' requirements for STANDALONE machines.

##################################################################################################

# CONFIRM THAT THE SCRIPT HAS BEEN RUN WITH SUDO

if [[ $UID -ne 0 ]]; then
	echo "Need to run this script as root (with sudo)"
	exit 1
fi
echo "[I] Beginning hardening script now"

##################################################################################################

# Changes all files in a user's home directory and subdirectories to be owned by that user

echo "[I] Changing all files in the user's home directory to be owned by that user"
find ~$USER ! -user $USER -print -exec chown $USER {} \
sleep 1

##################################################################################################

# Checks to see if the System Integrity Protection (SIP) subsystem is enabled
# Note: If not enabled, you need to boot in to system recovery to enable it, it can't be enabled
# through this script

echo "[I] Checking if System Integrity Protection (SIP) is enabled"
csrutil status
sleep 1

##################################################################################################

# Enables the security assessment policy (Gatekeeper) subsystem

echo "[I] Enabling the security assement policy (Gatekeeper) subsystem"
spctl --master-enable
sleep 1

##################################################################################################

# Changes all files in a user's home directory and subdirectories to be part of a group that the
# user belongs to

echo "[I] Changing all files in the user's home directory to be part of a group that the user belongs to"
find ~$USER ! -group `echo \`groups $USER | sed 's/ / -a ! -group /g'\`` -print -exec chgrp $GROUP {} \
sleep 1

##################################################################################################

# Prevents newly created files from being overly permissive

echo "[I] Preventing newly created files from being overly permissive"
launchctl config user umask 027
sleep 1

##################################################################################################

# Sets permissions on all user home directories to 700

echo "[I] Setting permissions on the user's home directories to 700"
for user in `dscl . -list /Users`; do uid=`id -u $user 2> /dev/null`; if [ "$uid" != "" ] && [ $uid -ge "500" ]; then chmod go-rwx /Users/$user; fi; done
sleep 1

##################################################################################################

# Sets a maximum file size for each log file

echo "[I] Setting maximum file size for each log file to 80M"
sed -i.bk "s/^filesz.*/filesz:80M/" /etc/security/audit_control; rm /etc/security/audit_control.bk
sleep 1

##################################################################################################

# Sets a maximum file age to ensure effective audit log retention

echo "[I] Setting a maximum file age to ensure audit log retention"
sed -i.bk "s/^expire-after.*/expire-after:30d AND 5G/" /etc/security/audit_control; rm /etc/security/audit_control.bk
sleep 1

##################################################################################################

# Disables automatic sending of diagnostic information to Apple

echo "[I] Disabling automatic sending of diagnostic information to Apple"
defaults write /Library/Application Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -bool false
sleep 1

##################################################################################################

# Sets a number of flags in the audit_control file to ensure effective auditing.

echo "[I] Setting a number of flags in the audit_control file to ensure effective auditing"
sed -i.bk "s/^flags.*/flags:lo,ad,-all,fd,fm,^-fa,^-fc,^-cl/" /etc/security/audit_control; rm /etc/security/audit_control.bk
sleep 1

##################################################################################################

# Creates policy text to be displayed on the command line at login

echo "[?] Please provide some policy text which can be displayed on the command line at login (i.e. Unauthorised use of this system... etc"
read -p "Please provide some appropriate text: " COMMANDTEXT
echo "$COMMANDTEXT" > /etc/motd
echo "[I] Setting the policy text to be displayed on the command line at login"
sleep 1

##################################################################################################

# Creates a policy banner to be displayed on the login screen

echo "[?] Please provide some policy text which can be displayed on the login screen"
read -p "Please provide some appropriate text: " LOGINTEXT
echo "$LOGINTEXT" > /Library/Security/PolicyBanner.txt
sleep 1

##################################################################################################

# Disables console login

echo "[I] Disabling console login"
defaults write /Library/Preferences/com.apple.loginwindow.plist DisableConsoleAccess -bool true
sleep 1

##################################################################################################

# Screensaver will start after 20 minutes or less of idle time

# FIRST WE HAVE TO GET THE MACHINE UUID AND SET IT AS A VARIABLE

echo "[I] Getting the UUID for this machine"
set UUID=system_profiler SPHardwareDataType | grep 'Hardware UUID' | awk ' { print $3 }'
echo "[I] UUID of this machine is: "
echo $UUID

#Now we can set the screensaver setting using that variable
echo "[I] Setting screensaver to start after 20 minutes of idle time"
defaults write ~/Library/Preferences/ByHost/com.apple.screensaver.$UUID.plist idleTime -int 1200; killall -HUP Dock; killall -HUP cfprefsd
sleep 1

# If you want to lower this value from 20 minutes (1200 seconds), change the 'idleTime -int 1200' value

##################################################################################################

# Password Policy Settings

echo "[I] Clearing the current Password Policy"
pwpolicy -clearaccountpolicies
sleep 1

echo "[I] Generating the new password plist file with the following options:"
sleep 1
echo "[I] Failed logins before locking = 3"
sleep 1
echo "[I] Lockout period = 15 minutes"
sleep 1
echo "[I] Password expiry = 60 days"
sleep 1
echo "[I] Minimum password length = 12 characters"
sleep 1
echo "[I] Minimum number of numeric characters = 1"
sleep 1
echo "[I] Minimum number of lower case letters = 1"
sleep 1
echo "[I] Minimum number of upper case letters = 1"
sleep 1
echo "[I] Minimum number of special characters = 1"
sleep 1
echo "[I] Password history = 15 passwords"
sleep 1
echo "[*] I know we shouldnt be mandating password changes after an arbitrary number of days but this is what NIST have set!  Dont hate me for it."
sleep 1 

FAILED=3                       # 3 failed logins before locking out the user
LOCKOUT=900                    # 15 min lockout period
PW_EXPIRE=60                   # password expires after 60 days
MIN_LENGTH=12	               # at least 12 chars for password
MIN_NUMERIC=1                  # at least 1 number in password
MIN_ALPHA_LOWER=1              # at least 1 lower case letter
MIN_UPPER_ALPHA=1              # at least 1 upper case letter
MIN_SPECIAL_CHAR=1             # at least 1 special character
PW_HISTORY=15                  # remember last 15 passwords

# Creates plist using the variables set above

echo "<dict>
<key>policyCategoryAuthentication</key>
  <array>
  <dict>
    <key>policyContent</key>
    <string>(policyAttributeFailedAuthentications &lt; policyAttributeMaximumFailedAuthentications) OR (policyAttributeCurrentTime &gt; (policyAttributeLastFailedAuthenticationTime + autoEnableInSeconds))</string>
    <key>policyIdentifier</key>
    <string>Authentication Lockout</string>
    <key>policyParameters</key>
  <dict>
  <key>autoEnableInSeconds</key>
  <integer>$LOCKOUT</integer>
  <key>policyAttributeMaximumFailedAuthentications</key>
  <integer>$FAILED</integer>
  </dict>
</dict>
</array>
<key>policyCategoryPasswordChange</key>
  <array>
  <dict>
    <key>policyContent</key>
    <string>policyAttributeCurrentTime &gt; policyAttributeLastPasswordChangeTime + (policyAttributeExpiresEveryNDays * 24 * 60 * 60)</string>
    <key>policyIdentifier</key>
    <string>Change every $PW_EXPIRE days</string>
    <key>policyParameters</key>
    <dict>
    <key>policyAttributeExpiresEveryNDays</key>
      <integer>$PW_EXPIRE</integer>
    </dict>
  </dict>
  </array>
  <key>policyCategoryPasswordContent</key>
<array>
  <dict>
  <key>policyContent</key>
    <string>policyAttributePassword matches '.{$MIN_LENGTH,}+'</string>
  <key>policyIdentifier</key>
    <string>Has at least $MIN_LENGTH characters</string>
  <key>policyParameters</key>
  <dict>
    <key>minimumLength</key>
    <integer>$MIN_LENGTH</integer>
  </dict>
  </dict>
  <dict>
  <key>policyContent</key>
    <string>policyAttributePassword matches '(.*[0-9].*){$MIN_NUMERIC,}+'</string>
  <key>policyIdentifier</key>
    <string>Has a number</string>
  <key>policyParameters</key>
  <dict>
  <key>minimumNumericCharacters</key>
    <integer>$MIN_NUMERIC</integer>
  </dict>
  </dict>
  <dict>
  <key>policyContent</key>
    <string>policyAttributePassword matches '(.*[a-z].*){$MIN_ALPHA_LOWER,}+'</string>
  <key>policyIdentifier</key>
    <string>Has a lower case letter</string>
  <key>policyParameters</key>
  <dict>
  <key>minimumAlphaCharactersLowerCase</key>
    <integer>$MIN_ALPHA_LOWER</integer>
  </dict>
  </dict>
  <dict>
  <key>policyContent</key>
    <string>policyAttributePassword matches '(.*[A-Z].*){$MIN_UPPER_ALPHA,}+'</string>
  <key>policyIdentifier</key>
    <string>Has an upper case letter</string>
  <key>policyParameters</key>
  <dict>
  <key>minimumAlphaCharacters</key>
    <integer>$MIN_UPPER_ALPHA</integer>
  </dict>
  </dict>
  <dict>
  <key>policyContent</key>
    <string>policyAttributePassword matches '(.*[^a-zA-Z0-9].*){$MIN_SPECIAL_CHAR,}+'</string>
  <key>policyIdentifier</key>
    <string>Has a special character</string>
  <key>policyParameters</key>
  <dict>
  <key>minimumSymbols</key>
    <integer>$MIN_SPECIAL_CHAR</integer>
  </dict>
  </dict>
  <dict>
  <key>policyContent</key>
    <string>policyAttributePasswordHashes in policyAttributePasswordHistory</string>
  <key>policyIdentifier</key>
    <string>Does not match any of last $PW_HISTORY passwords</string>
  <key>policyParameters</key>
  <dict>
    <key>policyAttributePasswordHistoryDepth</key>
    <integer>$PW_HISTORY</integer>
  </dict>
  </dict>
</array>
</dict>" > ./pwpolicy.plist 

echo "[I] Setting the new password policies for:"
echo $USER
chmod 777 ./pwpolicy.plist
pwpolicy u "$USER" -setaccountpolicies ./pwpolicy.plist
rm ./pwpolicy.plist

echo "[I] Password Policy has been set"
sleep 1

##################################################################################################

# Requires an admin password for changing certain settings that are system wide

echo "[I] Ensuring an admin password is needed to change system-wide settings"
security authorizationdb read system.preferences > tmp_file; defaults write tmp_file shared -bool false; security authorizationdb write system.preferences < tmp_file
sleep 1

##################################################################################################

# Controls when, and if, a password hint is given to the user, based on the number of failed login attempts - sets the value to 0

echo "[I] Turning off the feature which provides a password hint after x number of failed logins"
defaults write /Library/Preferences/com.apple.loginwindow.plist RetriesUntilHint -int 0
sleep 1

##################################################################################################

# The number of seconds after the screensaver starts before a password is required to use the machine - set to 5 seconds

echo "[I] Setting the timeout period, after the screensaver starts before a password is required, to 5 seconds" 
defaults write ~/Library/Preferences/ByHost/com.apple.screensaver.$UUID.plist askForPasswordDelay -int 5; killall -HUP Dock; killall -HUP cfprefsd
sleep 1

##################################################################################################

# Makes the bottom left hot corner activate screen saver if no corners are already set to start screen saver

echo "[I] Setting the bottom left hot corner to activate the screen saver (if no other hot corners are already configured to do this)"
defaults write ~/Library/Preferences/com.apple.dock.plist wvous-bl-corner -int 5; killall -HUP Dock; killall -HUP cfprefsd
sleep 1

##################################################################################################

# Enables automatic updates of system time by use of NTP through a trusted source (time.apple.com)

echo "[I] Setting 'time.apple.com' as a trusted time source for system time"
systemsetup -setnetworktimeserver time.apple.com
sleep 1
echo "[I] Enabling automatic update of system time from trusted time source"
systemsetup -setusingnetworktime on
sleep 1

##################################################################################################

# Controls whether the login screen shows usernames or not - set to not
 
echo "[I] Removing the list of users from the login screen"
defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -int 1
sleep 1

##################################################################################################

# Disables suggests in Lookup searches

echo "[I] Disabling suggestions in Lookup searches"
defaults write ~/Library/Preferences/com.apple.lookup.shared.plist LookupSuggestionsDisabled -int 1
sleep 1

##################################################################################################

# Disables Siri

echo "[I] Disabling Siri"
defaults write ~/Library/Preferences/com.apple.assistant.support.plist "Assistant Enabled" -int 0; killall -TERM Siri; killall -TERM cfprefsd
sleep 1

##################################################################################################

# Displays extensions of files that have their extensions marked as hidden

echo "[I] Setting hidden file extensions to be displayed"
defaults write ~/Library/Preferences/.GlobalPreferences.plist AppleShowAllExtensions -bool true; killall -HUP Finder; killall -HUP cfprefsd
sleep 1

##################################################################################################

# Enables the status bar on Safari

echo "[I] Enabling the status bar on Safari"
defaults write ~/Library/Preferences/com.apple.Safari.plist ShowOverlayStatusBar -bool true; killall -TERM cfprefsd
sleep 1

##################################################################################################

# Prevents other applications from intercepting text typed into Terminal

echo "[I] Preventing other applications from intercepting text typed into Terminal"
defaults write ~/Library/Preferences/com.apple.Terminal.plist SecureKeyboardEntry -int 1
sleep 1

##################################################################################################

# Do not allow downloaded signed software to receive incoming connections

echo "[I] Preventing downloaded signed software from receiving incoming connections"
/usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
sleep 1

##################################################################################################

# Allow builtin signed software to recieve incoming connections

echo "[I] Allowing inbuilt signed software to receive incoming connections"
/usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on
sleep 1

##################################################################################################

# Set firewall logging to the 'detail' level

echo "[I] Setting firewall logging to the 'detail' level"
'/usr/libexec/ApplicationFirewall/socketfilterfw --setloggingopt detail
sleep1

##################################################################################################

# Enables the pf firewall

echo "[I] Enabling the pf firewall"
pfctl -e 2> /dev/null; cp /System/Library/LaunchDaemons/com.apple.pfctl.plist /Library/LaunchDaemons/sam.pfctl.plist; /usr/libexec/PlistBuddy -c "Add :ProgramArguments:1 string -e" /Library/LaunchDaemons/sam.pfctl.plist; /usr/libexec/PlistBuddy -c "Set :Label sam.pfctl" /Library/LaunchDaemons/sam.pfctl.plist; launchctl enable system/sam.pfctl; launchctl bootstrap system /Library/LaunchDaemons/sam.pfctl.plist; echo 'anchor "sam_pf_anchors"' >> /etc/pf.conf; echo
'load anchor "sam_pf_anchors" from "/etc/pf.anchors/sam_pf_anchors"' >> /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming apple file service packets

echo "[I] Configuring the pf firewall to block incoming Apple file service packets"
echo "#apple file service pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto tcp to any port { 548 }" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block SSDP packets

echo "[I] Configuring the pf firewall to block SSDP packets"
echo "#bonjour pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block proto udp to any port 1900" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block finger packets

echo "[I] Configuring the pf firewall to block finger packets"
echo "#finger pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block proto tcp to any port 79" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming ftp packets

echo "[I] Configuring the pf firewall to block incoming FTP packets"
echo "#FTP pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto { tcp udp } to any port { 20 21 }" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming HTTP packets

echo "[I] Configuring the pf firewall to block incoming HTTP packets"
echo "#http pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto { tcp udp } to any port 80" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming ICMP packets

echo "[I] Configuring the pf firewall to block incoming ICMP packets"
echo "#icmp pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto icmp" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming IMAP packets

echo "[I] Configuring the pf firewall to block incoming IMAP packets"
echo "#imap pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto tcp to any port 143" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming IMAPS packets

echo "[I] Configuring the pf firewall to block incoming IMAPS packets"
echo "#imaps pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto tcp to any port 993" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block iTunes sharing packets

echo "[I] Configuring the pf firewall to block iTunes sharing packets"
echo "#iTunes sharing pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block proto tcp to any port 3689" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block mDNSResponder packets

echo "[I] Configuring the pf firewall to block mDNSResponder packets"
echo "#mDNSResponder pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block proto udp to any port 5353" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block nfs packets

echo "[I] Configuring the pf firewall to block nfs packets"
echo "#nfs pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block proto tcp to any port 2049" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block optical drive sharing packets

echo "[I] Configuring the pf firewall to block optical drive sharing packets"
echo "#optical drive sharing pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block proto tcp to any port 49152" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming pop3 packets

echo "[I] Configuring the pf firewall to block incoming pop3 packets"
echo "#pop3 pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto tcp to any port 110" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming printer sharing packets

echo "[I] Configuring the pf firewall to block incoming printer sharing packets"
echo "#printer sharing pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto tcp to any port 631" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming remote apple events packets

echo "[I] Configuring the pf firewall to block incoming remote Apple events packets"
echo "#remote apple events pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto tcp to any port 3031" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming screen sharing packets

echo "[I] Configuring the pf firewall to block incoming screen sharing packets"
echo "#screen sharing pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto tcp to any port 5900" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block smb packets

echo "[I] Configuring the pf firewall to block smb packets"
echo "#smb pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block proto tcp to any port { 139 445 }" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block proto udp to any port { 137 138 }" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming smtp packets

echo "[I] Configuring the pf firewall to block incoming smtp packets"
echo "#smtp pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto tcp to any port 25" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming ssh packets

echo "[I] Configuring the pf firewall to block incoming ssh packets"
echo "#SSH pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto { tcp udp } to any port 22" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming telnet packets

echo "[I] Configuring the pf firewall to block incoming telnet packets"
echo "#telnet pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block in proto { tcp udp } to any port 23" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block incoming tftp packets

echo "[I] Configuring the pf firewall to block incoming tftp packets
echo "#tftp pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block proto { tcp udp } to any port 69" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Configures pf firewall to block uucp packets

echo "[I] Configuring the pf firewall to block uucp packets"
echo "#uucp pf firewall rule" >> "/etc/pf.anchors/sam_pf_anchors"; echo "block proto tcp to any port 540" >> "/etc/pf.anchors/sam_pf_anchors"; pfctl -f /etc/pf.conf
sleep 1

##################################################################################################

# Enables the application firewall

echo "[I] Enabling the application firewall"
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sleep 1

##################################################################################################

# Prevents any action from occurring when inserting a blank cd

echo "[I] Preventing any action from occuring when inserting a blank cd"
defaults write ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.blank.cd.appeared -dict action -int 1; killall -HUP SystemUIServer; killall -HUP cfprefsd
sleep 1

##################################################################################################

# Prevents any action from occurring when a blank DVD is inserted

echo "[I] Preventing any action when inserting a blank dvd"
defaults write ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.blank.dvd.appeared -dict action -int 1; killall -HUP SystemUIServer; killall -HUP cfprefsd
sleep 1

##################################################################################################

# Prevents any action from occuring when inserting a music cd

echo "[I] Preventing any action when inserting a music cd"
defaults write ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.cd.music.appeared -dict action -int 1; killall -HUP SystemUIServer; killall -HUP cfprefsd
sleep 1

##################################################################################################

# Prevents any action from occurring when inserting a picture cd

echo "[I] Preventing any action when inserting a picture cd"
defaults write ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.cd.picture.appeared -dict action -int 1; killall -HUP SystemUIServer; killall -HUP cfprefsd
sleep 1

##################################################################################################

# Prevents any action from occurring when inserting a video DVD

echo "[I] Preventing any action when inserting a video DVD"
defaults write ~/Library/Preferences/com.apple.digihub.plist com.apple.digihub.dvd.video.appeared -dict action -int 1; killall -HUP SystemUIServer; killall -HUP cfprefsd
sleep 1

##################################################################################################

# Setting the ComputerName, HostName, LocalHostName and NetBIOSName

echo "[I] You need to provide a name for this device which can be set as the hostname"
read -p "[!] Enter a name for this device: " DEVNAME
echo "[I] Setting the ComputerName, HostName and NetBIOSName for this device"
scutil --set ComputerName $DEVNAME
scutil --set HostName $DEVNAME
scutil --set LocalHostName $DEVNAME
defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist NetBIOSName $DEVNAME
sleep 1

##################################################################################################

# Disables the file sharing daemons

echo "[I] Disabling the file sharing daemons"
launchctl disable system/com.apple.smbd; launchctl bootout system/com.apple.smbd; launchctl disable system/com.apple.AppleFileServer; launchctl bootout system/com.apple.AppleFileServer
sleep 1

##################################################################################################

# Disables the nfs server daemon

echo "[I] Disabling the nfs server daemon"
launchctl disable system/com.apple.nfsd; launchctl bootout system/com.apple.nfsd; launchctl disable system/com.apple.lockd; launchctl bootout system/com.apple.lockd; launchctl disable system/com.apple.statd.notify; launchctl bootout system/com.apple.statd.notify
sleep 1

##################################################################################################

# Restricts the use of the remote apple events service to the specified users (no users)

echo "[I] Restricting the use of the remote Apple events service"
defaults write /private/var/db/dslocal/nodes/Default/groups/com.apple.access_remote_ae.plist users -array ""; defaults delete /private/var/db/dslocal/nodes/Default/groups/com.apple.access_remote_ae.plist groupmembers; defaults delete /private/var/db/dslocal/nodes/Default/groups/com.apple.access_remote_ae.plist nestedgroups; killall -TERM cfprefsd
sleep 1

##################################################################################################

# Restricts use of the remote management service to the specified users (no users)

echo "[I] Restricting use of the remote management service
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -quiet -configure -allowAccessFor -specifiedUsers -access -off
sleep 1

##################################################################################################

# Limits the screen sharing service to the specified users (no users)

echo "[I] Restricting the use of the screen sharing service"
defaults write /private/var/db/dslocal/nodes/Default/groups/com.apple.access_screensharing.plist users -array ""; defaults delete /private/var/db/dslocal/nodes/Default/groups/com.apple.access_screensharing.plist groupmembers; defaults delete /private/var/db/dslocal/nodes/Default/groups/com.apple.access_screensharing.plist nestedgroups; killall -HUP cfprefsd
sleep 1

##################################################################################################

# Prevents the computer from idling into sleep

echo "[I] Preventing the computer from idling into sleep"
pmset -c sleep 0
sleep 1

##################################################################################################

#Prevents the computer from waking for network access

echo "[I] Prevents the computer from waking for network access"
pmset -a womp 0
sleep 1

##################################################################################################

# Determines the length of idle time before the display is put to sleep

echo "[I] Setting the idle time to 20 minutes before the display is put to sleep"
pmset -a displaysleep 20
sleep 1

##################################################################################################

# Disallows the use of challenge/response authentication mechanisms

echo "[I] Disallowing challenge/response authentication mechanisms"
sed -i.bak 's/.*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sleep 1

##################################################################################################

# Disables the public key authentication mechanisms for SSH

echo "[I] Disabling public key authentication for SSH"
sed -i.bak 's/.*PubkeyAuthentication.*/PubkeyAuthentication no/' /etc/ssh/sshd_config
sleep 1

##################################################################################################

# Prevent root login via SSH

echo "[I] Preventing root login via SSH"
sed -i.bak 's/.*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sleep 1

##################################################################################################

# Sets the number of client alive messages that can be sent without sshd receiving a resposne before the server terminates the connection

echo "Ensuring that the ssh daemon disconnects if a client alive response is not recieved"
sed -i.bak 's/.*ClientAliveCountMax.*/ClientAliveCountMax 0/' /etc/ssh/sshd_config
sleep 1

##################################################################################################

# Determines how long a remote user has to authenticate after connecting to a system using ssh

echo "[I] Setting the timeout period for how long a remote user has to authenticate using SSH before being disconnected"
sed -i.bak 's/.*LoginGraceTime.*/LoginGraceTime 30/' /etc/ssh/sshd_config
echo "[I] timeout period set to 30 seconds"
sleep 1

##################################################################################################

# Sets a limit of 4 on the number of authentication attempts before disconnecting the SSH client

echo "[I] Setting the authentication attempts for SSH to 4 before the client is disconnected"
sed -i.bak 's/.*maxAuthTries.*/maxAuthTries 4/' /etc/ssh/sshd_config
sleep 1

##################################################################################################

# Prevents the use on non-FIPS 140-2 compliant SSH ciphers

echo "[I] Preventing the use of non-FIPS 140-2 compliant SSH ciphers"
sed -i.bk 's/^Ciphers.*$//' /etc/sshd_config; echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,aes192-cbc,aes256-cbc,3des-cbc" >> /etc/sshd_config
sleep 1

##################################################################################################

# Prevents the use of non-FIPS 140-2 compliant Message Authentication Codes (MACs)

echo "[I] Preventing the use of non-FIPS 140-2 compliant Message Authentication Codes (MACs)"
sed -i.bk 's/^MACs.*$//' /etc/sshd_config; echo "MACs hmac-sha2-256,hmac-sha2-512,hmac-sha1" >> /etc/sshd_config
sleep 1

##################################################################################################

# Restricts SSH connections to use only the specified user accounts

echo "[I] Restricting SSH connections"
sed -i.bak 's/^DenyUsers.*$//' /etc/ssh/sshd_config; echo "DenyUsers *" >> /etc/ssh/sshd_config
sleep 1

##################################################################################################

# Sets a client liveness query of 900 seconds for an SSH session

echo "[I] Setting the liveness query for SSH to 900 seconds"
sed -i.bak 's/.*ClientAliveInterval.*/ClientAliveInterval 900/' /etc/ssh/sshd_config
sleep 1

##################################################################################################

# Determines if Bluetooth devices are allwed to wake the computer

echo "[I] Preventing Bluetooth devices from waking the computer"
defaults write ~/Library/Preferences/ByHost/com.apple.Bluetooth.$UUID.plist RemoteWakeEnabled -bool false; killall -HUP UserEventAgent; killall -HUP cfprefsd
sleep 1

##################################################################################################

# Disables the infrared receiver

echo "[I] Disabling the Infrared receiver"
defaults write /Library/Preferences/com.apple.driver.AppleIRController.plist DeviceEnabled -bool false
sleep 1

##################################################################################################

# Shows the Bluetooth status in the menu bar

echo "[I] Configuring the menu bar to show the Bluetooth status"
defaults write ~/Library/Preferences/com.apple.systemuiserver.plist menuExtras -array-add "/System/Library/CoreServices/Menu\ Extras/Bluetooth.menu"; killall -HUP SystemUIServer; killall -HUP cfprefsd
sleep 1

##################################################################################################

# Downloads and installs the latest Apple updates

echo "[I] Downloading and installing the latest Apple updates"
softwareupdate -ia
sleep 1

##################################################################################################

# THIS SECTION REBOOTS THE MACHINE SO THE SETTINGS CAN TAKE EFFECT - IT ADDS A KEYPRESS AS A PAUSE BEFORE CONTINUING WITH THE REBOOT

read -r -p "[I] The machine will now reboot to enable the hardening to take effect. Press ENTER to continue..."

sudo reboot

done

###################################################################################################
