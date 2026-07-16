# Baseline de tamaño

Medición ejecutada en `codex/offline-e1-audit` después de validar ambos builds y antes de limpiar cualquier output. No se ejecutó `flutter clean`, GC ni borrado.

## Resumen por naturaleza

| Naturaleza | Bytes | Lectura |
|---|---:|---|
| Código/config/documentos trackeados | 2.782.961 | Fuente real; 2,65 MiB. |
| Generado/ignorado local | 2.169.670.381 | Toolchains, intermediates, builds y dist; 2,02 GiB. |
| `.git` | 59.198.442 | 56,46 MiB; principalmente objetos sueltos locales. |
| Repositorio total | 2.231.651.784 | 2,08 GiB y 31.367 archivos. |

Conteos: 9.245 archivos fuera de `.git`, 22.122 dentro de `.git`, 327 trackeados, 8.923 ignorados y 0 untracked no ignorados antes de crear docs E1.

## Paths solicitados

| Path | Archivos | Bytes | Tamaño |
|---|---:|---:|---:|
| `lib/` | 173 | 2.031.485 | 1,94 MiB |
| `test/` | 88 | 524.243 | 511,96 KiB |
| `assets/` | — | — | no existe |
| `docs/` antes de E1 | 12 | 36.114 | 35,27 KiB |
| `android/` | 40 | 10.357.327 | 9,88 MiB |
| `windows/` | 65 | 273.512.614 | 260,84 MiB |
| `.dart_tool/` | 616 | 331.113.644 | 315,77 MiB |
| `build/` | 8.206 | 1.314.963.194 | 1,22 GiB |
| `dist/` | 19 | 239.793.166 | 228,68 MiB |
| `android/.gradle/` | 14 | 10.145.716 | 9,68 MiB |
| `third_party/` | 8 | 51.665 | 50,45 KiB |
| `tool/` | 1 | 2.742 | 2,68 KiB |

No hay `.gradle/` en la raíz. Los caches internos relevantes son `.dart_tool/flutter_build` (149,39 MiB), `.dart_tool/hooks_runner` (117,34 MiB) y `.dart_tool/pub/bin`/snapshots. `windows/flutter/ephemeral` ocupa 260,78 MiB, dominado por un PDB de 239,43 MiB.

## Outputs release

| Output | Bytes | Tamaño |
|---|---:|---:|
| `build/app/outputs/flutter-apk/app-release.apk` | 86.280.143 | 82,28 MiB |
| Windows `runner/Release` completo | 36.684.220 | 34,98 MiB |
| `backlog_vault.exe` | 81.920 | 80 KiB |
| Windows ZIP RC1 | 15.274.466 | 14,57 MiB |
| Android APK RC1 | 86.280.143 | 82,28 MiB |

Componentes Windows: `flutter_windows.dll` 21.284.352; `app.so` 10.765.200; `sqlite3.dll` 1.667.072; secure-storage DLL 150.528; `backlog_vault.exe` 81.920; `dartjni.dll` 72.192 bytes.

## Top 50 archivos del working tree

Los duplicados son copias/intermediates reales y explican por qué sumar outputs infla el directorio.

| # | Bytes | Path |
|---:|---:|---|
| 1 | 251.064.320 | `windows/flutter/ephemeral/flutter_windows.dll.pdb` |
| 2 | 164.273.912 | `build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib/x86_64/libflutter.so` |
| 3 | 163.761.776 | `build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib/arm64-v8a/libflutter.so` |
| 4 | 149.945.044 | `build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib/armeabi-v7a/libflutter.so` |
| 5 | 86.280.143 | `dist/BacklogVault-android-v0.3.0-rc1.apk` |
| 6 | 86.280.143 | `build/app/outputs/flutter-apk/app-release.apk` |
| 7 | 86.280.143 | `dist/BacklogVault-android-v0.3.0-qa1.apk` |
| 8 | 86.280.143 | `build/app/outputs/apk/release/app-release.apk` |
| 9 | 80.319.792 | `build/test_cache/build/0ea6338a9744699c4765127c07d5f7ae.cache.dill.track.dill` |
| 10 | 51.027.352 | `.dart_tool/flutter_build/3d4e25dd27ab000c9869dad02ea7ca72/app.dill` |
| 11 | 49.679.136 | `.dart_tool/flutter_build/da169fbc49c2b92d3407d7e50342f90d/app.dill` |
| 12 | 35.199.227 | `build/app/outputs/native-debug-symbols/release/native-debug-symbols.zip` |
| 13 | 27.848.704 | `build/app/outputs/mapping/release/mapping.txt` |
| 14 | 26.970.456 | `.dart_tool/pub/bin/build_runner/build_runner.dart-3.12.1.snapshot` |
| 15 | 21.284.352 | `dist/package_windows_work/Backlog Vault/flutter_windows.dll` |
| 16 | 21.284.352 | `windows/flutter/ephemeral/flutter_windows.dll` |
| 17 | 21.284.352 | `build/windows/x64/runner/Release/flutter_windows.dll` |
| 18 | 18.511.696 | `build/app/intermediates/native_symbol_tables/release/extractReleaseNativeSymbolTables/out/arm64-v8a/libflutter.so.sym` |
| 19 | 17.593.600 | `build/app/intermediates/native_symbol_tables/release/extractReleaseNativeSymbolTables/out/x86_64/libflutter.so.sym` |
| 20 | 16.568.608 | `.dart_tool/build/entrypoint/build.dart.aot` |
| 21 | 15.274.466 | `dist/BacklogVault-windows-x64-v0.3.0-rc1.zip` |
| 22 | 15.274.194 | `dist/BacklogVault-windows-x64-v0.3.0-qa1.zip` |
| 23 | 14.612.366 | `build/jni/intermediates/lint-cache/lintVitalAnalyzeRelease/private-apis-18-7541949.bin` |
| 24 | 14.601.368 | `build/app/intermediates/flutter/release/jniLibs/armeabi-v7a/libapp.so` |
| 25 | 14.601.368 | `build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib/armeabi-v7a/libapp.so` |
| 26 | 14.601.368 | `build/app/intermediates/merged_jni_libs/release/mergeReleaseJniLibFolders/out/armeabi-v7a/libapp.so` |
| 27 | 14.601.368 | `build/app/intermediates/flutter/release/armeabi-v7a/app.so` |
| 28 | 14.601.368 | `.dart_tool/flutter_build/3d4e25dd27ab000c9869dad02ea7ca72/armeabi-v7a/app.so` |
| 29 | 14.374.224 | `build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib/x86_64/libapp.so` |
| 30 | 14.374.224 | `build/app/intermediates/flutter/release/jniLibs/x86_64/libapp.so` |
| 31 | 14.374.224 | `build/app/intermediates/merged_jni_libs/release/mergeReleaseJniLibFolders/out/x86_64/libapp.so` |
| 32 | 14.374.224 | `build/app/intermediates/flutter/release/x86_64/app.so` |
| 33 | 14.374.224 | `.dart_tool/flutter_build/3d4e25dd27ab000c9869dad02ea7ca72/x86_64/app.so` |
| 34 | 14.108.632 | `build/app/intermediates/merged_jni_libs/release/mergeReleaseJniLibFolders/out/arm64-v8a/libapp.so` |
| 35 | 14.108.632 | `build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib/arm64-v8a/libapp.so` |
| 36 | 14.108.632 | `build/app/intermediates/flutter/release/jniLibs/arm64-v8a/libapp.so` |
| 37 | 14.108.632 | `build/app/intermediates/flutter/release/arm64-v8a/app.so` |
| 38 | 14.108.632 | `.dart_tool/flutter_build/3d4e25dd27ab000c9869dad02ea7ca72/arm64-v8a/app.so` |
| 39 | 13.628.772 | `build/app/intermediates/native_symbol_tables/release/extractReleaseNativeSymbolTables/out/armeabi-v7a/libflutter.so.sym` |
| 40 | 12.856.840 | `build/app/intermediates/stripped_native_libs/release/stripReleaseDebugSymbols/out/lib/x86_64/libflutter.so` |
| 41 | 11.995.192 | `build/app/intermediates/native_symbol_tables/release/extractReleaseNativeSymbolTables/out/armeabi-v7a/libapp.so.sym` |
| 42 | 11.796.104 | `.dart_tool/hooks_runner/sqlite3/8134992f33/hook.dill` |
| 43 | 11.796.104 | `.dart_tool/hooks_runner/sqlite3/b734070dda/hook.dill` |
| 44 | 11.796.104 | `.dart_tool/hooks_runner/sqlite3/60297a02a1/hook.dill` |
| 45 | 11.796.104 | `.dart_tool/hooks_runner/sqlite3/e6a3063631/hook.dill` |
| 46 | 11.796.104 | `.dart_tool/hooks_runner/sqlite3/b7a21b389e/hook.dill` |
| 47 | 11.579.920 | `build/app/intermediates/stripped_native_libs/release/stripReleaseDebugSymbols/out/lib/arm64-v8a/libflutter.so` |
| 48 | 11.356.368 | `build/app/intermediates/native_symbol_tables/release/extractReleaseNativeSymbolTables/out/x86_64/libapp.so.sym` |
| 49 | 11.094.368 | `build/app/intermediates/native_symbol_tables/release/extractReleaseNativeSymbolTables/out/arm64-v8a/libapp.so.sym` |
| 50 | 10.814.028 | `build/app/intermediates/stripped_native_libs/release/stripReleaseDebugSymbols/out/lib/armeabi-v7a/libapp.so` |

## Top 30 carpetas por suma recursiva

| # | Tamaño | Path |
|---:|---:|---|
| 1 | 1,22 GiB | `build/` |
| 2 | 1,05 GiB | `build/app/` |
| 3 | 849,62 MiB | `build/app/intermediates/` |
| 4–8 | 523,06 MiB | cadena `merged_native_libs/release/mergeReleaseNativeLibs/out/lib` |
| 9 | 315,77 MiB | `.dart_tool/` |
| 10 | 260,84 MiB | `windows/` |
| 11–12 | 260,78 MiB | `windows/flutter/ephemeral/` y padre |
| 13 | 229,40 MiB | `build/app/outputs/` |
| 14 | 228,68 MiB | `dist/` |
| 15 | 178,19 MiB | merged native x86_64 |
| 16 | 176,56 MiB | merged native arm64-v8a |
| 17 | 162,13 MiB | merged native armeabi-v7a |
| 18 | 149,39 MiB | `.dart_tool/flutter_build/` |
| 19 | 117,34 MiB | `.dart_tool/hooks_runner/` |
| 20–22 | 93,03 / 90,73 MiB | Flutter release intermediates y build hash activo |
| 23–26 | 85,96 MiB | native symbol tables y sus padres |
| 27–30 | 85,16 MiB | stripped native libs y sus padres |

## Causas y decisiones

1. Intermediates Android multi-ABI y copias de `.so` dominan el working tree; son regenerables.
2. El PDB efímero Windows domina `windows/`; no es producto distribuido.
3. `dist/` conserva RC/QA y staging duplicado; debe retenerse fuera de Git con política de artefactos.
4. El paquete Android universal contiene tres ABI. Publicar split APK/App Bundle puede reducir la descarga por dispositivo.
5. `mobile_scanner` agrega aproximadamente 13,45 MiB de Barhopper más modelos ML sin comprimir; retirarlo en E2 sí reducirá APK.
6. Reorganizar Dart o adoptar MVVM no reduce significativamente el ejecutable. El ahorro real vendrá de plugins nativos, Sync/QR/cámara, assets, ABI/packaging y outputs locales.

Véase el [plan de reducción](../../planning/repository_weight_reduction_plan.md).
