#! /bin/bash

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

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

##################################################################################################

# THIS SECTION REBOOTS THE MACHINE SO THE SETTINGS CAN TAKE EFFECT - IT ADDS A KEYPRESS AS A PAUSE BEFORE CONTINUING WITH THE REBOOT

read -r -p "[I] The machine will now reboot to enable the hardening to take effect. Press ENTER to continue..."

sudo reboot

done

###################################################################################################
