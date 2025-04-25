# Batch InfoStealer (Discord Webhook)

A lightweight information stealer written in Batch that collects system details and Steam data, then exfiltrates it via Discord webhooks.

**⚠️ Disclaimer:** This tool is for **research and educational purposes only**. Unauthorized use against systems you do not own is illegal.

---

### Features
- **System Information** (Username, Hostname, OS, Public IP)
- **No Hardcoded Webhook** (Input at runtime)
- **Basic Obfuscation Support** (Manual packing recommended)

---

### Usage
1. **Run the Builder**
   - The script will prompt for a Discord webhook on execution.
   - No manual editing required.

2. **Compilation (Optional)**
   - Convert to EXE using a tool like `Bat To Exe Converter`.
   - For better evasion, apply **VMProtect** or similar obfuscators post-compilation.

3. **Testing**
   - Always test in a controlled environment (virtual machine) before any real deployment.

---

### Detection Avoidance
To reduce AV detection:
- **Obfuscate the payload** (VMProtect, Themida, or custom packers)
- **Limit execution environments** (Some security solutions detect Batch-based stealers easily)

---

### Risks
- **Discord actively monitors and bans malicious webhooks.**
- **Victim systems may flag the script if poorly obfuscated.**
- **Legal consequences apply for unauthorized data collection.**

---

**Final Note:** This is a proof-of-concept tool. Use responsibly.
