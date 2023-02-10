#!/usr/bin/env bash

source "scripts/_utils.sh"

echo "SET COMPUTER NAME"
read -r COMPUTER_NAME

echo "========================================================================"
echo "SET YOUR LOCK SCREEN, GITHUB and SSH INFORMATION"
echo "Your name:"
read -r YOUR_NAME
echo "Your email:"
read -r YOUR_EMAIL
echo "Your phone number:"
read -r YOUR_PHONE

echo "========================================================================"

echo "Verify details"
echo 
echo "Computer name: $COMPUTER_NAME"
echo "Name: $YOUR_NAME"
echo "Email: $YOUR_EMAIL"
echo "Phone: $YOUR_PHONE"

get_consent "Are your details correct?"
if ! has_consent; then
    e_failure "Please rerun script and set the details correctly"
    killall caffeinate
    exit 0
fi
e_success "Details set"

echo "========================================================================"
echo "SIGN IN TO THE MAC APP STORE"
open /System/Applications/App\ Store.app/
e_pending "Sign in to the App Store to get xcode tools"
e_anykey "Press any key when you're done, to continue."

get_consent "Ready to start the installation process?"

if ! has_consent; then
    e_failure "Please rerun the script if you wish to carry out the installation"
    killall caffeinate
    exit 0
fi
