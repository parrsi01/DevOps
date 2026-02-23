# Section 2 - Docker Production Lab

Source docs:

- `docs/docker-production-lab.md`
- `projects/docker-production-lab/README.md`

## What Type Of Software Engineering This Is

Container platform operations and release/runtime debugging (build -> run -> verify -> fail -> diagnose -> reset).

## Definitions

- `image`: packaged filesystem + runtime config used to create containers.
- `container`: running instance of an image.
- `compose`: multi-container local orchestration using `docker compose`.
- `health check`: a test endpoint/command used to prove the app is healthy.
- `crash loop`: repeated container restarts after startup failure.

## Concepts And Theme

Always classify the failure layer first: build, container start, network/port bind, or application runtime.

## 1. Step 1 - Open the module and lab instructions

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,160p' docs/docker-production-lab.md
sed -n '1,120p' projects/docker-production-lab/README.md
```

What you are doing: checking the lab purpose and the exact simulation scripts before running containers.

## 2. Step 2 - Build and start the baseline app

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/docker-production-lab
docker compose up -d --build
docker compose ps
```

What you are doing: building the image, starting the app, and confirming container state in one place (`docker compose ps`).

## 3. Step 3 - Verify app health and collect runtime evidence

```bash
curl http://127.0.0.1:8080/health
docker compose logs --tail=100
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

What you are doing: proving the service is reachable and collecting logs/ports before simulating a failure.

## 4. Step 4 - Run one repeatable failure simulation and diagnose it

```bash
./scripts/simulate_crash_loop.sh
docker ps -a --filter name=crash-loop
docker inspect -f 'status={{.State.Status}} exit={{.State.ExitCode}} restarts={{.RestartCount}}' crash-loop
docker logs crash-loop --tail 50
```

What you are doing: creating a known crash-loop scenario and using status/inspect/logs to prove the failure mode.

## 5. Step 5 - Reset the lab cleanly

```bash
docker rm -f crash-loop 2>/dev/null || true
docker compose down -v --remove-orphans
```

What you are doing: removing the simulated broken container and returning the lab to a clean state for the next run.

## Done Check

You can state whether a failure is in:

- image build
- container startup
- port/network binding
- app runtime/health endpoint
