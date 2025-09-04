


#!/bin/bash


 #=======Set permission for backup_script.sh and setup_cron.sh=========
   
 check_permissions() {
   local script=("backup_script.sh" , "setup_cron.sh")

   for check in "${scripts[@]}"; do
	   if [ ! -x "$script" ]; then
		   error "Missing execute permission on $script"
		   notice "Run: chmod 755 $script"
		   exit 1
	   fi
   done
} 
check_permissions
 #=====path to your backup script======
BACKUP_SCRIPT="$HOME/project-01/backup-of-data/backup_script.sh"
LOG_FILE="$HOME/backup_cron.log"



notice() { echo -e "\033[1;34m[NOTICE]\033[0m $1"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

 #======Check if BACKUP_SCRIPT is exit=======

if [ ! -f "$BACKUP_SCRIPT" ]; then
	error "Backup script not found!"
	exit 1
	notice "Setting up for cron job...."
fi


# =====Check Permissions=====
#if [ ! -x "$BACKUP_SCRIPT" ]; then
 #   error "Backup script $BACKUP_SCRIPT is not executable!" | tee -a "$LOG_FILE"
  #   chmod +x "$BACKUP_SCRIPT" | tee -a "$LOG_FILE"
#fi

 #=======Add cron job=======

CRON_JOB="0 2 * * * $BACKUP_SCRIPT >> $LOG_FILE 2>&1"
CRON_FILE="/tmp/crontab.tmp"

if crontab -l | grep -Fx "$CRON_JOB" 2>/dev/null; then
	    notice "Cron job already exists!" | tee -a "$LOG_FILE"
	        exit 0
fi
 notice "Adding cron job..." | tee -a "$LOG_FILE"
 crontab -l > "$CRON_FILE" 2>/dev/null || true
 echo "$CRON_JOB" >> "$CRON_FILE"
 crontab "$CRON_FILE" && success "Cron job added!" | tee -a "$LOG_FILE" || { error "Cron job failed!" | tee -a "$LOG_FILE"; exit 1; }
 rm "$CRON_FILE"
notice "cron job completed successfully"


# ========NEW PART: Run backup immediately after cron setup =======
 notice "Running backup_script.sh immediately..."
 echo "--------------------------------------------------"
  	for _ in {1..5}; do
		echo -n "."
		sleep 2 
	done

 bash "$HOME/project-01/backup-of-data/backup_script.sh"
 echo "--------------------------------------------------"
