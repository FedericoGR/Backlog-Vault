# E7 final risk register

| Risk | Likelihood | Impact | Mitigation/evidence | RC status |
|---|---|---|---|---|
| In-place Android signature/version mismatch | low | critical | inspect package/signing certificate; install exact arm64 APK once with `adb install -r`; preserve install time | physical QA gate |
| Schema 5→6 data loss | low | critical | guarded transactional migration, synthetic schema-5 fixture, counts/IDs/FKs, schema-6 reopen, prior physical smoke | covered; recheck startup logs |
| Windows smoke touches a real library | medium | high | hash AppData before/after, use read-only navigation, cover mutations with tests | manual limitation if no disposable profile |
| JSON mistaken for complete recovery | medium | high | docs and UI call it export; no restore; explicit media/path/credential exclusions | accepted product limitation |
| Local DB/media loss or disclosure | medium | high | device-level protection and independent recovery guidance; no at-rest encryption claim | accepted product limitation |
| Provider outage or invalid credential | medium | low | providers optional and user-triggered; controlled localized errors | accepted |
| `file_picker` legacy KGP warning | high | low | pinned stable dependency, green Android build and physical picker QA | accepted toolchain warning |
| APK ABI incompatibility | low | medium | publish tested arm64 plus universal fallback with explicit labels | mitigated |
| Artifact/source mismatch | low | high | package from release branch, record hashes/sizes, keep only final candidates, tag final release commit | publication gate |
| Secret or personal data enters Git/assets | low | critical | synthetic external dataset, hygiene and history scans, no full logcat/DB/export committed | publication gate |
| Removed transport surface reappears | low | high | architecture absence test plus source, manifest, dependency, and log scans | covered |
| Upstream/toolchain warning blocks future build | medium | medium | pin current lock/toolchain and document warnings; defer upgrades | accepted for RC |
| Android RC uses the existing debug signing identity | certain | high | required to update the installed baseline in place; disclose as an RC-only personal-distribution constraint; choose a protected production-signing and migration policy before stable | new stable-promotion decision |
| APK bytes are not reproducible across rebuilds | high | medium | preserve and checksum the exact physically tested candidates; validate package/version/ABI/signature; do not replace them with later validation rebuilds | accepted for RC |

No open risk authorizes uninstalling, clearing data, extracting private app
storage, using real credentials, or adding release-scope functionality.

The Android signing identity is compatible with the installed baseline and
therefore suitable for this controlled RC smoke. It is not an acceptable
long-term public production key. Publishing the APKs broadly or promoting to
stable requires an explicit signing decision; changing keys also requires a
user-data transition plan because Android will reject an in-place update.
