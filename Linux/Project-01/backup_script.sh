#!/bin/bash

 # ======DETAILE======
 SOURCE_DIR="$HOME/important_files"     # directory to backup
 BACKUP_DIR="$HOME/backup/local" 	# Backup destination
 LOG_FILE="$HOME/backup.log"		# log file location
 TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S") # Current time
 EXCLUDE=(--exclude='*.tmp' --exclude='node_modules') # File/Folder ignore

 #======Notice function======
  notice() { echo -e "\033[1;34m[NOTICE]\033[0m $1"; }  #blue colur
  error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }  # red colur
  success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; } # green colur
  warn () { echo -e "\033[1;33m[WARN]\033[0m $1"; } # yellow colur

 #======Create log file if missing======
if [ ! -f "$LOG_FILE" ]; then
	error "Error: LOG_FILE not found!"
	sleep 2
	notice "Creating $LOG_FILE in few seconds..."
	for _ in {1..5}; do
		echo -n "."
		touch "$LOG_FILE"
		sleep 1
	done
	success "LOG_FILE successfully done" | tee -a "$LOG_FILE"	    
fi

 #======Check for SOURCE_DIR=====>( STEP 1 )
if [ ! -d  "$SOURCE_DIR" ]; then
	error "Error: Source directory $SOURCE_DIR does't exit!" >> "$LOG_FILE"
	exit 1
fi

 #======CHECK for BACKUP_DIR======>( STEP 2 )
if [ ! -d "$BACKUP_DIR" ]; then
	notice "Error: backup directory $BACKUP_DIR does't exit!" >> "$LOG_FILE"
	error "Backup directory not found!" || tee -a "$LOG_FILE"
	sleep 2
	notice "Creating backup directory in few seconds..."  || tee -a "$LOG_FILE"

	#wait for 3 second creating folder BACKUP_DIR
	for _  in {1..5}; do
	 echo -n "."
	 sleep 1
	done

 #======NOW CREATE BACKUP_DIR======
 	 mkdir -p "$BACKUP_DIR"
	 chmod 755 "$BACKUP_DIR"

	notice "$BACKUP_DIR is successfully completed" | tee -a "$LOG_FILE"
fi


#######################################
## STEP 3: CHECK WRITE PERMISSION
########################################
#
#if [ ! -w "$BACKUP_DIR" ]; then
#    error "No write permission on $BACKUP_DIR"
 #   notice "try: chmod 755 $BACKUP_DIR" 
       # notice "Try: sudo chmod 755 $BACKUP_DIR" | tee -a "$LOG_FILES"
  #         exit 1
# fi


	 warn "backup started at $TIMESTAMP" | tee -a "$LOG_FILE"

 # ==============================
 # #   FUNCTIONS
 # # ============================
 

 #=======Tar_backup======
Tar_backup() {
	TAR_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"  || tee -a "$LOG_FILE"
	if tar -czvf "$TAR_FILE" $EXCLUDE "$SOURCE_DIR" >> "$LOG_FILE" 2>&1; then
		for _ in {1..5}; do
			echo -n "."
			sleep 2
		done
		success "Tar_file successfully completed" | tee -a "$LOG_FILE"
	else
		error "Tar backup failed!" | tee -a "$LOG_FILE"
		exit 1
	fi

}
Tar_backup

 #======rsync_backup======
rsync_backup() {
	if rsync -azv --delete $EXCLUDE "$SOURCE_DIR" "$BACKUP_DIR/rsync_mirror/" >> "$LOG_FILE"; then
		for _ in {1..5}; do
			echo -n "."
			sleep 2
		done
		success  "Rsync_backup successfully done" | tee -a "$LOG_FILE"
	else
		error "rsync failed!" >> "$LOG_FILE"
	fi

	ssh -q chikuuser@127.0.0.1 exit || { error "SSH to remote failed!" | tee -a "$LOG_FILE"; exit 1; }
	    if rsync -avz -e ssh --delete "${EXCLUDE[@]}" "$SOURCE_DIR/" "$REMOTE_DIR" >> "$LOG_FILE" 2>&1; then
		            success "Remote rsync successful" | tee -a "$LOG_FILE"
			        else
					        error "Remote rsync failed!" | tee -a "$LOG_FILE"
						    fi
}

rsync_backup

 #=======Cleanup old backups (keep last 7+ days)=======
 
  notice  "do you want to clean old backup (>7 days)? (y/n)"
  read -r choise
  if [[ "$choise" == "y" ]]; then
	 find "$BACKUP_DIR" -type f -mtime +7 -delete >> "$LOG_FILE" 2>&1
	 	warn "cleanup in processing...."
 		for _ in {1..5}; do
			echo -n "."
			sleep 1
		done
 	 success "Old backups (older than 7 days) cleaned up" | tee -a "$LOG_FILE"
 else
	 warn "skipped cleanup"
  fi

 


 success "backup completed successfully at $TIMESTAMP" | tee -a "$LOG_FILE"

