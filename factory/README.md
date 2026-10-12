# Minimal lokay factory
Run `factory/tick.sh OWNER/REPO` for one tick; launchd uses StartCalendarInterval, minutes 0,5,...,55.
Requires Bash, gh, git, jq, pi-classic, and Perl for bounded AI calls.
Authenticate gh and configure pi-classic before starting.
The clone defaults to `$HOME/Developer/OSS/<repo>`; override with `FACTORY_CLONE`.
Each repo uses `$HOME/.lokay/factory/<owner__repo>/` for state.
A mkdir lock prevents overlap; dead locks become reclaimable after two hours.
Review runs once per head SHA before merging and posts findings plus a status.
Review is informational: mergeable lokay branches merge regardless of verdict.
Conflicts are logged without closing or rebuilding the PR.
Feed assigns the oldest eligible issue, then builds one assigned issue.
Build uses an isolated worktree, commits changes, pushes, and opens a PR.
`rounds.md` records UTC events; `review-<sha>.done` records completed reviews.
Create `$HOME/.lokay/STOP` to stop ticks; remove it to resume.
Before loading the supplied launchd agent, create `$HOME/.lokay/logs`; AI prompts are not a sandbox.
