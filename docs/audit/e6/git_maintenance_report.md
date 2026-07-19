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

## Maintenance performed

After the E6 fast-forward, origin verification, and branch deletion, E6 ran
only `git gc` with no flags. It did not use `--prune=now`, expire reflogs,
request aggressive GC, or delete objects manually.

Immediately before GC, `.git` occupied 1,923,186 bytes across 570 files, with
517 loose objects (636.00 KiB), 1,777 packed objects (1.10 MiB), 11 packs, and
zero garbage. Immediately after GC it occupied 1,260,559 bytes across 41 files:

- loose objects: 11 / 10.34 KiB;
- packed objects: 2,279 / 1.08 MiB;
- packs: 1;
- prune-packable: 0;
- garbage: 0.

Compared with the original E6 baseline, `.git` is 617,679 bytes (32.89%)
smaller. Normal GC changed no commit or tag hash.
