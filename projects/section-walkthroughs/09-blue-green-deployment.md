# Section 9 - Blue/Green Deployment

Source docs:

- `docs/blue-green-deployment-lab.md`
- `projects/blue-green-deployment-lab/README.md`

## What Type Of Software Engineering This Is

Release engineering and deployment safety engineering (traffic management, canarying, rollback, health-gated promotion).

## Definitions

- `blue/green`: two versions deployed at the same time, traffic switched between them.
- `canary`: send a small percentage of traffic to the new version first.
- `cutover`: change traffic routing to the new version.
- `rollback`: route back to a known-good version.
- `health gate`: only promote if health checks pass.

## Concepts And Theme

Deployment success is not the same as release success. Traffic and health decide release safety.

## 1. Step 1 - Read the lab and confirm endpoints

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' projects/blue-green-deployment-lab/README.md
```

What you are doing: learning the router/app endpoints and the rollback commands before you change traffic.

## 2. Step 2 - Start the lab and verify routing status

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/blue-green-deployment-lab
./scripts/start.sh
./scripts/status.sh
curl -s http://127.0.0.1:8088/router-status
curl -s http://127.0.0.1:8088/
```

What you are doing: starting the router plus both app versions and confirming the current traffic weights.

## 3. Step 3 - Run a canary release and sample traffic

```bash
./scripts/set_canary.sh 10
./scripts/sample_traffic.sh 50
curl -s http://127.0.0.1:8088/router-status
```

What you are doing: sending a small portion of traffic to green and sampling responses to see if results stay healthy.

## 4. Step 4 - Simulate a bad deployment and perform rollback

```bash
./scripts/simulate_bad_deployment.sh
./scripts/logs.sh app_green
./scripts/rollback_to_blue.sh
./scripts/sample_traffic.sh 30
./scripts/logs.sh nginx
```

What you are doing: creating a controlled failure, collecting evidence, then rolling traffic back to the known-good blue version.

## 5. Step 5 - Stop and reset the lab

```bash
./scripts/stop.sh
./scripts/reset.sh
```

What you are doing: shutting down containers and resetting shared state so the next deployment drill starts clean.

## Done Check

You can explain the difference between:

- deploy new version
- route traffic to new version
- promote release
- rollback release
