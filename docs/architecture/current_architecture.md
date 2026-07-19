# Arquitectura actual después de E3

Fecha: 2026-07-17. Este documento describe el árbol activo posterior al retiro
de Sync y del backup/restore complejo; la reconstrucción previa permanece en
`docs/audit/e1/` y en Git.

## Entrada, app y routing

`main.dart` crea el `ProviderContainer`, fuerza la apertura/migración de Drift,
ejecuta la limpieza selectiva e idempotente de claves seguras heredadas y monta
`BacklogVaultApp`. Un error de DB no se oculta; un error de secure storage se
reporta sin valores y no elimina credenciales externas.

```mermaid
flowchart LR
  Main["main.dart"] --> DBOpen["Abrir/migrar AppDatabase"]
  DBOpen --> Cleanup["Allowlist de claves heredadas"]
  Cleanup --> Scope["Riverpod ProviderContainer"]
  Scope --> App["BacklogVaultApp"]
  App --> Router["GoRouter / AppShell"]
  Router --> Screens["Home · Library · Games · Stats · Settings · CSV/JSON"]
```

No existe ruta, provider, listener, job ni inicializador de comunicación entre
dispositivos. Settings contiene exportación JSON, credenciales opcionales e
idioma; no contiene restore, cifrado ni passwords.

## Flujo UI → estado → DB

```mermaid
flowchart LR
  View["ConsumerWidget/Page"] --> Provider["Riverpod Provider/StreamProvider"]
  View --> RepoDirect["ref.read(repositoryProvider)"]
  Provider --> Repo["Repository"]
  RepoDirect --> Repo
  Repo --> Tx["AppDatabase.transaction"]
  Tx --> Drift[("Drift schema 6")]
  Drift --> Streams["watch() streams"]
  Streams --> Provider
```

Catalog, Game, Notion CSV import, Saved Views, Media, Metadata y Library Export
usan transacciones Drift locales. Se preservaron atomicidad, timestamps, soft
delete y comportamiento; no existe wrapper de tracking u oplog. El export toma
un snapshot de lectura consistente y delega el guardado al picker del sistema.

## Persistencia local

`AppDatabase` declara diez tablas funcionales en schema físico 6: games,
library entries, platforms, library-entry/platform links, genres, game/genre
links, playthroughs, saved views, external game IDs y media assets. La migración
5→6 elimina exclusivamente seis tablas y ocho índices históricos después de
validar el schema funcional y `PRAGMA foreign_key_check`.

El nuevo documento independiente se identifica como
`backlog-vault-library-export`, `formatVersion: 1`. No hereda el schema lógico 4
del backup retirado. Game, LibraryEntry y Playthrough continúan como conceptos
separados.

## Metadata y media

```mermaid
flowchart LR
  UI["Acción explícita del usuario"] --> Optional["RAWG · IGDB · SteamGridDB"]
  Optional --> HTTP["http.Client"]
  Optional --> Keys["OS secure storage"]
  Optional --> Repo["Metadata/Media repositories"]
  Repo --> DB[("Functional Drift tables")]
  Repo --> Files["MediaFileStorage"]
```

Estas son las únicas capacidades de red y nunca se ejecutan durante bootstrap
ni al usar la biblioteca. Media local, hashing y filesystem permanecen; no hay
packaging o transporte de media entre instalaciones.

## Importación y exportación

- Importación CSV conserva mapping, preview, duplicados y transacción local.
- Export JSON produce un snapshot UTF-8 determinista, sin modificar la DB.
- La serialización, lectura Drift, guardado y comando UI tienen límites
  separados bajo `import_export/library_export`.
- El JSON no incluye paths, bytes de imágenes, credenciales ni secure storage.
- No existe importación/restore JSON, ZIP, cifrado ni merge de paquetes.
- No se producen ni consumen `.vaultsync` o `.vaultpair`.

## Deuda deliberadamente no abordada

E3 no ejecutó el refactor general de ADR-001. Pages grandes todavía coordinan
workflows; algunas presentation importan data/filesystem; existen ciclos de
ownership games/library/metadata/media y modelos Drift alcanzan application.
E4 debe aplicar MVVM pragmático por vertical slice, sin combinarlo con una
migración destructiva o con cambios de contrato del export.
