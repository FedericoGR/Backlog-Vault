# E6 size and cleanup results

Measured on 2026-07-19. Artifact comparisons use ordinary release builds from
the same `0.3.0+5` source and toolchain. Workspace figures compare the initial
E6 directory, which still contained old ignored outputs, with the source-only
state after the final E6 cleanup. Final Git figures are refreshed after branch
consolidation and normal `git gc`.

| Metric | Before E6 | After E6 | Difference | Percentage |
|---|---:|---:|---:|---:|
| Clean repository directory | 2,499,850,391 B | 4,521,600 B pre-final-docs | -2,495,328,791 B | -99.82% |
| Working tree without `.git` | 2,497,972,153 B | 2,616,158 B pre-final-docs | -2,495,355,995 B | -99.90% |
| `.git` | 1,878,238 B | 1,905,442 B pre-GC | +27,204 B | +1.45% |
| Tracked files | 384 | 403 projected after E6 docs | +19 | +4.95% |
| Direct dependencies | 22 | 22 | 0 | 0.00% |
| Android plugin records | 7 | 7 | 0 | 0.00% |
| Windows plugin records | 5 | 5 | 0 | 0.00% |
| Source platform assets | 6 | 6 | 0 | 0.00% |
| Windows Release bundle | 35,667,270 B / 15 files | 35,667,064 B / 14 files | -206 B / -1 | -0.0006% |
| Windows ZIP | 15,186,459 B | 15,186,576 B | +117 B | +0.0008% |
| Android universal APK | 67,324,009 B | 67,324,009 B | 0 | 0.00% |
| Android arm64-v8a APK | 23,697,690 B | 23,697,690 B | 0 | 0.00% |
| Android armeabi-v7a APK | 21,382,540 B | 21,382,540 B | 0 | 0.00% |
| Android x86_64 APK | 25,134,447 B | 25,134,447 B | 0 | 0.00% |

The final two source-only workspace values and Git values are recorded after
the merge because committing this report and running normal GC necessarily
changes them. The pre-final-docs figures already prove that ignored build and
packaging output, not tracked source, caused the multi-gigabyte workspace.

## What changed

The 2.49 GB reduction comes from removing only reproducible local output:
`build/`, `dist/`, `.dart_tool/`, `android/.gradle/`, `android/build/`, Windows
ephemeral output, and generated Flutter plugin metadata. All are excluded by
anchored ignore rules and can be recreated by the documented release command.
No AppData, database, cover, export, credential, backup, SDK cache, tag, or
source file was removed.

The Windows package no longer copies a build tree opportunistically. It stages
an explicit runtime allowlist, rejects development artifacts, validates the
result, writes entries in a stable order with a fixed timestamp, and emits a
SHA-256 companion. Two consecutive final packages were byte-identical at
15,186,576 bytes with SHA-256
`AB19AD4EFF549E14D151E0DCEA3767C25F643FEAF7BC644578A658A00C067D77`.
The 117-byte increase over the old non-deterministic ZIP is immaterial and is
accepted in exchange for completeness checks and reproducibility.

## What did not change

All direct dependencies, native plugins, launcher resources, the Windows icon,
fixtures, and release runtime files have productive evidence. Removing one
would either break a preserved feature, make a platform package incomplete, or
save negligible bytes at disproportionate risk. Flutter engine libraries,
Dart AOT code, SQLite, ICU, shaders, manifests, notices, Material Icons, JNI,
and secure storage are legitimate runtime rather than repository waste.

The ordinary APK binaries are unchanged because E6 makes no functional or
dependency change. The practical reduction is distribution-specific: the
arm64 APK is 43,626,319 bytes (64.80%) smaller than the universal APK because
it does not carry native libraries for two other ABIs. An experimental arm64
`--split-debug-info` build saved a further 1,087,712 bytes (4.59%), while
obfuscation added only 131,072 bytes (0.58%) of incremental saving and more
support risk. Neither experiment was adopted into E6 release defaults.

## E7 recommendation

Use arm64-v8a for the known modern Android QA device and retain a universal APK
as a compatibility fallback. Keep all three ABI splits as a build gate. Adopt
`--split-debug-info` only together with an approved external symbol-retention
procedure; do not adopt obfuscation solely as a size or security claim.
