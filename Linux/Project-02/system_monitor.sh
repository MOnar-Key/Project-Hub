#!/bin/bash


 # source ./config.sh 2>dev/null || true

LOG_FILE="${LOG_FILE:-$HOME/system_monitor.log}"
CPU_THRESHOLD="${CPU_THRESHOLD:-80}"
MEM_THRESHOLD="${MEM_THRESHOLD:-75}"
DISK_THRESHOLD="${DISK_THRESHOLD:-80}"
INTERVAL="${INTERVAL:-300}"
SCREEN_TIME="${SCREEN_TIME:-10800}"
SMTP_SERVER="${SMTP_SERVER:-xyz.email.com:587}"

log() {
	local level="$1"
	shift
	echo "[$(date '+%Y-%m-%d %H:%M:%S IST')] [$level] $*" | tee -a "$LOG_FILE"
}
	 handle_error() {
		 log "error" "error:$1" 
		 echo "error: $1" >&2
		 exit 1
	 }


  #=======Check resource usage (CPU , MEM , DISK)=======

 Check_usage() {
	 CPU_USAGE=$(top -bn2 | grep "Cpu(s)" | tail -1 | awk '{print $2}'| cut -d. -f1)
	  [[  -z "$CPU_USAGE" ]] && handle_error "Failed to retrieve CPU usage"
         
	  MEM_USAGE=$(free | awk '/Mem:/ {printf("%d", $3/$2 * 100)}')
	  	[[ -z "$MEM_USAGE" ]] && handle_error "Failed to retrieve memory usage"

		DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | cut -d% -f1)
		 [[  -z "$DISK_USAGE" ]] &&  handle_error "Failed to retrieve disk usage"

		SESSION_TIME=$(awk '{print int($1)}' /proc/uptime)
		 

			log "INFO" ": CPU=$CPU_USAGE%, MEM=$MEM_USAGE%, DISK=$DISK_USAGE%, TIME=${SESSION_TIME}s"
	 
	 }


	 send_alert() {
		 local Body=""
		local level="$1"
	       local subject="Alert: System Resource $level Exceeded"
	       Body="Timestamp: $(date '+%Y-%m-%d %H:%M:%S IST')\nlevel:$level\nCPU_USAGE:$CPU_USAGE\nMEM_USAGE:$MEM_USAGE\nDISK_USAGE:$DISK_USAGE\nSESSION_TIME:$SESSION_TIME"
		if ! echo  -e "$Body" | mail -s "$subject" "$EMAIL_RECIPIENT" -- -r "$EMAIL_SENDER" -S smtp="$SMTP_SERVER" -S smtp-auth-user="$EMAIL_USER" -S smtp-auth-password="$EMAIL_PASS" -S smtp-auth=login; then
			handle_error "Failed to send alert email"
		fi
		log "INFO" "Send $level alert to $EMAIL_RECIPIENT"
	

}
	monitor() {
	while true; do
		Check_usage
		local alert_level=""

		if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ] || [ "$SESSION_TIME" -gt "$SCREEN_TIME" ] || [ "$MEM_USAGE" -ge "$MEM_THRESHOLD" ] || [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
			if [ "$CPU_USAGE" -ge $((CPU_THRESHOLD + 10)) ] || [ "$MEM_USAGE" -ge $((MEM_THRESHOLD + 10)) ] || [ "$DISK_USAGE" -ge $((DISK_THRESHOLD + 10)) ] ;then
				alert_level="CRITICAL"
			else
				alert_level="WARNING"
			fi
			echo "$alert_level threshold exceeded! Sending alert..."
			            send_alert "$alert_level"
		fi
		sleep "$INTERVAL"
	done
}

while getopts "i:c:m:d" opt; do
	case $opt in 
		i) INTERVAL="$OPTARG" ;;
		c) CPU_THRESHOLD="$OPTARG" ;;
		m) MEM_THRESHOLD="$OPTARG" ;;
		d) DISK_THRESHOLD="$OPTARG" ;;
		?) echo "Usage: $0 [-i interval] [-c cpu_threshold] [-m mem_threshold] [-d disk_threshold]"; exit 1 ;;
	esac
done


[[ "$CPU_THRESHOLD" -lt 0 || "$CPU_THRESHOLD" -gt 100 ]] && handle_error "CPU thrushold must be 1-100"
[[ "$MEM_THRESHOLD" -lt 0 || "$MEM_THRESHOLD" -gt 100 ]] && handle_error "MEM thrushold must be 1-100"
[[ "$DISK_THRESHOLD" -lt 0 || "$DISK_THRESHOLD" -gt 100 ]] && handle_error "DISK thrushold must be 1-100"

mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || handle_error "Cannot create Log directory"


monitor

