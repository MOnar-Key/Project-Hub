              Backup-of-Data Script: Beginner-Friendly Guide

Automated File Backup Project (project-01)
----------------------------------------------------------------------------------------------------------------------------------------------
Project Overview This project is an automated file backup system built using Bash scripting. It backs up a specified source directory using tar for creating compressed full archives and rsync for efficient incremental syncing to a local backup location. It follows the 3-2-1 backup rule (3 copies of data, 2 different media, 1 offsite) by including a remote sync option. The script includes colorful logging for better readability, directory validations to prevent clear errors, and an interactive prompt for cleaning old backups. Additionally, it uses a separate setup script (setup_cron.sh) to schedule the backups via cron for automation. This project is ideal for learning DevOps/SRE concepts like automation, reliability, and observability, ensuring data protection without manual interventionAutomated File Backup Project.


Features (Simple List)
---------------------------------------------------------------------------------------------------------------------------------------------
1.Copies files locally in a zip and a mirror folder.
2.Sends copies to another computer if you want.
3.Asks to clean up old files (older than 7 days).
4.Colors make it easy to read what's happening.
5.Logs everything in a file so you can check later.
6.Sets itself up to run automatically.

-------------------------------------------------------------------------------------------------------------------------------------------
What You Need Before Starting
-------------------------------------------------------------------------------------------------------------------------------------------
A computer with Bash (like Linux, or Windows with "Ubuntu" app from Microsoft Store—called WSL).
Basic tools: Open a terminal and type these to install if missing:
sudo apt update  # Updates your system list
sudo apt install tar rsync openssh-server cron  # Installs the tools we need

Know how to open a terminal (search "terminal" or "cmd" on your computer).
For remote backups: Another computer or server ready with SSH (we'll explain setup).


-------------------------------------------------------------------------------------------------------------------------------------------
How to Install and Run (Step-by-Step)
-------------------------------------------------------------------------------------------------------------------------------------------

Download from GitHub:

Go to the repo page, click "Code" > "Download ZIP", or use Git:
git clone https://github.com/yourusername/backup-of-data.git  # Copies the project to your computer
cd backup-of-data  # Goes inside the folder



Make it runnable:
chmod +x backup_script.sh  # This line gives permission to run the script, like unlocking a door

Change settings (see next section).
Run it:
./backup_script.sh  # Starts the script—watch the colors!

If it asks for "sudo" (admin power), try:
sudo ./backup_script.sh

Check what happened:
cat /home/yourusername/backup_cron.log  # Shows the log file—replace with your path.


------------------------------------------------------------------------------------------------------------------------------------------

            How the Project is Built: Line-by-Line Explanation
------------------------------------------------------------------------------------------------------------------------------------------
STEP 1: Create the Project Directory

Command: mkdir -p ~/project-01/backup-of-data

------->Why? This creates the project folder to organize scripts. backup-of-data holds the code.


Change directory: cd ~/project-01/backup-of-data
------->Why? To work inside the project folder.

Command: vim setup_cron.sh


STEP 2:  [SOURCE_DIR Variable]
   This section defines the source directory for backups.

   text

   SOURCE_DIR="$HOME/important_files"     # Directory to backup

------->Why needed? It's the starting point for all backups; the script reads files from here to create archives and syncs. What happens? The script valid   ates it exists; if not, it errors out to prevent running without data. This ensures the backup process is targeted and safe.

STEP 3:   [BACKUP_DIR Variable]
    This section defines the local backup location.

    text

    BACKUP_DIR="$HOME/backup/local"        # Backup destination

    
------->Why needed? It's where local copies (tar files and rsync mirrors) are stored for quick access and restore. What happens? The script creates it if    missing, checks permissions, and uses it for all local operations, ensuring organized storage.

STEP 4:  [LOG_FILE Variable]
    This section defines the log file for script actions.

    text

    LOG_FILE="$HOME/backup.log"            # Log file location

------->Why needed? Logs record every step, error, and success for debugging and auditing. In SRE, logs are crucial for observability. What happens? The     script appends messages to this file, allowing you to review what happened during runs.

STEP 5:  [TIMESTAMP Variable]
    This section generates a unique timestamp.

    text

    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S") # Current time

------->Why needed? It creates unique filenames for backups to avoid overwrites. What happens? Each run gets a time-stamped file (e.g., backup_2025-0        9-03_16-00-00.tar.gz), making version control easy.

STEP 6:  [EXCLUDE Variable]
    This section defines patterns to exclude from backups.

    text

    EXCLUDE=(--exclude='*.tmp' --exclude='node_modules') # File/Folder ignore

-------->Why needed? It skips unnecessary files to save space and time. What happens? During tar and rsync, these patterns are applied, ignoring temp file    s and node_modules, resulting in cleaner backups.


STEP 6:  [Notice Functions]
    This section defines colorful logging functions.

    text

    notice() { echo -e "\033[1;34m[NOTICE]\033[0m $1"; }  # Blue
    error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }    # Red
    success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; } # Green
    warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }      # Yellow

------->Why needed? They provide visual feedback in the terminal for better user experience. What happens? Messages are printed in colors (e.g., error  s    in red), making it easier to spot issues during runs.

STEP 7:  [Create Log File]
    This section creates the log file if missing.

    text

    if [ ! -f "$LOG_FILE" ]; then
    error "Log file $LOG_FILE not found!"
    sleep 2
       notice "Creating $LOG_FILE in few seconds..."
    for _ in {1..5}; do
        echo -n "."
        touch "$LOG_FILE" || { error "Failed to create $LOG_FILE" | tee -a "$LOG_FILE"; exit 1; }
        sleep 1
    done
    success "Log file created successfully" | tee -a "$LOG_FILE"
    fi

------->Why needed? Ensures logging is available from the start. What happens? If missing, it creates the file with a countdown, logs the action, and exi    ts on failure, preventing runs without logging.

STEP 8:  [Check SOURCE_DIR]
    This section validates the source directory.

    text

    if [ ! -d "$SOURCE_DIR" ]; then
    error "Source directory $SOURCE_DIR doesn't exist!" | tee -a "$LOG_FILE"
    exit 1
    fi

------->Why needed? Prevents backups from running without a source, avoiding errors. What happens? If the directory doesn't exist, it logs an error and      exits, ensuring reliability.


STEP 9:  [Check BACKUP_DIR]
    This section validates and creates the backup directory.

    text

    if [ ! -d "$BACKUP_DIR" ]; then
    error "Backup directory $BACKUP_DIR doesn't exist!" | tee -a "$LOG_FILE"
    sleep 2
    notice "Creating backup directory in few seconds..."
    #for _ in {1..5}; do
        echo -n "."
        sleep 1
    done
    echo ""
    mkdir -p "$BACKUP_DIR" || { error "Failed to create $BACKUP_DIR" | tee -a "$LOG_FILE"; exit 1; }
    chmod 755 "$BACKUP_DIR"
    success "Backup directory $BACKUP_DIR created successfully" | tee -a "$LOG_FILE"
    fi

------->Why needed? Ensures a destination for backups exists. What happens? If missing, it creates the directory with a countdown, sets ownership, logs t    he action, and exits on failure, making the script idempotent.



    #    STEP 10:  [Check Write Permission]
   #     This section checks write permissions on the backup directory.

   #     text

   # if [ ! -w "$BACKUP_DIR" ]; then
   #   error "No write permission on $BACKUP_DIR" | tee -a "$LOG_FILE"
   #  notice "Try: chmod 755 $BACKUP_DIR"
   #     exit 1
   #     fi

    Why needed? Prevents failures during writing backups. What happens? If no permission, it logs an error, suggests a fix, and exits, ensuring the       script doesn't run in a broken state.


STEP 11:  [Log Start]
    This section logs the start of the backup.

    text

    warn "Backup started at $TIMESTAMP" | tee -a "$LOG_FILE"

    Why needed? Tracks when the backup begins for auditing. What happens? Appends a warning message to the log and terminal, providing a timestamped    record.


STEP 12:  [Tar Backup Function]
    This section defines the tar backup function.

    text

    tar_backup() {
    TAR_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"
    if tar -czvf "$TAR_FILE" "${EXCLUDE[@]}" "$SOURCE_DIR" >> "$LOG_FILE" 2>&1; then
        for _ in {1..5}; do
            echo -n "."
            sleep 1
        done
        echo ""
        success "Tar backup successful: $TAR_FILE" | tee -a "$LOG_FILE"
    else
        error "Tar backup failed!" | tee -a "$LOG_FILE"
        exit 1
    fi
    }

    Why needed? Creates a compressed full backup. What happens? It runs tar with excludes, logs output, shows a countdown on success, or errors and      exits on failure, ensuring a reliable archive.


STEP 13:  [Rsync Backup Function]
    This section defines the rsync backup function.

    text

    rsync_backup() {
    if rsync -avz --delete "${EXCLUDE[@]}" "$SOURCE_DIR/" "$BACKUP_DIR/rsync_mirror/" >> "$LOG_FILE" 2>&1; then
        for _ in {1..5}; do
            echo -n "."
            sleep 1
        done
        echo ""
        success "Local rsync successful" | tee -a "$LOG_FILE"
    else
        error "Local rsync failed!" | tee -a "$LOG_FILE"
        exit 1
    fi
    ssh -q chikuuser@127.0.0.1 exit || { error "SSH to remote failed!" | tee -a "$LOG_FILE"; exit 1; }
    if rsync -avz -e ssh --delete "${EXCLUDE[@]}" "$SOURCE_DIR/" "$REMOTE_DIR" >> "$LOG_FILE" 2>&1; then
        for _ in {1..5}; do
            echo -n "."
            sleep 1
        done
        echo ""
        success "Remote rsync successful" | tee -a "$LOG_FILE"
    else
        error "Remote rsync failed!" | tee -a "$LOG_FILE"
    fi
    }


------->Why needed? Performs efficient incremental syncs locally and remotely. What happens? It syncs files with excludes, deletes old ones, checks SSH, logs output with countdown on success, or errors on failure, ensuring data mirroring.


STEP 14:  [Run Backups]
    This section calls the backup functions.

    text

    tar_backup
    rsync_backup

-------->Why needed? Executes the core backup logic. What happens? It runs tar and rsync sequentially, performing the full backup process.


STEP 15:   [Cleanup Old Backups]
    This section handles interactive cleanup.

    text

    notice "Do you want to clean old backups (>7 days)? (y/n)" | tee -a "$LOG_FILE"
    read -r choice
    if [[ "$choice" == "y" ]]; then
    warn "Cleanup in progress..." | tee -a "$LOG_FILE"
    for _ in {1..5}; do
        echo -n "."
        sleep 1
    done
    echo ""
    find "$BACKUP_DIR" -type f -mtime +7 -delete >> "$LOG_FILE" 2>&1
    success "Old backups cleaned up" | tee -a "$LOG_FILE"
    else
    warn "Skipped cleanup" | tee -a "$LOG_FILE"
    fi

-------->Why needed? Manages disk space  by deleting old backups. What happens? Prompts user, runs cleanup with countdown if yes, logs the action, or skip    if no, preventing storage overflow.



------------------------------------------------------------------------------------------------------------------------------------------
            How the Project is Built: setup_cron.sh
            Command: vim setup_cron.sh
------------------------------------------------------------------------------------------------------------------------------------------

STEP 1:  [BACKUP_SCRIPT and LOG_FILE Variables]
    This section defines paths.

    text

    BACKUP_SCRIPT="$HOME/project-01/backup-of-data/backup_script.sh"
    LOG_FILE="$HOME/backup_cron.log"

-------->Why needed? Specifies the script to schedule and its log. What happens? Used for adding the cron job and logging cron runs.


STEP 2:  [Notice Functions]
    This section defines colorful logging.

    text

    notice() { echo -e "\033[1;34m[NOTICE]\033[0m $1"; }
    success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
    error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

--------->Why needed? Provides visual feedback. What happens? Messages are printed in colors for clarity.

STEP 3:   [Check if BACKUP_SCRIPT Exists]
    This section validates the backup script.

    text

    if [ ! -f "$BACKUP_SCRIPT" ]; then
    error "Backup script not found!"
    exit 1
    fi

--------->Why needed? Prevents scheduling a missing script. What happens? Errors and exits if not found


STEP 4:  [Check Permissions]
    This section ensures the script is executable.

    text

    if [ ! -x "$BACKUP_SCRIPT" ]; then
    error "Backup script $BACKUP_SCRIPT is not executable!" | tee -a "$LOG_FILE"
     chmod +x $BACKUP_SCRIPT" | tee -a "$LOG_FILE"
    fi

--------->Why needed? Cron requires executable scripts. What happens? Logs the issue and suggests a fix.


STEP 5:   [Add Cron Job]
    This section adds the cron job.

    text

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

---------->Why needed? Schedules the backup. What happens? Defines the job and adds it, but note: The current code has premature success message; in fixed       versions, it checks for success. The job runs every minute for testing, logging output.



-----------------------------------------------------------------------------------------------------------------------------------------
    [Running]
-----------------------------------------------------------------------------------------------------------------------------------------
    chmod +x backup_script.sh setup_cron.sh
    ./setup_cron.sh
    ./setup_cron.sh --test
    Check logs: cat ~/backup_cron.log




------------------------------------------------------------------------------------------------------------------------------------------
Troubleshooting: Common Problems and Fixes (Focus Here!)
This is the big part! Based on my tests (like the photos I shared), here are issues that can happen, why, and how to fix with exact code lines. Beginners: If you see an error, copy-paste it into Google or ask here.

Problem: "LOG_FILE not found!"

Why? Log path wrong or no permission to create.
What happens: Script says [ERROR] but then creates it.
Fix: Check path: ls /home/chikuuser/ (replace username). Create manually: touch /home/chikuuser/backup_cron.log.
If permission denied: sudo chown yourusername /home/chikuuser/ — Changes owner to you.


Problem: "Operation not permitted" on chown

Why? Script tries chown chikuuser "$BACKUP_DIR" but you need admin power.
What happens: [NOTICE] Changing ownership... then red error.
Fix: Run whole script with sudo: sudo ./backup_script.sh. Or remove the line: Comment out # chown ... if folder is already yours.
Test: ls -l $BACKUP_DIR — Shows owner; should be your user.


Problem: "Tar backup failed!"

Why? Source missing, excludes wrong, or no space/permissions.
What happens: [ERROR] Tar backup failed! Script stops.
Fix: Check source: ls $SOURCE_DIR — Should list files.
Test tar alone: tar -czvf test.tar.gz $SOURCE_DIR — If fails, fix path.
Excludes issue: If array wrong, edit EXCLUDE=("item1" "item2") — No commas at end.
No space: df -h — Checks disk space.


Problem: "SSH to remote failed!" or "Remote rsync failed!"

Why? SSH not setup, wrong host, or server not running.
What happens: [ERROR] SSH... then [ERROR] Remote rsync... Script may continue locally.
Fix Step-by-Step:

Install SSH: sudo apt install openssh-server.
Start: sudo service ssh start — Or sudo service ssh status to check.
Test connect: ssh chikuuser@127.0.0.1 — Should login (password if no key).
Setup key: ssh-keygen -t rsa (make key), ssh-copy-id chikuuser@127.0.0.1 (copy to remote).
In script: Change REMOTE_HOST="actual.ip.here" if not localhost.
Remote dir: SSH in and mkdir $REMOTE_DIR; chmod 755 $REMOTE_DIR.


If "Connection refused": Port 22 blocked? Firewall: sudo ufw allow 22.


Problem: Cleanup Doesn't Work or Skips

Why? Wrong input, or find command fails (no files/old ones).
What happens: [WARN] Skipped cleanup.
Fix: Test find: find $BACKUP_DIR -type f -mtime +7 — Lists old files.
If no prompt: Script in non-interactive mode? For cron, make it auto: Change if [ "$choice" = "y" ]; then to always yes if needed.


Problem: Cron Job Not Running

Why? Not added, or cron not started.
What happens: No auto backups.
Fix: Check: crontab -l — Lists jobs.
Add manually: crontab -e (edit), add 0 2 * * * /path/to/backup_script.sh >> $LOG_FILE 2>&1 — Runs at 2 AM.
Start cron: sudo service cron start.


Other Common Issues:

"Permission denied" anywhere: Always check ls -l path and fix with chmod 755 path or chown youruser path.
Script stops early: Add echo "Debug: At line X" in code to trace.
Windows issues (if WSL): Paths like "/home/" work, but map drives if needed (/mnt/c/ for C:).
Too slow: Large files? Add --bwlimit=1000 to rsync for speed limit.



If you see a new error, run bash -x backup_script.sh > debug.log — Saves every step to file, then share it.


------------------------------------------------------------------------------------------------------------------------------------------
Automatic Backups with Cron
------------------------------------------------------------------------------------------------------------------------------------------
Script checks if job exists: crontab -l | grep -Fx "$CRON_JOB".
Adds if not: Creates temp file, echoes job, crontab temp_file.
Job example: 0 2 * * * $BACKUP_SCRIPT >> $LOG_FILE 2>&1 — 0 min, 2 hour, every day/month/week.
Test: Change to * * * * * (every minute), wait, check log.

------------------------------------------------------------------------------------------------------------------------------------------
Things to Watch Out For (Limitations)
------------------------------------------------------------------------------------------------------------------------------------------

Don't use on huge files—might take time.
Remote needs internet/SSH working.
Deletes in cleanup are permanent—test first!
For Windows only: Use WSL, not plain CMD.


------------------------------------------------------------------------------------------------------------------------------------------
How You Can Help (Contributing)
------------------------------------------------------------------------------------------------------------------------------------------

Try it, find bugs? Open an "Issue" on GitHub.
Fix something? Fork, edit, Pull Request.
Add features like email alerts? Welcome!


















