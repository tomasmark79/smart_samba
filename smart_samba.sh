#!/bin/bash

DEBUG=1

log() {
    if [ "$DEBUG" ]; then
        echo "-> $1"
    fi
}

umount_samba() {
    sudo umount -f -l "$MOUNT_POINT" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        log "Successfully Unmounted from $MOUNT_POINT."
    else
        log "Already Unmounted from $MOUNT_POINT."
    fi
}

smart_samba_mount() {
    echo "smart_samba_mount() {" 
    date

    credential_file=$1
    remote_samba_share=$2
    remote_ip=$3
    mount_point=$4
    ping_check=$5
    ping_result=""
    port_check=$6
    port_number=$7
    port_status=$8
    port_result=""

    # Check if lock file exists
    lock_file="/tmp/smart_mount.lock"
    if [ -f "$lock_file" ]; then
        log "Script is already running or was not terminated correctly. Exiting."
        exit 1
    else
        touch "$lock_file"
    fi

    # Check if is ping check enabled
    if [ "$ping_check" == "yes" ]; then
        if ping -c 1 -W 1 "$remote_ip" >/dev/null; then
            ping_result="accessible"

            # Check if is port check enabled and if is device accessible
            if [ "$port_check" == "yes" ]; then
                if /bin/bash -c "nc -z -w 5 $remote_ip $port_number"; then
                    port_result="opened"
                else
                    port_result="closed"
                fi
            fi
        else
            ping_result="not_accessible"
            log "Destination IP $remote_ip for $mount_point is $ping_result. (preventive umount)"
            
            # Magic is umount in screen session to smooth the process
            screen -dmS umount_samba bash -c "sudo umount -f -l $mount_point"
            
            # Clean up
            rm -f "$lock_file"
            
            # exit from function
            return
        fi
    fi

    log "Port $port_number is $port_result."

    # Check if the share is already connected
    if mountpoint -q "$mount_point"; then
        log "Samba share $remote_samba_share already connected to $mount_point."
    else
        Connection to Samba share if ping and port check passed
        if [ "$ping_result" == "accessible" ] && ([ "$port_result" == "$port_status" ] || [ "$port_check" != "yes" ]); then
            sudo mount -t cifs -o noatime,guest,_netdev,vers=3.0,noauto,credentials=$credential_file,uid=1000,gid=1000,iocharset=utf8,sec=ntlmssp,nofail,soft,noperm "$remote_samba_share" "$mount_point"
            if [ $? -eq 0 ]; then
                log "Samba share $remote_samba_share was successfully connected to $mount_point."
            else
                log "Samba share $remote_samba_share was unsuccessfully connected to $mount_point. (Failed)"
            fi
        else
            log "Samba share $remote_samba_share was not connected to $mount_point. (filtered, preventive umount)"
            
            # Magic is umount in screen session to smooth the process
            screen -dmS umount_samba bash -c "sudo umount -f -l $mount_point"
        fi
    fi

    # Clean up
    rm -f "$lock_file"
}

# Params:         CREDENTIAL_FILE        SAMBA_SHARE             TARGET_IP       MOUNT_POINT PING_CHECK PORT_CHECK PORT_NUMBER PORT_STATUS

# Nas with opened port 7922
smart_samba_mount "/root/credential2nas" "//192.168.79.11/homes" "192.168.79.11" "/mnt/nas/" yes yes 7922 opened
smart_samba_mount "/root/credential2nas" "//192.168.79.11/music" "192.168.79.11" "/mnt/nas/music" yes yes 7922 opened
smart_samba_mount "/root/credential2nas" "//192.168.79.11/video" "192.168.79.11" "/mnt/nas/video" yes yes 7922 opened
smart_samba_mount "/root/credential2nas" "//192.168.79.11/NetBackup" "192.168.79.11" "/mnt/nas/NetBackup" yes yes 7922 opened

# MS Windows with closed port 7922
smart_samba_mount "/root/credential2pc" "//192.168.79.111/c" "192.168.79.111" "/mnt/pcwin/c" yes yes 7922 closed
#smart_samba_mount "/root/credential2pc" "//192.168.79.111/d" "192.168.79.111" "/mnt/pcwin/d" yes yes 7922 closed
smart_samba_mount "/root/credential2pc" "//192.168.79.111/f" "192.168.79.111" "/mnt/pcwin/f" yes yes 7922 closed
#smart_samba_mount "/root/credential2pc" "//192.168.79.111/l" "192.168.79.111" "/mnt/pcwin/l" yes yes 7922 closed

# Libvirts Windows
smart_samba_mount "/root/credential2winku" "//192.168.78.100/c" "192.168.78.100" "/mnt/winku/c" yes yes 7922 closed
smart_samba_mount "/root/credential2winku" "//192.168.78.144/c" "192.168.78.144" "/mnt/windev/c" yes yes 7922 closed