# Encryption

I’ve implemented full-disk encryption on my server. This meant setting up LUKS. Actual setup of encryption is outside of the scope of this document. A consequence of full system encryption is that you need to type in your system passphrase each time you power on your computer.

Using Dropbear, it's possible to enter the password remotely during the boot process. The trick involves embedding a small ssh server (dropbear) in the initramfs that allows you to enter the password remotely for the root partition at boot time.

***NOTE*** It's important to use **dropbear-initramfs**, not just dropbear

### Configure GRUB

ignore this step, otherwise you have to specify the IP configuration at the Kernel boot line. To do this edit the file ```/etc/default/grub``` and define the line:

```sh
GRUB_CMDLINE_LINUX="ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>"
```

If your server gets the IP address automatically (DHCP) 

```sh
GRUB_CMDLINE_LINUX="ip=dhcp"
```

Using the format specified in the file Documentation/nfsroot.txt of the Linux kernel documentation. For example:
GRUB_CMDLINE_LINUX="ip=192.168.122.192::192.168.122.1:255.255.255.0::eth0:none"

Reload the grub configuration

```sh
update-grub
```

### Step 1. Install dropbear and busybox

During the installation, I get a warning about dropbear: WARNING: Invalid authorized_keys file, remote unlocking of cryptroot via SSH won't work!, and I was not able to find the needed keys.

First make sure that initramfs-conf busybox and dropbear-initramfs are installed

```sh
sudo apt-get install initramfs-conf dropbear-initramfs busybox
```

### Step 2. Activate BUSYBOX and DROPBEAR in initramfs

```sh
sudo nano /etc/initramfs-tools/initramfs.conf /etc/dropbear/initramfs/dropbear.conf
```
Alose make sure this is done: 

```sh
sudo mkdir /etc/initramfs-tools/root
sudo mkdir /etc/initramfs-tools/root/.ssh
sudo cp dropbear_* /etc/initramfs-tools/root/.ssh/
sudo cp id_* /etc/initramfs-tools/root/.ssh/
sudo cp authorized_keys /etc/initramfs-tools/root/.ssh/
```

### Step 3. Generate our keys, convert the openssh key to dropbear format

```sh
sudo nano dropbear -p 2222 -R -F
```

### Step 4. Set dropbear to start

```sh
sudo nano /etc/initramfs-tools/initramfs.conf 
```
Change NO_START=1 to NO_START=0


Here's a [script](https://gist.github.com/gusennan/712d6e81f5cf9489bd9f) that may be usefull to you.


### Step 5 KEYS

Add your public key (most of the time ~/.ssh/id_rsa.pub) in the file /etc/dropbear-initramfs/authorized_keys.

To create a key (in dropbear format):

```
dropbearkey -t rsa -f /etc/initramfs-tools/root/.ssh/id_rsa.dropbear
```

To convert the key from dropbear format to openssh format:

```
/usr/lib/dropbear/dropbearconvert dropbear openssh \
    /etc/initramfs-tools/root/.ssh/id_rsa.dropbear \
    /etc/initramfs-tools/root/.ssh/id_rsa
```

To extract the public key:
```
dropbearkey -y -f /etc/initramfs-tools/root/.ssh/id_rsa.dropbear | \
    grep "^ssh-rsa " > /etc/initramfs-tools/root/.ssh/id_rsa.pub
```
To add the public key to the authorized_keys file:
```
cat /etc/initramfs-tools/root/.ssh/id_rsa.pub >> /etc/initramfs-tools/root/.ssh/authorized_keys 
```
```sh
update-initramfs -u
```

### Unlocking

Note, if you want to avoid to have clash between the keys between dropbear and openssh (they share the same ip, but use a different key), you may want to put in your client ~/.ssh/config something like that:

```sh
Host myserver_luks_unlock
     User root
     Hostname <myserver>
     # The next line is useful to avoid ssh conflict with IP
     HostKeyAlias <myserver>_luks_unlock
     Port 22
     PreferredAuthentications publickey
     IdentityFile ~/.ssh/id_rsa
```

To unlock from remote, you could do something like this:

```sh
ssh -o "UserKnownHostsFile=~/.ssh/known_hosts.initramfs" \
    -i "~/id_rsa.initramfs" root@initramfshost.example.com \
    "echo -ne \"secret\" >/lib/cryptsetup/passfifo"
```

### Here's a Powershell Script to unlock the server from a Windows machine

```powershell
function Unblock-MiniSrvRootFs { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]       
        [String]$ServerIp = "10.0.0.111"   
    )

    try{
        $IsConnected = $False
        Write-Host "Waiting for minisrv ($ServerIp) to be up..." -NoNewLine
        While($IsConnected -eq $False){
            Start-Sleep 1
            Write-Host ". " -NoNewLine
            $IsConnected = Test-Connection -TargetName "$ServerIp" -Ping -IPv4 -Count 1 -TimeoutSeconds 1 -Quiet -ErrorAction Ignore
        }

        Write-Host "`nok!"

        $SshExe = (Get-Command 'ssh.exe').Source
        $Credz = Get-AppCredentials -Id "minisrv.initramfs"

        if($Null -eq $Credz){ throw "no credentials found!" }

        $Username = $Credz.UserName
        $Password = $Credz.GetNetworkCredential().Password
        $SshArg = '{0}@{1}' -f $Username, $ServerIp
        $Cmd = 'echo -ne "{0}" >/lib/cryptsetup/passfifo' -f $Password
        &"$SshExe" '-o' "UserKnownHostsFile=~/.ssh/known_hosts.initramfs" "$SshArg" "$Cmd"

    }catch{
      Write-Host "$_" -f DarkRed
    }    
} 
```



```sh
$ zcat /usr/share/doc/cryptsetup/README.remote.gz

unlocking rootfs via ssh login in initramfs
-------------------------------------------

You can unlock your rootfs on bootup from remote, using ssh to log in to the
booting system while it's running with the initramfs mounted.


Setup
-----

For remote unlocking to work, the following packages have to be installed
before building the initramfs: dropbear busybox

The file /etc/initramfs-tools/initramfs.conf holds the configuration options
used when building the initramfs. It should contain BUSYBOX=y (this is set as
the default when the busybox package is installed) to have busybox installed
into the initramfs, and should not contain DROPBEAR=n, which would disable
installation of dropbear to initramfs. If set to DROPBEAR=y, dropbear will
be installed in any case; if DROPBEAR isn't set at all, then dropbear will only
be installed in case of an existing cryptroot setup.

The host keys used for the initramfs are dropbear_dss_host_key and
dropbear_rsa_host_key, both located in/etc/initramfs-tools/etc/dropbear/.
If they do not exist when the initramfs is compiled, they will be created
automatically. Following are the commands to create them manually:

# dropbearkey -t dss -f /etc/initramfs-tools/etc/dropbear/dropbear_dss_host_key
# dropbearkey -t rsa -f /etc/initramfs-tools/etc/dropbear/dropbear_rsa_host_key

As the initramfs will not be encrypted, publickey authentication is assumed.
The key(s) used for that will be taken from
/etc/initramfs-tools/root/.ssh/authorized_keys.
If this file doesn't exist when the initramfs is compiled, it will be created
and /etc/initramfs-tools/root/.ssh/id_rsa.pub will be added to it.
If the latter file doesn't exist either, it will be generated automatically -
you will find the matching private key which you will later need to log in to
the initramfs under /etc/initramfs-tools/root/.ssh/id_rsa (or id_rsa.dropbear
in case you need it in dropbear format). Following are the commands to do the
respective steps manually:

To create a key (in dropbear format):

# dropbearkey -t rsa -f /etc/initramfs-tools/root/.ssh/id_rsa.dropbear

To convert the key from dropbear format to openssh format:

# /usr/lib/dropbear/dropbearconvert dropbear openssh \
    /etc/initramfs-tools/root/.ssh/id_rsa.dropbear \
    /etc/initramfs-tools/root/.ssh/id_rsa

To extract the public key:

# dropbearkey -y -f /etc/initramfs-tools/root/.ssh/id_rsa.dropbear | \
    grep "^ssh-rsa " > /etc/initramfs-tools/root/.ssh/id_rsa.pub

To add the public key to the authorized_keys file:

# cat /etc/initramfs-tools/root/.ssh/id_rsa.pub >> /etc/initramfs-tools/root/.ssh/authorized_keys

In case you want some interface to get configured using dhcp, setting DEVICE= in
/etc/initramfs-tools/initramfs.conf should be sufficient.  The initramfs should
also honour the ip= kernel parameter.
In case you use grub, you probably might want to set it in /boot/grub/menu.lst,
either in the '# kopt=' line or appended to specific 'kernel' line(s).
The ip= kernel parameter is documented in Documentation/nfsroot.txt in the
kernel source tree.


Issues
------

Don't forget to run update-initramfs when you changed the config to make it
effective!

Collecting enough entropy for the ssh daemon sometimes seems to be an issue.
Startup of the ssh daemon might be delayed until enough entropy has been
retrieved. This is non-blocking for the startup process, so when you are at the
console you won't have to wait for the sshd to complete its startup.


Unlocking procedure
-------------------

To unlock from remote, you could do something like this:

# ssh -o "UserKnownHostsFile=~/.ssh/known_hosts.initramfs" \
    -i "~/id_rsa.initramfs" root@initramfshost.example.com \
    "echo -ne \"secret\" >/lib/cryptsetup/passfifo"

This example assumes that you have an extra known_hosts file 
"~/.ssh/known_hosts.initramfs" which holds the cryptroot system's host-key,
that you have a file "~/id_rsa.initramfs" which holds the authorized-key for
the cryptroot system, that the cryptroot system's name is
"initramfshost.example.com", and that the cryptroot passphrase is "secret"
```

### Sources

[Unlocking a LUKS encrypted root partition remotely via SSH](http://blog.neutrino.es/2011/unlocking-a-luks-encrypted-root-partition-remotely-via-ssh/)
[How do I get dropbear to actually work with initramfs](https://askubuntu.com/questions/640815/how-do-i-get-dropbear-to-actually-work-with-initramfs)
[Remote unlocking LUKS encrypted LVM using Dropbear SSH in Ubuntu Server 14.04.1](https://stinkyparkia.wordpress.com/2014/10/14/remote-unlocking-luks-encrypted-lvm-using-dropbear-ssh-in-ubuntu-server-14-04-1-with-static-ipst/)
[SSH to decrypt encrypted LVM during headless server boot?](https://unix.stackexchange.com/questions/5017/ssh-to-decrypt-encrypted-lvm-during-headless-server-boot)