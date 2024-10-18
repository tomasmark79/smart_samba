# Smart Samba Mount Script

## Overview

This script is used to intelligently manage mounting and unmounting Samba shares on Linux. It performs checks to ensure the remote devices are accessible before attempting to mount, avoiding unnecessary system failures.

### Key Features:
- Checks if a remote device is accessible via `ping`.
- Optionally checks if a specific port on the remote device is open using `netcat`.
- Automatically unmounts if the device is not accessible or if the conditions are not met.
- Utilizes `screen` to unmount shares smoothly in the background.
- Prevents concurrent executions by using a lock file.

### Syntax:
```bash
smart_samba_mount <CREDENTIAL_FILE> <SAMBA_SHARE> <TARGET_IP> <MOUNT_POINT> <PING_CHECK> <PORT_CHECK> <PORT_NUMBER> <PORT_STATUS>
```

### Parameters:
- `CREDENTIAL_FILE`: Path to the file containing Samba credentials.
- `SAMBA_SHARE`: The path to the remote Samba share (e.g., `//192.168.79.11/homes`).
- `TARGET_IP`: IP address of the remote device.
- `MOUNT_POINT`: Local directory where the share should be mounted.
- `PING_CHECK`: Set to `yes` to enable ping checking.
- `PORT_CHECK`: Set to `yes` to enable port checking.
- `PORT_NUMBER`: The port number to check (optional if `PORT_CHECK` is `no`).
- `PORT_STATUS`: Expected port status (`opened` or `closed`).

### Example Commands:
Mount multiple Samba shares with proper checks:

```bash
# Mount NAS shares with port check on port 7922
smart_samba_mount "/root/credential2nas" "//192.168.79.11/homes" "192.168.79.11" "/mnt/nas/" yes yes 7922 opened
smart_samba_mount "/root/credential2nas" "//192.168.79.11/music" "192.168.79.11" "/mnt/nas/music" yes yes 7922 opened

# Mount Windows shares with closed port 7922
smart_samba_mount "/root/credential2pc" "//192.168.79.111/c" "192.168.79.111" "/mnt/pcwin/c" yes yes 7922 closed
```

## Logs

The script provides logs that can be enabled or disabled using the `DEBUG` variable. When set to `1`, log output will display status messages for mounts and unmounts.

## Notes

- Ensure the Samba client is installed on your system:
  ```bash
  sudo apt install cifs-utils
  ```
- If the script doesn't mount correctly, ensure the provided credentials are valid, and the remote device is reachable.

"Writing and fine-tuning this script took me quite a few hours, so if you like it, don't hesitate to send me a little something for a coffee. ☕😊"