# Section 7 - DevSecOps CI/CD

Source docs:

- `docs/devsecops-cicd-lab.md`
- `projects/github-actions-ci-demo/README.md`

## What Type Of Software Engineering This Is

Security engineering inside software delivery pipelines (DevSecOps). You are adding risk checks to CI/CD, not replacing CI/CD.

## Definitions

- `SAST`: static code analysis for security issues.
- `secret scanning`: detection of exposed credentials/tokens.
- `image scanning`: vulnerability scanning of container images.
- `hardening`: reducing attack surface (non-root, minimal base image, safer config).
- `CVSS`: severity scoring framework for vulnerabilities.

## Concepts And Theme

A security check exists to reduce a specific risk. Learn the risk, not just the tool name.

## 1. Step 1 - Read the DevSecOps note and target project

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' docs/devsecops-cicd-lab.md
sed -n '1,220p' projects/github-actions-ci-demo/README.md
```

What you are doing: reviewing the security controls, simulations, and the example project used in this section.

## 2. Step 2 - Inspect workflows and map security controls to jobs

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/github-actions-ci-demo
ls .github/workflows
rg -n 'trivy|gitleaks|codeql|audit|dependency-review|permissions:' .github/workflows/*.yml
```

What you are doing: locating each security control in the CI workflows and identifying where it runs in the pipeline.

## 3. Step 3 - Inspect the hardened vs insecure Docker examples

```bash
ls examples/secure-nginx
sed -n '1,220p' examples/secure-nginx/Dockerfile
sed -n '1,220p' examples/secure-nginx/Dockerfile.insecure
```

What you are doing: comparing container hardening patterns (non-root, minimal base, safer defaults) with intentionally insecure patterns.

## 4. Step 4 - Run one local secret-detection drill (safe fake credential)

```bash
echo 'AWS_SECRET_ACCESS_KEY=AKIAEXAMPLESECRET1234567890' > tmp-secret-demo.env
rg -n 'AWS_SECRET_ACCESS_KEY' tmp-secret-demo.env
```

What you are doing: creating a fake secret pattern so you understand what secret scanners are designed to catch.

Optional local checks if tooling is installed:

```bash
npm ci
npm audit --audit-level=high
```

## 5. Step 5 - Clean up and record the risk mapping

```bash
rm -f tmp-secret-demo.env
rg -n 'Trivy|gitleaks|CodeQL|CVSS|risk' README.md docs/devsecops-cicd-lab.md
```

What you are doing: removing the drill artifact and reviewing the documented risk language for your notes.

## Done Check

You can explain one thing each scanner catches and one thing it does not catch.
