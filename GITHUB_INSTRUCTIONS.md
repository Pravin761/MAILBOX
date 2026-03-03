# GitHub Upload Instructions - ULLCON 2026 Mailbox Challenge

## Quick Start (3 Steps)

### Step 1: Navigate to Mailbox Directory
```bash
cd Mailbox
```

### Step 2: Run Upload Script
```bash
chmod +x GITHUB_UPLOAD.sh
./GITHUB_UPLOAD.sh
```

### Step 3: Done!
Your code is now on GitHub at: https://github.com/Pravin761/MAILBOX

---

## Manual Steps (If Script Doesn't Work)

### Step 1: Initialize Git Repository
```bash
cd Mailbox
git init
```

### Step 2: Configure Git
```bash
git config user.name "Pravin761"
git config user.email "your-email@example.com"
```

### Step 3: Add Remote Repository
```bash
git remote add origin https://github.com/Pravin761/MAILBOX.git
```

### Step 4: Add All Files
```bash
git add .
```

### Step 5: Create Initial Commit
```bash
git commit -m "ULLCON 2026 - Mailbox CTF Challenge - Kernel Exploitation Research

- Vulnerability: TOCTOU Race Condition in /dev/mailbox driver
- 4 exploit variants with different strategies
- Comprehensive technical analysis and documentation
- 5 exploitation attempts documented
- Deep dive into kernel exploitation techniques"
```

### Step 6: Push to GitHub
```bash
git branch -M main
git push -u origin main
```

---

## What Gets Uploaded

### Exploit Code (4 files)
- exploit_toctou.c
- exploit_mailbox_toctou.c
- exploit_final.c
- exploit_aggressive.c

### Documentation (5 files)
- CTF_REPORT.md
- TECHNICAL_ANALYSIS.md
- SOLUTION.md
- README.md
- BUILDROOT_GUIDE.md

### Summary Files
- SUBMISSION_SUMMARY.txt
- FILES_TO_SUBMIT.txt

### Challenge Files
- bzImage
- rootfs.ext3
- vmlinux
- run.sh
- .config

---

## GitHub Repository Structure

```
MAILBOX/
├── exploit_toctou.c                 # Symlink race exploit
├── exploit_mailbox_toctou.c         # Mailbox TOCTOU exploit
├── exploit_final.c                  # Multi-threaded exploit
├── exploit_aggressive.c             # Aggressive variant
├── CTF_REPORT.md                    # Main research report
├── TECHNICAL_ANALYSIS.md            # Technical deep dive
├── SOLUTION.md                      # Complete solution
├── README.md                        # Overview
├── BUILDROOT_GUIDE.md               # Step-by-step guide
├── SUBMISSION_SUMMARY.txt           # Quick summary
├── FILES_TO_SUBMIT.txt              # Submission checklist
├── GITHUB_INSTRUCTIONS.md           # This file
├── GITHUB_UPLOAD.sh                 # Upload script
├── bzImage                          # Kernel image
├── rootfs.ext3                      # Filesystem
├── vmlinux                          # Kernel with symbols
├── run.sh                           # QEMU runner
└── .config                          # Kernel config
```

---

## Troubleshooting

### Issue: "fatal: not a git repository"
**Solution:**
```bash
cd Mailbox
git init
```

### Issue: "fatal: could not read Username"
**Solution:**
```bash
git config user.name "Pravin761"
git config user.email "your-email@example.com"
```

### Issue: "fatal: 'origin' does not appear to be a 'git' repository"
**Solution:**
```bash
git remote remove origin
git remote add origin https://github.com/Pravin761/MAILBOX.git
```

### Issue: "Permission denied (publickey)"
**Solution:** You need to set up SSH keys or use HTTPS with personal access token
```bash
# Use HTTPS instead
git remote set-url origin https://github.com/Pravin761/MAILBOX.git
```

### Issue: "fatal: The current branch main does not have any upstream tracking information"
**Solution:**
```bash
git push -u origin main
```

---

## After Upload

### View on GitHub
Visit: https://github.com/Pravin761/MAILBOX

### Add Description
1. Go to repository settings
2. Add description: "ULLCON 2026 - Mailbox CTF Challenge - Kernel Exploitation Research"
3. Add topics: kernel, exploitation, ctf, toctou, race-condition

### Add README
The README.md file will automatically be displayed on the repository homepage.

---

## Commands Summary

```bash
# Navigate to directory
cd Mailbox

# Initialize git
git init

# Configure git
git config user.name "Pravin761"
git config user.email "your-email@example.com"

# Add remote
git remote add origin https://github.com/Pravin761/MAILBOX.git

# Add files
git add .

# Commit
git commit -m "ULLCON 2026 - Mailbox CTF Challenge"

# Push
git branch -M main
git push -u origin main
```

---

## One-Liner (Copy & Paste)

```bash
cd Mailbox && git init && git config user.name "Pravin761" && git config user.email "your-email@example.com" && git remote add origin https://github.com/Pravin761/MAILBOX.git && git add . && git commit -m "ULLCON 2026 - Mailbox CTF Challenge - Kernel Exploitation Research" && git branch -M main && git push -u origin main
```

---

## Verify Upload

After upload, verify everything is on GitHub:

```bash
# Check remote
git remote -v

# Check status
git status

# View commits
git log --oneline
```

---

## Next Steps

1. ✓ Upload to GitHub
2. Share repository link
3. Add to portfolio
4. Submit to CTF organizers

---

**Repository:** https://github.com/Pravin761/MAILBOX

Good luck!
