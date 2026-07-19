# Branch consolidation plan after E6

E5 is canonical on `main` at `323e533`. E6 starts there on
`codex/offline-e6-size-cleanup`. All historical branch tips are ancestors of
main and have zero commits in `main..branch`.

## Recovery boundary

Before any deletion, E6 created and verified a full 38-ref bundle outside the
repository. It includes main, E1-E5, all Sync/QR/LAN refs, release branches,
and six historical tags. The E1 bundle remains untouched.

## Final sequence

1. Complete and push E6.
2. Fast-forward E6 to main; run checker, analyze, tests, Windows/APK builds,
   and Windows packaging.
3. Push main and verify `origin/main` is identical.
4. Recheck ancestry/unique-commit counts.
5. Delete only contained local branches with `git branch -d`.
6. Delete only contained remote branches with `git push origin --delete`.
7. Preserve main and every historical tag; do not create `release/v1` yet.
8. Run normal `git gc`, measure, and clean generated workspace output.

No force push, rebase, filter-repo, immediate reflog expiration, aggressive
pruning, tag move, tag deletion, or manual object deletion is allowed.
