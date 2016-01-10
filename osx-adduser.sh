#!/bin/bash
# =========================
# Add User OSX Command Line
# =========================

# An easy add user script for Max OSX.
# Although I wrote this for 10.7 Lion Server, these commands have been the same since 10.5 Leopard.
# It's pretty simple as it uses and strings together the (rustic and ancient) commands that OSX 
# already uses to add users.

# Customized to be less interactive for Rust Buildbot slaves as of Jan 2016

# Fail early if insufficient permissions
if [[ $UID -ne 0 ]]; then echo "Please run $0 as root." && exit 1; fi

USERNAME='rustbuild'
FULLNAME='Rust Buildbot'
# We already have admin credentials on the machine if we're running this
# script, and access the user by su-ing to it. 
PASSWORD=$(openssl rand -base64 30)

SECONDARY_GROUPS="admin _lpadmin _appserveradm _appserverusr" # for an admin user

# Create a UID that is not currently in use

# Find out the next available user ID
MAXID=$(dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1)
USERID=$((MAXID+1))

# Create the user account by running dscl (normally you would have to do each
# of these commands one by one in an obnoxious and time consuming way.
echo "Creating necessary files..."

dscl . -create /Users/$USERNAME
dscl . -create /Users/$USERNAME UserShell /bin/bash
dscl . -create /Users/$USERNAME RealName "$FULLNAME"
dscl . -create /Users/$USERNAME UniqueID "$USERID"
dscl . -create /Users/$USERNAME PrimaryGroupID 20
dscl . -create /Users/$USERNAME NFSHomeDirectory /Users/$USERNAME
dscl . -passwd /Users/$USERNAME $PASSWORD

# Add user to any specified groups

for GROUP in $SECONDARY_GROUPS ; do
    dseditgroup -o edit -t user -a $USERNAME $GROUP
done

# Create the home directory
createhomedir -c 2>&1 | grep -v "shell-init"

echo "Created user #$USERID: $USERNAME ($FULLNAME)"
