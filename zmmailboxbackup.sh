#!/bin/bash
# Zimbra's mailboxes backup script

# Date of backup creation
date=`date +%Y%m%d-%H%M`

# Backup path
zimbraBackDir="/mnt/remote/zimbra/"

# Directory where backups will be stored named by date
zimbraBackDirWithDate=$zimbraBackDir$date

# Main maillist of company where all useres included 
maillist="all-users@example1.com"

# Excluded accounts
exclude=".*trainee.*"

# Another domain which need to backup
domain="example2.com"

# Get all addresses from main maillist without excluded accounts
firstList=`/opt/zimbra/bin/zmprov gdl $maillist | grep zimbraMailForwardingAddress: | grep -v "$exclude" | cut -f 2 -d ' ' -s`

# Get all addresses from domain
secondList=`/opt/zimbra/bin/zmprov -l gaa $domain`

# Concatenate lists
zimbraAccounts="$firstList $secondList"

echo "====================================================="
echo "Log of Zimbra's mailboxes backup by $date"
echo "====================================================="

# Check existing of backup path
if ! [ -d "$zimbraBackDir" ]; then

    mkdir "$zimbraBackDir"

fi

# Check existing directory with date
if [ -d "$zimbraBackDirWithDate" ]; then

    echo "Directory with this name is exist"
    exit 1

else

    mkdir "$zimbraBackDirWithDate"
    echo "Directory with backups has been created $zimbraBackDirWithDate"

fi

# In loop script saves each mailbox in a separate zip archive
for account in $zimbraAccounts;

    do

	if /opt/zimbra/bin/zmmailbox -v -z -m $account getRestURL "//?fmt=zip" > $zimbraBackDirWithDate/$account.zip; then

	    filesize=`du -h $zimbraBackDirWithDate/$account.zip`
	    echo "Account has been backuped $account - $filesize"

	else

	    echo "Backup of $account failed"

	fi

    done

# Backups rotation
if ls -dr -1 $zimbraBackDir** | tail -n6 | xargs rm -rv; then

    echo "Last 6 backups left, old backups have been deleted. List of existing backup directories:"

else

    echo "Nothing has been deleted. List of existing backup directories:"

fi

# Get list of backup directories
ls $zimbraBackDir
exit 0