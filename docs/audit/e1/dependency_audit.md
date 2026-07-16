# Auditoría de dependencias

Fecha: 2026-07-16. No se modificó `pubspec.yaml`, `pubspec.lock`, Gradle, CMake ni el override vendorizado.

## Resumen

- 140 paquetes en `dart pub deps`.
- 20 dependencias directas main, 6 directas dev y 112 transitivas en lock.
- Flutter 3.44.1 / Dart 3.12.1.
- `flutter pub outdated` detectó 6 directas main bloqueadas por lock y actualizables: Drift, drift_flutter, Riverpod, mobile_scanner, path_provider y uuid.
- El build Android advierte KGP legacy aplicado por `file_picker` y `mobile_scanner`.
- Windows usa `flutter_secure_storage_windows` desde `third_party/` mediante override, más `jni`/SQLite.

“Peso” es impacto observado o cualitativo en el build, no tamaño del source cache de Pub.

## Dependencias directas de runtime

| Dependencia (lock) | Uso real / archivos | Nativo y plataformas | Peso/mantenimiento/riesgo | Decisión futura |
|---|---|---|---|---|
| Flutter SDK 3.44.1 | UI, runner y build completo | Android/Windows engine | Base dominante e inevitable | mantener |
| `flutter_localizations` SDK | 2 ARB + API generada | no plugin adicional | Oficial; necesario ES/EN | mantener |
| `drift` 2.33.0 | 37 archivos; DB, repos y tests | SQLite vía transitivos | Central; schema/migraciones de alto riesgo; 2.34.2 resolvible | mantener; actualizar después de E2 |
| `drift_flutter` 0.3.0 | apertura DB en 1 archivo | selección de backend por plataforma | 0.3.1 resolvible | mantener; revisar update aislado |
| `flutter_riverpod` 3.3.1 | 53 archivos | Dart/Flutter | DI y estado; 3.3.2 resolvible; no causa peso nativo relevante | mantener |
| `go_router` 17.3.0 | 15 archivos | Dart/Flutter | Publicado por flutter.dev, feature-complete/estable | mantener |
| `intl` 0.20.2 | formatters + l10n generado | Dart | Restricción SDK mantiene 0.20.2; latest 0.20.3 | mantener |
| `path_provider` 2.1.5 | backup y media storage | plugins por plataforma | 2.1.6 resolvible; compartido, no Sync | mantener |
| `uuid` 4.5.3 | `IdGenerator` | Dart | 4.6.0 resolvible; bajo riesgo | mantener/actualizar luego |
| `file_picker` 11.0.2 | 5 archivos: CSV, backup, media y 2 Sync | Android plugin; Windows no figura como native build | Compartido; KGP warning Android | mantener; retirar sólo usos Sync; revisar versión |
| `csv` 8.0.0 | parser CSV + export | Dart | Pequeño; funcionalidad requerida | mantener |
| `data_table_2` 2.7.2 | tabla de biblioteca + test | Dart/Flutter | Aislado y funcional | mantener |
| `http` 1.6.0 | 18 archivos metadata/media/tests | Dart + sockets plataforma | Sólo capacidades online opcionales; app debe tolerar ausencia de red | mantener si se aprueban providers |
| `flutter_secure_storage` 10.3.1 | metadata credentials + identity/group Sync | Android y Windows nativo | Compartido; no borrar con Sync; fork Windows aumenta ownership | mantener sólo por credenciales externas |
| `crypto` 3.0.7 | SHA/canonical JSON en backup, media y Sync | Dart | Compartido y útil para integridad local | mantener |
| `archive` 4.0.9 | backup ZIP completo | Dart | Backup/media; no Sync | mantener si backup/restore continúa |
| `cryptography` 2.9.0 | backup cifrado + codecs Sync | Dart/posibles optimizaciones plataforma | Compartido; la parte backup sigue siendo valiosa | mantener si backup cifrado continúa |
| `shared_preferences` 2.5.5 | idioma + test | plugins plataforma | Bajo impacto; preferencia local | mantener |
| `qr_flutter` 4.1.0 | 1 archivo, render QR Sync | Dart/Flutter | Exclusivo de Sync/QR | eliminar con Sync en E2 |
| `mobile_scanner` 7.2.0 | 1 página scanner Sync | Android nativo (y otras plataformas en grafo) | Barhopper ~13,45 MiB + modelos ML; KGP warning; 7.3.0 resolvible | eliminar con Sync en E2 |

## Dependencias de desarrollo

| Dependencia | Uso | Decisión |
|---|---|---|
| `build_runner` 2.15.0 | genera Drift | mantener; no está importado porque es CLI |
| `drift_dev` 2.33.0 | generator y futura prueba de migraciones | mantener; alinear update con Drift |
| `flutter_lints` 6.0.0 | analyzer config | mantener |
| `flutter_test` SDK | widget/unit tests Flutter | mantener |
| `mocktail` 1.0.5 | 3 tests UI | mantener |
| `test` 1.31.0 | 45 archivos unit/data | mantener |

## Plugins nativos detectados

Android: `file_picker`, lifecycle, `flutter_secure_storage`, `jni`, `jni_flutter`, `mobile_scanner`, `path_provider_android` y `shared_preferences_android`. Windows: `flutter_secure_storage_windows` como plugin compilado y `jni` como FFI; path provider, shared preferences y file picker no generan DLL propia en este release.

El APK universal contiene, para `armeabi-v7a`, `arm64-v8a` y `x86_64`:

- Flutter engines: ~32,87 MiB sin comprimir;
- `libapp.so`: ~30,48 MiB;
- Barhopper de scanner: ~13,45 MiB;
- SQLite: ~4,87 MiB;
- dartjni y image/surface utilities: ~0,42 MiB;
- modelos ML de barcode: ~0,84 MiB.

Por esto `mobile_scanner` es la dependencia con mejor retorno de reducción. `qr_flutter` reduce código/maintenance, pero casi no aporta peso nativo.

## Android/Gradle

- `AndroidManifest.xml` declara `INTERNET` (metadata/media) y `CAMERA` (exclusivo scanner).
- E2 debe retirar `CAMERA`; `INTERNET` se mantiene sólo por providers opcionales.
- El warning Built-in Kotlin debe resolverse al eliminar scanner y revisar una versión compatible de file_picker; no actualizar dentro del mismo cambio destructivo de DB sin tests separados.
- No hay keystore trackeado.

## Windows y vendorizado

`dependency_overrides` fuerza `flutter_secure_storage_windows` 4.1.0 desde `third_party/`. Su FFI usa Credential Manager y produce una DLL de 150.528 bytes. No es significativo en peso, pero sí en mantenimiento: hay que documentar el motivo del fork, upstream divergence y criterio de retiro. Mientras metadata opcional conserve API keys/secret de IGDB, no puede eliminarse automáticamente.

## Dependencias que no deben caer por asociación con Sync

- `file_picker`: también CSV, backup y media.
- `flutter_secure_storage`: credenciales externas.
- `crypto`: hashes de media y backup.
- `cryptography`: backup cifrado.
- `archive`: backup ZIP.
- `http`: metadata y covers opcionales.
- `path_provider`: DB/files locales y media.

## Orden recomendado

1. E2: eliminar usos productivos de QR/scanner y luego `qr_flutter`/`mobile_scanner` + CAMERA.
2. E2: conservar las compartidas y limpiar sólo imports Sync.
3. E3/E4: resolver KGP de file_picker y actualizar Drift/Riverpod/path_provider/uuid en PRs pequeños.
4. E4: evaluar split por ABI/App Bundle y medir APK después de retirar scanner.
5. Sólo con decisión funcional: revisar si providers externos y secure storage continúan.

Fuentes de mantenimiento/arquitectura: [go_router en pub.dev](https://pub.dev/packages/go_router), [Drift migrations](https://drift.simonbinder.eu/migrations/), [Riverpod providers](https://riverpod.dev/docs/concepts2/providers).
