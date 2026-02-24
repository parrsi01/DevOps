#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

quick_mode=0
for arg in "$@"; do
  case "$arg" in
    --quick) quick_mode=1 ;;
    -h|--help)
      cat <<'USAGE'
Usage: ./validate_repo.sh [--quick]

Checks repository structure, library completeness, docs presence, shell syntax, and placeholder markers.
USAGE
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

failures=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; failures=$((failures+1)); }
warn() { echo "WARN: $1"; }
check_file() { [[ -f "$1" ]] && pass "$1 present" || fail "$1 present"; }
check_dir() { [[ -d "$1" ]] && pass "$1 present" || fail "$1 present"; }

echo "DevOps Repository Validation"
check_file README.md
check_dir docs
check_dir projects
check_dir tickets
check_dir scripts
check_dir Library
check_file docs/PROJECT_MANUAL.md
check_file docs/LESSON_EXECUTION_COMPANION.md
check_file docs/LESSON_RESEARCH_ANALYSIS_COMPANION.md
check_file docs/PROJECT_RUNBOOKS_DETAILED.md
check_file Library/README.md
check_file Library/00_full_course_q_and_a_sheet.md
check_file Library/00_full_lesson_and_ticket_demo_sheet.md
check_file .github/workflows/ci.yml
check_file .github/workflows/lint.yml
check_file validate_repo.sh

if python3 - <<'PY'
from pathlib import Path
import sys
lib = Path('Library')
files = sorted(p for p in lib.glob('*.md') if p.is_file())
if len(files) < 15:
    print(f"Expected >=15 markdown files in Library, found {len(files)}")
    sys.exit(1)
required = [
    'README.md',
    '00_full_course_q_and_a_sheet.md',
    '00_full_lesson_and_ticket_demo_sheet.md',
    '00_full_course_master_guide.md',
]
missing = [name for name in required if not (lib / name).exists()]
if missing:
    print(f"Missing required library files: {missing}")
    sys.exit(1)
print(f"Library completeness OK: {len(files)} files")
PY
then
  pass "Library completeness"
else
  fail "Library completeness"
fi

if python3 - <<'PY'
from pathlib import Path
import sys
root = Path('.')
md_count = sum(1 for _ in (root / 'docs').rglob('*.md'))
if md_count < 10:
    print(f"Expected >=10 docs markdown files, found {md_count}")
    sys.exit(1)
print(f"docs markdown count OK: {md_count}")
PY
then
  pass "Docs coverage"
else
  fail "Docs coverage"
fi

shell_failed=0
while IFS= read -r -d '' f; do
  if ! bash -n "$f"; then
    echo "Syntax error: $f"
    shell_failed=1
  fi
done < <(find scripts projects tickets -type f -name '*.sh' -print0 2>/dev/null)

bash -n validate_repo.sh || shell_failed=1
[[ $shell_failed -eq 0 ]] && pass "Shell syntax checks" || fail "Shell syntax checks"

py_failed=0
if find . -type f -name '*.py' -print -quit >/dev/null 2>&1; then
  while IFS= read -r -d '' f; do
    python3 -m py_compile "$f" || py_failed=1
  done < <(find . -type f -name '*.py' \
      -not -path './.git/*' \
      -not -path './.course-exercises/*' \
      -not -path './.course-state/*' \
      -print0)
  [[ $py_failed -eq 0 ]] && pass "Python syntax checks" || fail "Python syntax checks"
else
  warn "No Python files found"
fi

if command -v rg >/dev/null 2>&1; then
  if rg -n "TODO|TBD|FIXME|PLACEHOLDER|REPLACE_WITH_|lorem ipsum" . \
      --glob '!**/.git/**' \
      --glob '!.github/workflows/**' \
      --glob '!.course-exercises/**' \
      --glob '!.course-state/**' \
      --glob '!validate_repo.sh' \
      >/tmp/devops_placeholders.out; then
    cat /tmp/devops_placeholders.out
    fail "No placeholder/template markers remain"
  else
    pass "No placeholder/template markers remain"
  fi
else
  warn "rg not available; placeholder scan skipped"
fi
rm -f /tmp/devops_placeholders.out

if [[ $quick_mode -eq 0 ]]; then
  python3 - <<'PY'
from pathlib import Path
root = Path('.')
print('Repository Metrics')
print(f"docs_md={sum(1 for _ in (root/'docs').rglob('*.md'))}")
print(f"library_md={sum(1 for _ in (root/'Library').glob('*.md'))}")
print(f"projects={sum(1 for _ in (root/'projects').iterdir() if _.is_dir())}")
print(f"tickets={sum(1 for _ in (root/'tickets').rglob('*') if _.is_file())}")
PY
fi

if [[ $failures -ne 0 ]]; then
  echo "Validation failed with $failures issue(s)." >&2
  exit 1
fi

echo "Validation passed."
