Creating a `systemd` service involves writing a service unit file and configuring it so that `systemd` can manage your service. Here's how you can create a custom service in Linux using `systemd`.

### Steps to Create a Service

#### 1. **Create a Service Unit File**
Service unit files for `systemd` are stored in `/etc/systemd/system/` (for custom services) or `/lib/systemd/system/` (for system-provided services). 

1. Open a terminal and create a new service file under `/etc/systemd/system/`:

   ```bash
   sudo nano /etc/systemd/system/my-custom-service.service
   ```

   Replace `my-custom-service.service` with the name of your service.

#### 2. **Define the Service Configuration**
The service file contains metadata and instructions about how the service should run. Here’s a basic template for a service:

```ini
[Unit]
Description=My Custom Service
After=network.target

[Service]
ExecStart=/path/to/your/script-or-program
Restart=always
User=myuser
WorkingDirectory=/path/to/working-directory

[Install]
WantedBy=multi-user.target
```

- **[Unit] Section**:
  - `Description`: A brief description of the service.
  - `After=network.target`: Ensures the service starts after the network is up. You can adjust this to suit your needs.

- **[Service] Section**:
  - `ExecStart`: The command to start your service. This could be a script, a binary, or any command you want to run as a service.
  - `Restart=always`: Tells `systemd` to always restart the service if it crashes or stops.
  - `User=myuser`: Run the service as a specific user (replace `myuser` with the actual user).
  - `WorkingDirectory`: The directory where the service should be executed.

- **[Install] Section**:
  - `WantedBy=multi-user.target`: This tells `systemd` that the service should be enabled in multi-user mode (the usual mode for non-graphical systems).

#### 3. **Save and Close the File**
After defining the service configuration, save the file and exit (`Ctrl + X`, then `Y`, then `Enter` in `nano`).

#### 4. **Reload `systemd` to Apply the New Service**
To make `systemd` recognize the new service, reload the `systemd` daemon:

```bash
sudo systemctl daemon-reload
```

#### 5. **Start and Enable the Service**
Now, you can start the service:

```bash
sudo systemctl start my-custom-service
```

To enable the service to start automatically on boot:

```bash
sudo systemctl enable my-custom-service
```

#### 6. **Check the Status of the Service**
You can check the status of the service to see if it's running correctly:

```bash
systemctl status my-custom-service
```

#### 7. **View Logs for the Service**
If your service encounters issues, you can view its logs using `journalctl`:

```bash
journalctl -u my-custom-service
```

### Example: Running a Python Script as a Service
If you have a Python script (`/home/myuser/myscript.py`) and want to run it as a service, your service file might look like this:

```ini
[Unit]
Description=Run My Python Script
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/myuser/myscript.py
Restart=always
User=myuser
WorkingDirectory=/home/myuser

[Install]
WantedBy=multi-user.target
```

### Summary of Commands
1. **Create the service file**:
   ```bash
   sudo nano /etc/systemd/system/my-custom-service.service
   ```

2. **Reload `systemd`**:
   ```bash
   sudo systemctl daemon-reload
   ```

3. **Start the service**:
   ```bash
   sudo systemctl start my-custom-service
   ```

4. **Enable the service at boot**:
   ```bash
   sudo systemctl enable my-custom-service
   ```

5. **Check the service status**:
   ```bash
   systemctl status my-custom-service
   ```

Once these steps are completed, your custom service will be created and managed by `systemd`, and you can start, stop, and enable it like any other system service.





To delete a service that you created and registered with `systemd`, follow these steps:

### 1. **Stop the Service**
First, stop the service if it's currently running:

```bash
sudo systemctl stop <service-name>
```

Replace `<service-name>` with the actual name of your service (without the `.service` extension).

### 2. **Disable the Service**
Disable the service to prevent it from starting automatically at boot:

```bash
sudo systemctl disable <service-name>
```

This removes any symbolic links created by `systemd` that link the service to system startup.

### 3. **Delete the Service File**
Find and delete the service file that you originally created. Typically, custom service files are placed in one of the following directories:
- `/etc/systemd/system/`
- `/lib/systemd/system/`

To remove the service file, run:

```bash
sudo rm /etc/systemd/system/<service-name>.service
```

or

```bash
sudo rm /lib/systemd/system/<service-name>.service
```

Make sure you are deleting the correct service file.

### 4. **Reload `systemd` Daemon**
After deleting the service file, you need to reload `systemd` to inform it of the change:

```bash
sudo systemctl daemon-reload
```

This command forces `systemd` to reload its configuration files and reflect the removal of the service.

### 5. **Remove Service-Related Files (Optional)**
If your service involved additional files like logs, environment files, or configuration files, you might also want to delete them. For example, if you had log files in `/var/log/` or configuration files under `/etc/`, you can manually remove them.

---

By following these steps, you will have completely removed the service from your system. If you want to confirm that it's gone, you can check the service status:

```bash
systemctl status <service-name>
```

This should return an error indicating that the service file no longer exists.