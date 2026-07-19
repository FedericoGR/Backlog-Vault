# Known toolchain warnings — v1.0.0-rc1

These messages were classified during the E6/E7 release gates. None changes
the application package identity, runtime behavior, schema, or exported data.

| Warning | Evidence | Classification and decision |
|---|---|---|
| Legacy Kotlin Gradle Plugin warning from `file_picker` 11.0.2 | Reproducible in Android release builds; 11.0.2 is the retained stable package used by CSV, JSON save, and local covers | Accepted dependency/toolchain warning. No prerelease dependency upgrade in E7. |
| Cupertino font not bundled | No `cupertino_icons` dependency or productive `CupertinoIcons` use; the APK contains the tree-shaken Material font | Accepted Flutter icon-tree-shaker false positive. Adding an unused font would increase the artifact. |
| `dartdoc` 9.0.4 process instability | Observed only in optional documentation generation, outside the canonical application gate | Accepted external tooling issue. `dartdoc` is not required to compile, test, package, or run the RC. |
| Transient Gradle lock contention | A retry after the external lock owner exits succeeds without source or cache mutation beyond normal build output | Operational warning only. Never bypass Gradle integrity or publish a failed build. |
| Newer incompatible package versions reported by pub | Resolution remains locked and all direct packages have productive consumers | Informational. Dependency upgrades are deliberately outside E7. |

An `Import-Clixml` message may also be emitted by the local PowerShell profile
before a command runs. It is external to the repository and is not included in
the public release notes.

No obfuscation or `--split-debug-info` is used for this RC.
