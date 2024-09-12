## Cron - Backup Every Day

To have your script run once every day, you can use **cron**, which is a Linux utility for scheduling tasks. Here's how you can set it up:

### Steps to Schedule the Script with Cron:

1. **Place your script in a directory**:  
   Ensure that the `create_backup.sh` script is saved somewhere on your server, for example, in `/srv/scripts/create_backup.sh`.

2. **Make the script executable**:  
   Make sure the script has the appropriate executable permissions:
   ```bash
   chmod +x /srv/scripts/create_backup.sh
   ```

3. **Edit the root user's crontab**:  
   Since the script needs to run as root, you will need to add it to the root user's crontab. You can do this by running:
   ```bash
   sudo crontab -e
   ```

4. **Add a cron job to run the script daily**:  
   Add the following line to the root's crontab file to schedule the script to run every day at, for example, 2:00 AM:

   ```bash
   0 2 * * * /srv/scripts/create_backup.sh
   ```

   ### Explanation of the cron syntax:
   - `0 2 * * *` means "at 2:00 AM every day."
   - `/srv/scripts/create_backup.sh` is the full path to the script.

   If you want it to run at a different time, you can modify the time accordingly:
   - First value: minute (0-59)
   - Second value: hour (0-23)
   - Third value: day of the month (1-31)
   - Fourth value: month (1-12)
   - Fifth value: day of the week (0-7, where both 0 and 7 are Sunday)

5. **Save and Exit**:  
   After adding the line, save and exit the crontab editor (in most editors, `Ctrl + O` to save and `Ctrl + X` to exit).

### Verifying the Cron Job:
- To verify that the cron job has been added, you can list the cron jobs with:
  ```bash
  sudo crontab -l
  ```

Now, the `create_backup.sh` script will run automatically every day at 2:00 AM (or your chosen time).

### Log Output:
If you want to log the script's output to a file for troubleshooting or review, you can modify the cron job to include a redirection to a log file:
```bash
0 2 * * * /srv/scripts/create_backup.sh >> /var/log/backup_script-config.log 2>&1
```

This will append both standard output and error messages to `/var/log/backup_script.log`.

Let me know if you need any additional help!