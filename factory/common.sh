#!/bin/bash
set -euo pipefail
REPO=${1:?usage: script OWNER/REPO [NUMBER]}
[[ $REPO =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || exit 2
NAME=${REPO#*/}
STATE="$HOME/.lokay/factory/${REPO//\//__}"
CLONE=${FACTORY_CLONE:-"$HOME/Developer/OSS/$NAME"}
mkdir -p "$STATE"
log() { printf '%s issue=%s pr=%s sha=%s %s\n' "$(date -u +%FT%TZ)" "$1" "$2" "$3" "$4" >> "$STATE/rounds.md"; }
number() { [[ $1 =~ ^[1-9][0-9]*$ ]] || exit 2; }
ensure_clone() {
    if [[ ! -e $CLONE ]]; then
        mkdir -p "$(dirname "$CLONE")"
        gh repo clone "$REPO" "$CLONE"
    fi
    git -C "$CLONE" rev-parse --git-dir >/dev/null
}
prs() { gh pr list -R "$REPO" --state open --limit 10000 --json number,headRefName,body; }
issues() { gh issue list -R "$REPO" --state open --limit 10000 --json number,createdAt,assignees; }
