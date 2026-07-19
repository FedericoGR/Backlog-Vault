# Branch consolidation report

E5 was fast-forwarded to `main` at `323e533` and pushed before E6 began. A full
`git bundle create --all` backup was then created outside the repository and
verified as a complete history.

## Recovery bundle

- directory: `Backlog Vault Backups/pre-e6-branch-consolidation/20260719-154735/`;
- bundle: `backlog-vault-pre-e6-consolidation-20260719-154735.bundle`;
- size: 1,028,633 bytes;
- SHA-256: `2D84A094720ED4431C86ABE11A6DC39B27913DB6C396BF4B8833818C2A310DBF`;
- result: 38 refs, complete history, verified OK;
- companion evidence: local/remote branch lists, tags, graph, main commit,
  bundle heads, checksums, and restore instructions.

It contains E1-E5, historical Sync/pairing/QR/LAN refs, `release/v0.2`,
`release/v0.3`, the old `release/v1`, `main`, and all six historical tags. The
older E1 bundle was neither read nor replaced.

## Containment evidence

For every local and origin remote-tracking branch, E6 ran an ancestry check and
`git rev-list --count main..branch`. All reported `ContainedInMain=True` and
zero unique commits. `git branch --no-merged main` and the corresponding remote
query were empty before E6 diverged from main.

After E6 was pushed, fast-forwarded to `main` at `525d7b9`, validated, and
aligned with `origin/main`, a second check again returned contained/zero for
all candidates. E6 then deleted these groups with `git branch -d` and
`git push origin --delete`:

- local/remote Offline E1-E5 and the E6 branch itself after merge;
- Sync foundation, device pairing, encrypted package, Sync UX;
- QR pairing/QA and LAN now/hardening/media;
- historical branch names `release/v0.2`, `release/v0.3`, and old `release/v1`.

Result: 12 local branches and 18 remote branches deleted, with no rejection or
unexpected retention. The final branch sets are exactly local `main` and
remote-tracking `origin/main`. Remote `ls-remote --heads` also reports only
`main`.

The commits/releases remain reachable from `main`, the six preserved tags, and
the verified bundle. No tag was deleted or moved. No `release/v1` replacement
was created, no history was rewritten, and no force push was used.
