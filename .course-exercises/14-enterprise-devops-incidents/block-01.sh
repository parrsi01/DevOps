cd /home/sp/cyber-course/projects/DevOps
sed -n '1,90p' docs/enterprise-devops-incidents-lab.md
rg -n '^## [0-9]+\.' docs/enterprise-devops-incidents-lab.md
