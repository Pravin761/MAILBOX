#!/bin/bash

# GitHub Upload Script for ULLCON 2026 - Mailbox Challenge
# Repository: https://github.com/Pravin761/MAILBOX

echo "╔════════════════════════════════════════════════════════╗"
echo "║     Uploading to GitHub: Pravin761/MAILBOX            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Navigate to Mailbox directory
cd Mailbox || exit 1

# Initialize git repository (if not already done)
if [ ! -d .git ]; then
    echo "[*] Initializing git repository..."
    git init
    echo "[+] Git repository initialized"
else
    echo "[+] Git repository already exists"
fi

# Configure git (if needed)
echo "[*] Configuring git..."
git config user.name "Pravin761" 2>/dev/null || true
git config user.email "your-email@example.com" 2>/dev/null || true

# Add remote (if not already added)
echo "[*] Adding remote repository..."
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/Pravin761/MAILBOX.git

# Add all files
echo "[*] Adding files to git..."
git add .

# Create commit
echo "[*] Creating commit..."
git commit -m "ULLCON 2026 - Mailbox CTF Challenge - Kernel Exploitation Research

- Vulnerability: TOCTOU Race Condition in /dev/mailbox driver
- 4 exploit variants with different strategies
- Comprehensive technical analysis and documentation
- 5 exploitation attempts documented
- Deep dive into kernel exploitation techniques"

# Push to GitHub
echo "[*] Pushing to GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║     Upload Complete!                                  ║"
echo "║     Repository: https://github.com/Pravin761/MAILBOX  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
