# Plan de reducción de peso

## Diagnóstico

El source trackeado es 2,65 MiB. El directorio de 2,08 GiB proviene de outputs regenerables; `.git` local de 56,46 MiB proviene sobre todo de objetos sueltos no alcanzables al ignorar reflogs. La historia publicada no necesita reescritura.

## Acciones por retorno/riesgo

| Acción futura | Ahorro esperado | Riesgo | Entregable |
|---|---|---|---|
| `flutter clean`/borrar outputs regenerables con verificación | hasta ~1,8 GiB local según qué se preserve | bajo si dist respaldado | E4 |
| política `dist/`: RC externos, staging temporal | ~228 MiB local | medio por artefactos | E4 |
| retirar mobile_scanner/Barhopper/modelos | ~14+ MiB sin comprimir del APK universal, más Dart/dex | medio | E2 |
| retirar qr_flutter/Sync code | pequeño binario; gran maintenance/LOC | bajo/medio | E2 |
| split APK por ABI o App Bundle | descarga por dispositivo potencialmente ~mitad o menos | medio; cambia distribución | E4/E5 |
| optimizar assets | bajo hoy; sólo iconos trackeados | bajo | E4 |
| GC local normal | hasta ~55 MiB `.git` local | medio; esperar backup/aprobación | E4 |
| `filter-repo` | beneficio mínimo demostrado | crítico | no recomendado |

Las cifras de scanner son observadas en APK: Barhopper suma ~13,45 MiB y modelos ~0,84 MiB. El ahorro final debe medirse; el compiler/tree shaking y ZIP pueden alterar el resultado.

## Política de working tree

- mantener `build/`, `.dart_tool/`, ephemeral, Gradle y dist fuera de Git;
- antes de limpiar dist, comparar SHA y confirmar copia externa;
- conservar sólo artefactos de release firmados/verificados fuera del repo;
- automatizar packaging reproducible en vez de conservar staging;
- medir siempre antes/después con los mismos comandos y build mode.

## Builds

Android:

1. E2 retirar scanner/CAMERA.
2. Medir APK universal.
3. Evaluar `--split-per-abi`/App Bundle según canal.
4. Revisar símbolos/mapping como artefactos separados, no paquete de usuario.

Windows:

1. Distribuir sólo Release completo/ZIP, no PDB ephemeral.
2. Mantener Flutter DLL, app.so, SQLite, secure storage si providers siguen.
3. Comparar ZIP/extracted y documentar data directory independiente.

## Git

- no GC en E1;
- confirmar bundle + remote + reflog retention antes de GC;
- ejecutar `git count-objects` pre/post cuando se apruebe;
- no expirar reflogs o podar agresivamente sin ventana de recuperación;
- no reescribir porque top reachable es código generado/texto e iconos esperados.

## Criterio de éxito

Repo de trabajo limpio sin outputs innecesarios, release artifacts externos reproducibles, APK significativamente menor tras scanner/ABI, Windows ZIP sin debug symbols, y `.git` razonable sin cambiar hashes públicos.
