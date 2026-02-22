# Linux Mastery Lab Notes

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

Topics covered in this workspace path for repeat practice:

- File permissions
- Users and groups
- Process management
- `systemctl` and `journalctl`
- Networking commands and `ufw`
- Cron jobs
- Disk and memory inspection
- TCP/UDP port inspection

Use a throwaway Ubuntu VM. Keep a snapshot before firewall/disk labs.

Suggested repeat loop:

1. Create the symptom (intentional break).
2. Capture evidence (`systemctl status`, `journalctl`, `ss`, `df`, `free`).
3. Fix one thing at a time.
4. Write a short incident note.
