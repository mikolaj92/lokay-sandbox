#!/bin/bash
set -euo pipefail
if [[ -e $HOME/.lokay/STOP ]]; then echo stopped; exit 0; fi
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/common.sh"
LOCK="$STATE.lock"
if ! mkdir "$LOCK" 2>/dev/null; then
    if [[ -n $(find "$LOCK" -maxdepth 0 -mmin +120 -print 2>/dev/null) ]] && mkdir "$LOCK.reap" 2>/dev/null; then
        pid=$(<"$LOCK/pid") || pid=0
        if [[ $pid =~ ^[1-9][0-9]*$ ]] && kill -0 "$pid" 2>/dev/null; then
            rmdir "$LOCK.reap"; exit 0
        fi
        rm -rf "$LOCK"
        mkdir "$LOCK" || { rmdir "$LOCK.reap"; exit 0; }
        rmdir "$LOCK.reap"
    else
        exit 0
    fi
fi
printf '%s\n' "$$" > "$LOCK/pid"
trap 'rm -rf "$LOCK"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
open=$(prs)
while read -r pr; do
    [[ -n $pr ]] || continue
    info=$(gh pr view "$pr" -R "$REPO" --json headRefOid,mergeable,body)
    sha=$(jq -r .headRefOid <<< "$info")
    issue=$(jq -r '.body | capture("Closes #(?<n>[0-9]+)([^0-9]|$)") .n' <<< "$info") || issue=-
    if [[ ! -e $STATE/review-$sha.done ]]; then
        if "$HERE/review.sh" "$REPO" "$pr" "$sha"; then
            touch "$STATE/review-$sha.done"
            log "$issue" "$pr" "$sha" reviewed
        else
            log "$issue" "$pr" "$sha" review-error
        fi
    fi
    case $(jq -r .mergeable <<< "$info") in
        MERGEABLE)
            if gh pr merge "$pr" -R "$REPO" --squash --delete-branch --match-head-commit "$sha"; then
                log "$issue" "$pr" "$sha" merged
            else
                log "$issue" "$pr" "$sha" merge-error
            fi ;;
        CONFLICTING) log "$issue" "$pr" "$sha" conflict ;;
    esac
done < <(jq -r '.[] | select(.headRefName | startswith("lokay/")) | .number' <<< "$open")
open=$(prs)
user=$(gh api user -q .login)
all=$(issues)
assigned=$(jq -r --arg u "$user" 'sort_by(.createdAt,.number)[] | select(any(.assignees[]; .login == $u)) | .number' <<< "$all")
if [[ -z $assigned ]] && ! jq -e 'any(.[]; .headRefName | startswith("lokay/"))' <<< "$open" >/dev/null; then
    issue=$(jq -r --argjson p "$open" 'sort_by(.createdAt,.number) | map(select(.number as $n | any($p[]; .body | test("Closes #" + ($n|tostring) + "([^0-9]|$)")) | not)) | .[0].number // empty' <<< "$all")
    if [[ -n $issue ]]; then
        gh issue edit "$issue" -R "$REPO" --add-assignee "$user"
        log "$issue" - - assigned
        assigned=$issue
    fi
fi
issue=${assigned%%$'\n'*}
if [[ -n $issue ]] && ! jq -e 'any(.[]; .headRefName | startswith("lokay/"))' <<< "$open" >/dev/null; then
    if "$HERE/build.sh" "$REPO" "$issue"; then
        log "$issue" - - built
    else
        log "$issue" - - build-error
        exit 1
    fi
fi
