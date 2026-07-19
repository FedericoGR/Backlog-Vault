# Git maintenance report

## Before consolidation

At the E6 baseline, `.git` occupied 1,878,238 bytes across 552 files.
`git count-objects -vH` reported:

- loose objects: 460 / 579.51 KiB;
- packed objects: 1,777 / 1.10 MiB;
- packs: 11;
- prune-packable: 0;
- garbage: 0.

The reachable history is source/text and small native icons. The verified full
bundle is 1,028,633 bytes. These figures continue to reject `filter-repo`, tag
rewrites, force pushes, aggressive pruning, and manual object deletion.

## Approved maintenance

After the E6 fast-forward, origin verification, and branch deletion, run only a
normal `git gc`. Do not use `--prune=now`, expire reflogs immediately, or run
aggressive GC. Git's standard retention preserves referenced objects and normal
recovery windows while consolidating packs.

The completion report records the exact post-GC `.git` bytes, object counts,
and packs. A normal GC is local maintenance and does not change commit or tag
hashes.
