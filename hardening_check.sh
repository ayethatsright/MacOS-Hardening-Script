#! /bin/bash

# This script checks the machine against all the settings in the 'DRAFT NIST SP 800-179r1 macOS 10.12 Security Baseline' and reports on it's compliance
# It outputs the results to ./check_results.txt

echo "[WARNING] THIS SCRIPT IS STILL UNDER DEV AND HASNT BEEN TESTED AT ALL YET"
echo "[WARNING] USE THE SCRIPT FROM THE MASTER BRANCH UNLESS YOU HAVE THE TIME TO TROUBLESHOOT THIS"

##################################################################################################

# CONFIRM THAT THE SCRIPT HAS BEEN RUN WITH SUDO

if [[ $UID -ne 0 ]]; then
	echo "Need to run this script as root (with sudo)"
	exit 1
fi
echo "[I] Beginning hardening check script now"

##################################################################################################

# Blah



##################################################################################################

