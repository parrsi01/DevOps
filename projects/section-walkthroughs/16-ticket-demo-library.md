# Section 16 - Ticket Demo Library

Source docs:

- `docs/ticket-demo-index.md`
- `tickets/README.md`
- `tickets/docker/`
- `tickets/cicd/`

## What Type Of Software Engineering This Is

Operational troubleshooting practice (incident simulation drills). This section builds repetition and pattern recognition.

## Definitions

- `ticket`: a scoped issue report with reproduce/debug/fix workflow.
- `reproduce`: intentionally recreate the failure.
- `debug evidence`: logs/status/commands that prove what failed.
- `verify`: prove the fix worked.
- `reset`: return the lab to a clean state for repeat practice.

## Concepts And Theme

Do not skip the reset step. Repeatability is the training value.

## 1. Step 1 - Read the ticket indexes and practice loop

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' docs/ticket-demo-index.md
sed -n '1,220p' tickets/README.md
```

What you are doing: understanding the overall ticket system and the expected reproduce -> debug -> fix -> reset workflow.

## 2. Step 2 - List tickets in order and choose one

```bash
ls -1 tickets/docker
ls -1 tickets/cicd
sed -n '1,220p' tickets/docker/TKT-001-crash-loop/README.md
```

What you are doing: selecting a single drill and reading its exact scenario and command sequence before running anything.

## 3. Step 3 - Run one Docker ticket end-to-end (TKT-001 example)

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/docker-production-lab
docker build -t docker-prod-lab:prod .
./scripts/simulate_crash_loop.sh
docker ps -a --filter name=crash-loop
docker inspect -f 'status={{.State.Status}} exit={{.State.ExitCode}} restarts={{.RestartCount}}' crash-loop
docker logs crash-loop --tail 50
```

What you are doing: reproducing the ticket exactly, then gathering the minimum evidence needed to identify the root cause.

## 4. Step 4 - Fix/reset the Docker ticket and review one CI/CD ticket

```bash
docker rm -f crash-loop
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,160p' tickets/cicd/TKT-101-lint-failure/README.md
```

What you are doing: resetting the Docker drill and switching to a CI/CD ticket to practice a different failure category.

## 5. Step 5 - Capture a repeatable ticket note template

```bash
cat > /tmp/section16-ticket-note.md <<'NOTE'
# Ticket Practice Note
Ticket ID:
Reproduction proof:
Debug evidence (commands + key output):
Root cause:
Fix:
Verification:
Reset confirmation:
NOTE
cat /tmp/section16-ticket-note.md
rm -f /tmp/section16-ticket-note.md
```

What you are doing: standardizing how you document each drill so your reasoning improves with repetition.

## Done Check

You can complete a ticket without skipping any phase: reproduce, debug, fix, verify, reset.
