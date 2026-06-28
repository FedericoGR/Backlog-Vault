// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Backlog Vault';

  @override
  String get navigationHome => 'Inicio';

  @override
  String get navigationLibrary => 'Biblioteca';

  @override
  String get navigationStatistics => 'Estadísticas';

  @override
  String get navigationSettings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get languageDescription =>
      'Elegí el idioma usado en este dispositivo.';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Borrar';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get continueAction => 'Continuar';

  @override
  String get back => 'Volver';

  @override
  String get retry => 'Reintentar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get edit => 'Editar';

  @override
  String get create => 'Crear';

  @override
  String get replace => 'Reemplazar';

  @override
  String get search => 'Buscar';

  @override
  String get clear => 'Limpiar';

  @override
  String get select => 'Seleccionar';

  @override
  String get selected => 'Seleccionado';

  @override
  String get none => 'Ninguno';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get ready => 'Listo';

  @override
  String get loading => 'Cargando…';

  @override
  String get notAvailable => 'No disponible';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLocalStatusTitle => 'Estado local';

  @override
  String get settingsLocalStatusSubtitle =>
      'Backlog Vault sigue siendo una app offline-first: la biblioteca vive en tu equipo y las integraciones externas son opcionales.';

  @override
  String get settingsAccountRequired => 'Cuenta obligatoria';

  @override
  String get settingsUsageMode => 'Modo de uso';

  @override
  String get settingsLocalDatabase => 'Base local';

  @override
  String get settingsLoadingStatus => 'Estado de carga';

  @override
  String get settingsLoadingConfiguration => 'Cargando configuración…';

  @override
  String get settingsPrivacyProtection => 'Privacidad y protección';

  @override
  String get settingsPrivacyProtectionMessage =>
      'La DB local y los archivos media siguen sin cifrado en disco. Los backups cifrados ya están disponibles para exportación y restauración.';

  @override
  String get settingsDataBackups => 'Datos y backups';

  @override
  String get settingsDataBackupsSubtitle =>
      'Exportá JSON/CSV, generá backups normales o cifrados y restaurá archivos locales.';

  @override
  String get settingsOpenBackups => 'Abrir backups';

  @override
  String get settingsGoodPractices => 'Buenas prácticas';

  @override
  String get settingsGoodPracticesSubtitle =>
      'No pegues claves reales en README, issues, logs, tests ni commits. Todo queda guardado localmente en secure storage.';

  @override
  String get settingsRawgSubtitle =>
      'Fuente opcional para completar metadata de juegos. La clave se guarda localmente en el secure storage del sistema.';

  @override
  String get settingsIgdbSubtitle =>
      'Client credentials para consultar IGDB. El access token se renueva localmente y el secret no se expone en pantalla.';

  @override
  String get settingsSteamGridDbSubtitle =>
      'Clave opcional para buscar portadas. Backlog Vault sigue pidiendo confirmación explícita antes de guardar covers.';

  @override
  String get settingsNewApiKey => 'Nueva API key';

  @override
  String get settingsApiKeyHelper =>
      'No se exporta en backups, no se muestra en claro y no debe terminar en commits.';

  @override
  String get settingsClientIdHelper =>
      'Se guarda solo en el equipo actual y no viaja en backups.';

  @override
  String get settingsClientSecretHelper =>
      'No lo pegues en logs, README, tests ni issues.';

  @override
  String get settingsMediaApiKeyHelper =>
      'Se usa solo para búsqueda de media y se mantiene local.';

  @override
  String get settingsExternalKeysDeletion => 'Borrado de claves externas';

  @override
  String get settingsExternalKeysDeletionMessage =>
      'Solo elimina credenciales guardadas localmente. No toca juegos, metadata ya aplicada, external IDs ni portadas almacenadas.';

  @override
  String get settingsDeleteAllKeys => 'Borrar todas las claves';

  @override
  String get settingsEnterApiKey => 'Ingresá una API key antes de guardar.';

  @override
  String get settingsRawgSaved => 'API key de RAWG guardada localmente.';

  @override
  String get settingsRawgDeleted => 'API key de RAWG borrada.';

  @override
  String get settingsEnterIgdbCredentials =>
      'Ingresá Client ID y Client Secret antes de guardar.';

  @override
  String get settingsIgdbSaved => 'Credenciales de IGDB guardadas localmente.';

  @override
  String get settingsIgdbDeleted => 'Credenciales de IGDB borradas.';

  @override
  String get settingsSteamGridDbSaved =>
      'API key de SteamGridDB guardada localmente.';

  @override
  String get settingsSteamGridDbDeleted => 'API key de SteamGridDB borrada.';

  @override
  String get settingsDeleteExternalKeysTitle => 'Borrar claves externas';

  @override
  String get settingsDeleteExternalKeysConfirmation =>
      'Se borrarán las claves de RAWG, IGDB y SteamGridDB guardadas localmente. No se modifican tus juegos, metadata aplicada, external IDs ni portadas.';

  @override
  String get settingsDeleteKeys => 'Borrar claves';

  @override
  String get settingsExternalKeysDeleted => 'Claves externas borradas.';

  @override
  String get settingsConfigured => 'Configurado';

  @override
  String get settingsNotConfigured => 'No configurado';

  @override
  String get settingsConfigurationPresent => 'Configuración presente';

  @override
  String get settingsConfigurationPending => 'Configuración pendiente';

  @override
  String get settingsPending => 'Pendiente';

  @override
  String get statusWishlist => 'Lista de deseos';

  @override
  String get statusBacklog => 'Pendiente';

  @override
  String get statusPlaying => 'Jugando';

  @override
  String get statusPaused => 'Pausado';

  @override
  String get statusCompleted => 'Completado';

  @override
  String get statusDropped => 'Abandonado';

  @override
  String get statusRetired => 'Retirado';

  @override
  String get playthroughPlanned => 'Planeada';

  @override
  String get playthroughActive => 'Activa';

  @override
  String get playthroughPaused => 'Pausada';

  @override
  String get playthroughCompleted => 'Completada';

  @override
  String get playthroughDropped => 'Abandonada';

  @override
  String get gameTypeUndefined => 'Sin definir';

  @override
  String get gameTypeSinglePlayer => 'Un jugador';

  @override
  String get gameTypeMultiplayer => 'Multijugador';

  @override
  String get gameTypeCooperative => 'Cooperativo';

  @override
  String get games => 'Juegos';

  @override
  String get backlog => 'Backlog';

  @override
  String get playing => 'Jugando';

  @override
  String get completed => 'Completados';

  @override
  String get missingCover => 'Sin portada';

  @override
  String get missingMetadata => 'Sin metadata';

  @override
  String get missingRating => 'Sin puntaje';

  @override
  String get missingPlatform => 'Sin plataforma';

  @override
  String get missingGenre => 'Sin género';

  @override
  String get homeNowPlaying => 'Jugando ahora';

  @override
  String get homeNowPlayingDescription =>
      'Lo más activo de tu biblioteca personal.';

  @override
  String get homeNowPlayingEmpty => 'No hay juegos en progreso.';

  @override
  String get homeBacklogDescription => 'Pendientes listos para volver a mirar.';

  @override
  String get homeBacklogEmpty => 'No hay pendientes en backlog.';

  @override
  String get homeRecentCompleted => 'Completados recientes';

  @override
  String get homeRecentCompletedDescription =>
      'Los últimos cierres con fecha registrada.';

  @override
  String get homeRecentCompletedEmpty =>
      'No hay completados con fecha registrada.';

  @override
  String get homeMissingCoverDescription =>
      'Entradas que todavía piden una selección visual.';

  @override
  String get homeMissingCoverEmpty =>
      'Todos los juegos visibles tienen portada.';

  @override
  String get homeMissingMetadataDescription =>
      'Juegos que conviene enriquecer antes de ordenar.';

  @override
  String get homeMissingMetadataEmpty =>
      'Todos los juegos visibles tienen metadata externa.';

  @override
  String get homeRecentlyUpdated => 'Últimos actualizados';

  @override
  String get homeRecentlyUpdatedDescription =>
      'Movimiento reciente en estados, notas y partidas.';

  @override
  String get homeRecentlyUpdatedEmpty => 'No hay actividad reciente.';

  @override
  String get homeLoading => 'Cargando inicio';

  @override
  String get homeLoadError => 'No se pudo cargar el inicio';

  @override
  String homeLibrarySummary(
    Object completedCount,
    Object playingCount,
    Object total,
  ) {
    return '$total juegos activos, $completedCount completados y $playingCount en progreso.';
  }

  @override
  String get homeOpenLibrary => 'Abrir biblioteca';

  @override
  String get homeQuickPanel => 'Panel rápido';

  @override
  String get homeQuickPanelDescription =>
      'Saltá a estadísticas o revisá lo que sigue sin portada o metadata.';

  @override
  String get homeViewStatistics => 'Ver estadísticas';

  @override
  String get homeCreateGame => 'Crear juego';

  @override
  String get homeViewLibrary => 'Ver biblioteca';

  @override
  String get homeEmptyTitle => 'Tu biblioteca todavía está vacía.';

  @override
  String get homeEmptyMessage =>
      'Cuando cargues tus primeros juegos, este panel te va a mostrar actividad, pendientes y calidad de datos.';

  @override
  String get homeCreateFirstGame => 'Crear primer juego';

  @override
  String get statisticsLibraryLoading => 'Cargando biblioteca';

  @override
  String get statisticsProgressLoading => 'Cargando progreso';

  @override
  String get statisticsLoadProgressError => 'No se pudo cargar progreso';

  @override
  String get statisticsLoadError => 'No se pudo cargar estadísticas';

  @override
  String get statisticsLibraryByStatus => 'Biblioteca por estado';

  @override
  String get statisticsLibraryByStatusSubtitle =>
      'Distribución rápida del backlog actual.';

  @override
  String get statisticsRatings => 'Ratings';

  @override
  String get statisticsRatingsSubtitle =>
      'Cómo se reparte tu valoración personal entre los juegos puntuados.';

  @override
  String get statisticsDataQuality => 'Calidad de datos';

  @override
  String get statisticsDataQualitySubtitle =>
      'Huecos de metadata que todavía conviene revisar.';

  @override
  String get statisticsAnnualProgress => 'Progreso anual';

  @override
  String get statisticsAnnualProgressSubtitle =>
      'Playthroughs completados con fecha, más horas registradas por período.';

  @override
  String get statisticsTopPlatforms => 'Plataformas más usadas';

  @override
  String get statisticsTopPlatformsSubtitle =>
      'Dónde se concentra más actividad jugable.';

  @override
  String get statisticsNoPlatforms => 'No hay plataformas registradas.';

  @override
  String get statisticsTopGenres => 'Géneros más usados';

  @override
  String get statisticsTopGenresSubtitle =>
      'Qué estilos dominan tu biblioteca personal.';

  @override
  String get statisticsNoGenres => 'No hay géneros registrados.';

  @override
  String get statisticsRecentCompleted => 'Últimos completados';

  @override
  String get statisticsRecentCompletedSubtitle =>
      'Tus cierres más recientes con fecha registrada.';

  @override
  String get statisticsPulse => 'Pulso de tu biblioteca';

  @override
  String get statisticsPulseSubtitle =>
      'Un vistazo rápido a backlog, progreso y calidad de datos sin salir del mismo catálogo.';

  @override
  String statisticsCompletedHours(Object completedCount, Object hours) {
    return '$completedCount completados · $hours horas';
  }

  @override
  String get statisticsTotalCompleted => 'Completados totales';

  @override
  String get statisticsLoggedHours => 'Horas registradas';

  @override
  String get statisticsAverageRating => 'Rating promedio';

  @override
  String get statisticsYear => 'Año';

  @override
  String get statisticsNoAnnualProgress => 'Todavía no hay progreso anual';

  @override
  String get statisticsNoAnnualProgressMessage =>
      'Cuando completes partidas con fecha, este panel las resume por año y mes.';

  @override
  String statisticsMonthsOf(Object year) {
    return 'Meses de $year';
  }

  @override
  String get statisticsNoRatings => 'Todavía no hay puntajes';

  @override
  String get statisticsNoRatingsMessage =>
      'Cuando empieces a calificar juegos, esta sección va a mostrar cómo se reparte tu criterio.';

  @override
  String statisticsStars(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrellas',
      one: '1 estrella',
    );
    return '$_temp0';
  }

  @override
  String statisticsUnrated(Object count) {
    return 'Sin puntaje: $count';
  }

  @override
  String get statisticsNoData => 'Sin datos todavía';

  @override
  String get statisticsCompletedWithoutDate => 'Completados sin fecha';

  @override
  String get statisticsNoCompleted => 'Todavía no hay completados';

  @override
  String get statisticsNoCompletedMessage =>
      'Registrá una fecha de cierre en tus partidas para verlas acá.';

  @override
  String get statisticsEmptyTitle =>
      'Todavía no hay datos para calcular estadísticas.';

  @override
  String get statisticsEmptyMessage =>
      'Cuando cargues juegos y partidas, este panel te va a resumir progreso, ratings y calidad de metadata.';

  @override
  String get statisticsGoToLibrary => 'Ir a biblioteca';

  @override
  String hoursShort(Object value) {
    return '$value h';
  }

  @override
  String get monthJanuary => 'Enero';

  @override
  String get monthFebruary => 'Febrero';

  @override
  String get monthMarch => 'Marzo';

  @override
  String get monthApril => 'Abril';

  @override
  String get monthMay => 'Mayo';

  @override
  String get monthJune => 'Junio';

  @override
  String get monthJuly => 'Julio';

  @override
  String get monthAugust => 'Agosto';

  @override
  String get monthSeptember => 'Septiembre';

  @override
  String get monthOctober => 'Octubre';

  @override
  String get monthNovember => 'Noviembre';

  @override
  String get monthDecember => 'Diciembre';

  @override
  String get apply => 'Aplicar';

  @override
  String get name => 'Nombre';

  @override
  String get view => 'Vista';

  @override
  String get filters => 'Filtros';

  @override
  String get table => 'Tabla';

  @override
  String get gallery => 'Galería';

  @override
  String get list => 'Lista';

  @override
  String get columns => 'Columnas';

  @override
  String get saveView => 'Guardar vista';

  @override
  String get importCsv => 'Importar CSV';

  @override
  String get importMetadata => 'Importar metadata';

  @override
  String get libraryExitSelection => 'Salir de selección';

  @override
  String get librarySelectMultiple => 'Seleccionar varios';

  @override
  String get libraryLoading => 'Cargando biblioteca';

  @override
  String get libraryLoadError => 'No se pudo cargar la biblioteca';

  @override
  String get libraryDeleteSelectedTitle => 'Eliminar juegos seleccionados';

  @override
  String libraryDeleteSelectedMessage(Object count) {
    return 'Se marcarán como eliminados $count juegos. No se borrarán físicamente.';
  }

  @override
  String get libraryTypeDeleteConfirmation =>
      'Escribí ELIMINAR para confirmar.';

  @override
  String get libraryDeleteKeyword => 'ELIMINAR';

  @override
  String get libraryConfirmation => 'Confirmación';

  @override
  String get libraryDeleteSelected => 'Eliminar seleccionados';

  @override
  String libraryFiltersCount(Object count) {
    return 'Filtros ($count)';
  }

  @override
  String get libraryActions => 'Acciones de biblioteca';

  @override
  String get libraryUpdateView => 'Actualizar vista';

  @override
  String get libraryRenameView => 'Renombrar vista';

  @override
  String get libraryDeleteView => 'Eliminar vista';

  @override
  String get libraryYear => 'Año';

  @override
  String libraryFilterStatus(Object value) {
    return 'Estado: $value';
  }

  @override
  String libraryFilterPlatform(Object value) {
    return 'Plataforma: $value';
  }

  @override
  String libraryFilterGenre(Object value) {
    return 'Género: $value';
  }

  @override
  String libraryFilterSearch(Object value) {
    return 'Búsqueda: $value';
  }

  @override
  String get libraryMissingCompletedDate => 'Sin fecha completado';

  @override
  String get libraryOpenDetails => 'Abrir detalle';

  @override
  String get libraryActionsTooltip => 'Acciones';

  @override
  String get libraryAdvancedFilters => 'Filtros avanzados';

  @override
  String get libraryClearFilters => 'Limpiar filtros';

  @override
  String get libraryStatus => 'Estado';

  @override
  String get libraryPlatforms => 'Plataformas';

  @override
  String get libraryGenres => 'Géneros';

  @override
  String get libraryMinimumRating => 'Puntaje mínimo';

  @override
  String get libraryMaximumRating => 'Puntaje máximo';

  @override
  String get libraryMinimumHours => 'Horas mínimas';

  @override
  String get libraryMaximumHours => 'Horas máximas';

  @override
  String get libraryType => 'Tipo';

  @override
  String get libraryReleaseFrom => 'Salida desde';

  @override
  String get libraryReleaseTo => 'Salida hasta';

  @override
  String get libraryCompletedFrom => 'Completado desde';

  @override
  String get libraryCompletedTo => 'Completado hasta';

  @override
  String get libraryWithRating => 'Con puntaje';

  @override
  String get libraryWithPlatform => 'Con plataforma';

  @override
  String get libraryWithGenre => 'Con género';

  @override
  String get libraryWithCompletedDate => 'Con fecha completado';

  @override
  String get libraryNoOptions => 'No hay opciones disponibles.';

  @override
  String get libraryClearDate => 'Limpiar fecha';

  @override
  String get libraryChooseDate => 'Elegir fecha';

  @override
  String get libraryVisibleColumns => 'Columnas visibles';

  @override
  String get libraryEmptyTitle => 'Todavía no hay juegos en tu biblioteca.';

  @override
  String get libraryEmptyMessage =>
      'Cuando cargues el primero, el catálogo va a empezar a tomar forma.';

  @override
  String get libraryEmptyFilteredTitle =>
      'No hay juegos que coincidan con la vista actual.';

  @override
  String get libraryEmptyFilteredMessage =>
      'Probá aflojar filtros, cambiar la vista guardada o limpiar la búsqueda.';

  @override
  String get libraryViewUpdated => 'Vista actualizada.';

  @override
  String libraryDeleteViewMessage(Object name) {
    return 'Se eliminará la vista “$name”.';
  }

  @override
  String get libraryDeleteGameTitle => 'Eliminar juego';

  @override
  String libraryDeleteGameMessage(Object title) {
    return 'Se ocultará “$title” de la biblioteca.';
  }

  @override
  String get libraryNoLimit => 'Sin límite';

  @override
  String get libraryDefaultAll => 'Todos los juegos';

  @override
  String get libraryDefaultPending => 'Pendientes';

  @override
  String get libraryDefaultCompleted => 'Completados';

  @override
  String get libraryDefaultByYear => 'Filtrar por año';

  @override
  String librarySelectedCount(Object count) {
    return '$count seleccionados';
  }

  @override
  String librarySelectVisible(Object count) {
    return 'Seleccionar visibles ($count)';
  }

  @override
  String librarySelectAll(Object count) {
    return 'Seleccionar todos ($count)';
  }

  @override
  String get libraryClearSelection => 'Limpiar selección';

  @override
  String get libraryAverage => 'Promedio';

  @override
  String get libraryHours => 'Horas';

  @override
  String get libraryNoOptionsShort => 'Sin opciones';

  @override
  String get columnCover => 'Portada';

  @override
  String get columnTitle => 'Título';

  @override
  String get columnStatus => 'Estado';

  @override
  String get columnPlatforms => 'Plataformas';

  @override
  String get columnGenres => 'Géneros';

  @override
  String get columnRating => 'Puntaje';

  @override
  String get columnReleaseDate => 'Fecha salida';

  @override
  String get columnCompletedDate => 'Fecha completado';

  @override
  String get columnHours => 'Horas';

  @override
  String get columnType => 'Tipo';

  @override
  String get columnNotes => 'Notas';

  @override
  String get columnUpdatedAt => 'Actualizado';

  @override
  String get columnPlaythroughs => 'Playthroughs';

  @override
  String get gameCreateTitle => 'Crear juego';

  @override
  String get gameEditTitle => 'Editar juego';

  @override
  String get gameIdentity => 'Identidad';

  @override
  String get gameIdentitySubtitle => 'Datos del juego y metadata externa.';

  @override
  String get gameName => 'Nombre';

  @override
  String get gameNameRequired => 'El nombre es obligatorio.';

  @override
  String get gameReleaseDate => 'Fecha de salida';

  @override
  String get gamePersonalLibrary => 'Biblioteca personal';

  @override
  String get gamePersonalLibrarySubtitle => 'Estado, puntaje y notas privadas.';

  @override
  String get gamePersonalRating => 'Puntaje personal';

  @override
  String get gamePersonalNotes => 'Notas personales';

  @override
  String get gameCatalogs => 'Catálogos';

  @override
  String get gameCatalogsSubtitle => 'Plataformas y géneros asociados.';

  @override
  String get gameAddPlatform => 'Agregar plataforma';

  @override
  String get gameAddGenre => 'Agregar género';

  @override
  String get gameCompletionSection => 'Completado / partida';

  @override
  String get gameCompletionSectionSubtitle =>
      'Datos iniciales al marcar como completado.';

  @override
  String get gameImportMetadata => 'Importar metadata';

  @override
  String get gameSearchByTitle => 'Buscar por título';

  @override
  String get provider => 'Proveedor';

  @override
  String get gameNoCandidates => 'Sin candidatos todavía';

  @override
  String gameNoCandidatesMessage(Object provider) {
    return 'Buscá un juego para prellenar campos desde $provider.';
  }

  @override
  String get gameApplyToForm => 'Aplicar al formulario';

  @override
  String providerNoCandidates(Object provider) {
    return '$provider no devolvió candidatos.';
  }

  @override
  String get gameSaveIncludedCover => 'Guardar portada incluida';

  @override
  String get gameIncludedCoverReplace =>
      'Reemplazará la portada al guardar el juego.';

  @override
  String get gameIncludedCoverSave =>
      'Se guardará localmente después de guardar el juego.';

  @override
  String get gameSearchMetadata => 'Buscar metadata';

  @override
  String gamePendingCover(Object provider) {
    return 'Portada pendiente: $provider';
  }

  @override
  String get ratingNone => 'Sin puntaje';

  @override
  String get ratingOneStar => '1 estrella';

  @override
  String ratingStars(Object count) {
    return '$count estrellas';
  }

  @override
  String get choose => 'Elegir';

  @override
  String get gameCompletionDate => 'Fecha de completado';

  @override
  String get gameHoursPlayed => 'Horas jugadas';

  @override
  String get gamePlaythroughRating => 'Puntaje de partida';

  @override
  String get gamePlatform => 'Plataforma';

  @override
  String get gameNoPlatform => 'Sin plataforma';

  @override
  String get gameNotFoundTitle => 'Juego no encontrado';

  @override
  String get gameNotFoundMessage => 'No se encontró el juego.';

  @override
  String get errorTitle => 'Error';

  @override
  String get coverSearch => 'Buscar portada';

  @override
  String get coverChange => 'Cambiar portada';

  @override
  String get metadataSearch => 'Buscar metadata';

  @override
  String get gameDeleteTooltip => 'Eliminar juego';

  @override
  String get gameActions => 'Acciones del juego';

  @override
  String get gameRemoveCover => 'Quitar portada';

  @override
  String get gameSummaryProgress => 'Resumen y progreso';

  @override
  String get gameLastCompleted => 'Último completado';

  @override
  String get gamePlaythroughs => 'Partidas';

  @override
  String get gameMarkPlaying => 'Jugando';

  @override
  String get gamePause => 'Pausar';

  @override
  String get gameComplete => 'Completar';

  @override
  String get gameDrop => 'Abandonar';

  @override
  String get gameMoveToBacklog => 'Pendiente';

  @override
  String get gameNewPlaythrough => 'Nueva partida';

  @override
  String get gameNoPlaythroughs => 'Sin partidas registradas';

  @override
  String get gameNoPlaythroughsMessage =>
      'Cuando juegues o completes una partida aparecerá acá.';

  @override
  String get gamePlaythroughActions => 'Acciones de partida';

  @override
  String get metadataApplied => 'Metadata aplicada.';

  @override
  String get coverUpdated => 'Portada actualizada.';

  @override
  String get coverRemoveTitle => 'Quitar portada';

  @override
  String get coverRemoveMessage =>
      'La portada se ocultará del juego, sin borrar físicamente tu historial de media.';

  @override
  String get remove => 'Quitar';

  @override
  String get coverRemoved => 'Portada quitada.';

  @override
  String get gameDeletePlaythroughTitle => 'Eliminar partida';

  @override
  String get gameDeletePlaythroughMessage =>
      'La partida se ocultará del historial.';

  @override
  String get gameMarkCompletedTitle => 'Marcar como completado';

  @override
  String get gameNote => 'Nota';

  @override
  String get gameRegisterPlaythrough => 'Registrar partida';

  @override
  String get gameEditPlaythrough => 'Editar partida';

  @override
  String get gameStartDate => 'Fecha de inicio';

  @override
  String get gameNotes => 'Notas';

  @override
  String gamePlaythroughStart(Object date) {
    return 'Inicio $date';
  }

  @override
  String gamePlaythroughEnd(Object date) {
    return 'Fin $date';
  }

  @override
  String get metadataDialogTitle => 'Buscar metadata';

  @override
  String get metadataTitleField => 'Título';

  @override
  String get metadataNoCandidates => 'Sin candidatos todavía';

  @override
  String metadataNoCandidatesMessage(Object provider) {
    return 'Buscá un juego para ver resultados de $provider.';
  }

  @override
  String get metadataSaveLink => 'Guardar vínculo';

  @override
  String get metadataApply => 'Aplicar metadata';

  @override
  String metadataCoverSaveFailed(Object error) {
    return 'Metadata aplicada, pero no se pudo guardar la portada. $error';
  }

  @override
  String get metadataReplaceCoverTitle => 'Reemplazar portada';

  @override
  String get metadataReplaceCoverMessage =>
      'Este juego ya tiene portada seleccionada. ¿Querés reemplazarla por la portada incluida en IGDB?';

  @override
  String get metadataReplaceExternalTitle => 'Reemplazar match externo';

  @override
  String get metadataReplaceExternalMessage =>
      'Este juego ya tiene otro match externo para este proveedor. ¿Querés reemplazarlo por el candidato seleccionado?';

  @override
  String get metadataOperationFailed =>
      'No se pudo completar la operación de metadata.';

  @override
  String get metadataIncludedCoverExisting =>
      'Este juego ya tiene portada. Se pedirá confirmación antes de reemplazarla.';

  @override
  String get metadataIncludedCoverOffline =>
      'La portada se guardará localmente y quedará disponible offline.';

  @override
  String get metadataNoNewFields =>
      'No hay campos nuevos para aplicar. Podés guardar el vínculo externo.';

  @override
  String get metadataReplaces => 'reemplaza';

  @override
  String get metadataProtected => 'protegido';

  @override
  String metadataCurrentExternal(
    Object current,
    Object external,
    Object provider,
  ) {
    return 'Actual: $current\n$provider: $external';
  }

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get coverDialogSearchTitle => 'Buscar portada';

  @override
  String get coverDialogChangeTitle => 'Cambiar portada';

  @override
  String coverSearchIn(Object provider) {
    return 'Buscar en $provider';
  }

  @override
  String get coverUseLocalFile => 'Usar archivo local';

  @override
  String get coverNoResults => 'Sin portadas todavía';

  @override
  String coverNoResultsMessage(Object provider) {
    return 'Buscá un juego en $provider o elegí un archivo local.';
  }

  @override
  String get coverSave => 'Guardar portada';

  @override
  String providerNoCovers(Object provider) {
    return '$provider no devolvió portadas.';
  }

  @override
  String get coverOperationFailed =>
      'No se pudo completar la operación de portada.';

  @override
  String get backupTitle => 'Datos y backups';

  @override
  String get backupLocalPortability => 'Portabilidad local';

  @override
  String get backupLocalPortabilityMessage =>
      '.vaultbackup no está cifrado y puede incluir notas personales, juegos, estados y media local. .vaultbackup.enc cifra el backup completo con una password que la app no guarda.';

  @override
  String get backupProcessingTitle => 'Procesando archivo';

  @override
  String get backupProcessingMessage =>
      'Esperá mientras Backlog Vault prepara o valida el contenido seleccionado.';

  @override
  String get backupLastOperation => 'Última operación';

  @override
  String get backupRestoreLogicTitle => 'Restauración y reemplazo lógico';

  @override
  String get backupRestoreLogicMessage =>
      'Antes de restaurar, la app crea un backup previo automático. La restauración inserta o actualiza lo que está en el archivo y marca como borrado lógico lo que quedó afuera.';

  @override
  String get backupRestore => 'Restaurar backup';

  @override
  String get backupRestoreEncrypted => 'Restaurar cifrado';

  @override
  String get backupCreated => 'Backup completo creado.';

  @override
  String get backupEncryptedCreated => 'Backup cifrado creado.';

  @override
  String get backupJsonCreated => 'Export JSON creado.';

  @override
  String get backupCsvCreated => 'Export CSV creado.';

  @override
  String get backupRestoredWithSafety =>
      'Backup restaurado. Se creó un backup previo automático.';

  @override
  String get backupRestored => 'Backup restaurado.';

  @override
  String get backupEncryptedRestoredWithSafety =>
      'Backup cifrado restaurado. Se creó un backup previo cifrado automático.';

  @override
  String get backupEncryptedRestored => 'Backup cifrado restaurado.';

  @override
  String get backupConfirmRestore => 'Confirmar restauración';

  @override
  String backupDate(Object date) {
    return 'Fecha: $date';
  }

  @override
  String backupGames(Object count) {
    return 'Juegos: $count';
  }

  @override
  String backupPlaythroughs(Object count) {
    return 'Playthroughs: $count';
  }

  @override
  String backupMediaFiles(Object count) {
    return 'Media: $count archivos';
  }

  @override
  String backupSchema(Object version) {
    return 'Schema: $version';
  }

  @override
  String backupWarnings(Object count) {
    return 'Warnings: $count';
  }

  @override
  String get backupTypeRestore => 'Escribí RESTAURAR para continuar.';

  @override
  String get backupRestoreKeyword => 'RESTAURAR';

  @override
  String get backupOperationFailed => 'No se pudo completar la operación.';

  @override
  String get backupCreateEncrypted => 'Crear backup cifrado';

  @override
  String get backupOpenEncrypted => 'Abrir backup cifrado';

  @override
  String get backupPasswordWarning =>
      'La password no se guarda. Si la perdés, el backup cifrado no se puede recuperar.';

  @override
  String get backupPassword => 'Password';

  @override
  String get backupRepeatPassword => 'Repetir password';

  @override
  String get backupEnterPassword => 'Ingresá una password.';

  @override
  String get backupPasswordsMismatch => 'Las passwords no coinciden.';

  @override
  String get openAction => 'Abrir';

  @override
  String get backupCompleteTitle => 'Backup completo';

  @override
  String get backupCompleteDescription =>
      'Genera un .vaultbackup con juegos, partidas, metadata aplicada y media local sin cifrado.';

  @override
  String get backupCreate => 'Crear backup';

  @override
  String get backupEncryptedTitle => 'Backup cifrado';

  @override
  String get backupEncryptedDescription =>
      'Genera un .vaultbackup.enc protegido con password. La password no queda almacenada.';

  @override
  String get backupExportJson => 'Exportar JSON';

  @override
  String get backupExportJsonDescription =>
      'Exporta la biblioteca en un formato legible y útil para revisión o scripting local.';

  @override
  String get backupExportCsv => 'Exportar CSV';

  @override
  String get backupExportCsvDescription =>
      'Genera una exportación tabular compacta para hojas de cálculo o intercambio manual.';

  @override
  String get backupRestoreDescription =>
      'Abre un .vaultbackup, muestra preview y pide confirmación fuerte antes de aplicar cambios.';

  @override
  String get backupRestoreEncryptedDescription =>
      'Abre un .vaultbackup.enc, pide password y valida el contenido antes de reemplazar datos.';

  @override
  String get warnings => 'Warnings';

  @override
  String get errors => 'Errores';

  @override
  String get csvImportTitle => 'Importar CSV de Notion';

  @override
  String get csvFlowTitle => 'Flujo de importación';

  @override
  String get csvFlowDescription =>
      'Este flujo crea juegos nuevos a partir del CSV exportado desde Notion. No actualiza juegos existentes y te deja revisar el mapping antes de aplicar cambios.';

  @override
  String get csvMappingNeedsName =>
      'El mapping necesita una columna para Nombre.';

  @override
  String get csvConfirmTitle => 'Confirmar importación';

  @override
  String csvConfirmMessage(Object count) {
    return 'Se importarán $count juegos. No se actualizarán juegos existentes.';
  }

  @override
  String get csvImportAction => 'Importar';

  @override
  String get stepOne => 'Paso 1';

  @override
  String get stepTwo => 'Paso 2';

  @override
  String get stepThree => 'Paso 3';

  @override
  String get stepFour => 'Paso 4';

  @override
  String get csvChooseFile => 'Elegir archivo';

  @override
  String get csvChooseFileDescription =>
      'Seleccioná el CSV exportado desde Notion. La app detecta delimitador, columnas y cantidad de filas antes de avanzar.';

  @override
  String get csvNoFile => 'Todavía no hay archivo seleccionado';

  @override
  String get csvNoFileMessage =>
      'Elegí un CSV para revisar headers, mapping y preview de importación.';

  @override
  String csvRows(Object count) {
    return '$count filas';
  }

  @override
  String csvColumns(Object count) {
    return '$count columnas';
  }

  @override
  String csvDelimiter(Object delimiter) {
    return 'Delimitador “$delimiter”';
  }

  @override
  String get csvSelect => 'Seleccionar CSV';

  @override
  String get csvChange => 'Cambiar CSV';

  @override
  String get csvColumnMapping => 'Mapping de columnas';

  @override
  String get csvColumnMappingDescription =>
      'Definí cómo se interpretan los headers del CSV. Solo Nombre es obligatorio para generar preview.';

  @override
  String get csvMissingNameMapping =>
      'Falta mapear Nombre antes de generar el preview.';

  @override
  String get csvDoNotImport => 'No importar';

  @override
  String get csvGeneratePreview => 'Generar preview';

  @override
  String get csvPreviewDescription =>
      'Revisá qué filas se importan, cuáles quedan omitidas y dónde aparecen warnings o duplicados.';

  @override
  String get csvConfirmImport => 'Confirmar importación';

  @override
  String csvImportable(Object count) {
    return '$count importables';
  }

  @override
  String csvOmitted(Object count) {
    return '$count omitidas';
  }

  @override
  String csvWithWarnings(Object count) {
    return '$count con warnings';
  }

  @override
  String csvWithErrors(Object count) {
    return '$count con errores';
  }

  @override
  String csvDuplicates(Object count) {
    return '$count duplicadas';
  }

  @override
  String get csvNoRows => 'No hay filas para revisar';

  @override
  String get csvNoRowsMessage =>
      'El preview no generó resultados visibles para importar.';

  @override
  String csvUnnamedRow(Object row) {
    return 'Fila $row sin nombre';
  }

  @override
  String get csvHasErrors => 'Con errores';

  @override
  String get csvWarning => 'Warning';

  @override
  String get csvDuplicate => 'Duplicado';

  @override
  String get csvSkipDuplicate => 'Omitir duplicado';

  @override
  String get csvCreateAnyway => 'Crear igual';

  @override
  String get csvResult => 'Resultado';

  @override
  String get csvResultDescription =>
      'Resumen de lo que entró realmente a tu biblioteca local.';

  @override
  String csvImported(Object count) {
    return 'Importados $count';
  }

  @override
  String csvSkipped(Object count) {
    return 'Omitidas $count';
  }

  @override
  String csvDuplicateSkipped(Object count) {
    return 'Duplicados $count';
  }

  @override
  String csvPlatformsCreated(Object count) {
    return 'Plataformas $count';
  }

  @override
  String csvGenresCreated(Object count) {
    return 'Géneros $count';
  }

  @override
  String csvPlaythroughsCreated(Object count) {
    return 'Partidas $count';
  }

  @override
  String get csvBackToLibrary => 'Volver a biblioteca';

  @override
  String get cannotContinue => 'No se pudo continuar';

  @override
  String get importFieldTitle => 'Nombre';

  @override
  String get importFieldReleaseDate => 'Fecha de salida';

  @override
  String get importFieldCompletedAt => 'Fecha de completado';

  @override
  String get importFieldHours => 'Duración';

  @override
  String get importFieldRating => 'Puntaje';

  @override
  String get importFieldGenres => 'Géneros';

  @override
  String get importFieldPlatforms => 'Plataformas';

  @override
  String get importFieldStatus => 'Estado';

  @override
  String get importFieldType => 'Tipo';

  @override
  String get importFieldNotes => 'Notas';

  @override
  String get bulkTitle => 'Importar metadata';

  @override
  String get bulkIntroTitle => 'Importación masiva';

  @override
  String get bulkIntroDescription =>
      'Definí alcance, revisá el preview y confirmá exactamente qué metadata o covers se aplican antes de ejecutar cambios en lote.';

  @override
  String get bulkLoadingLibrary => 'Cargando biblioteca';

  @override
  String bulkPreviewFailed(Object error) {
    return 'No se pudo generar el preview. $error';
  }

  @override
  String get bulkConfirmTitle => 'Confirmar importación masiva';

  @override
  String get bulkConfirmMessage =>
      'Se aplicarán solo los juegos, campos y covers seleccionados.';

  @override
  String bulkConfirmSummary(
    Object games,
    Object newCovers,
    Object newFields,
    Object replacedCovers,
    Object replacedFields,
  ) {
    return 'Juegos: $games\nCampos nuevos: $newFields\nCampos reemplazados: $replacedFields\nCovers nuevos: $newCovers\nCovers reemplazados: $replacedCovers';
  }

  @override
  String bulkTypeConfirmation(Object keyword) {
    return 'Escribí $keyword para confirmar.';
  }

  @override
  String get bulkReplace => 'Reemplazar';

  @override
  String get bulkApply => 'Aplicar';

  @override
  String get bulkWhatImport => 'Qué querés importar';

  @override
  String get bulkWhatImportDescription =>
      'Elegí el tipo de importación y después ajustá alcance, proveedor y reglas de reemplazo antes de generar el preview.';

  @override
  String get bulkGamesToAnalyze => 'Juegos a analizar';

  @override
  String get bulkGamesToAnalyzeHelper => 'Esto no decide qué se pisa.';

  @override
  String get bulkMetadataProvider => 'Provider metadata';

  @override
  String get bulkMetadataMode => 'Modo metadata';

  @override
  String get bulkCoverSource => 'Fuente de portada';

  @override
  String get bulkExistingCovers => 'Portadas existentes';

  @override
  String get bulkScanning => 'Escaneando biblioteca';

  @override
  String get bulkPreviewTitle => 'Preview';

  @override
  String get bulkPreviewDescription =>
      'Filtrá coincidencias, revisá cambios y dejá seleccionados solo los juegos y campos que querés aplicar.';

  @override
  String get bulkAnalyzed => 'Analizados';

  @override
  String get bulkWithMatch => 'Con match';

  @override
  String get bulkWithoutMatch => 'Sin match';

  @override
  String get bulkSafe => 'Seguros';

  @override
  String get bulkProbable => 'Probables';

  @override
  String get bulkAmbiguous => 'Ambiguos';

  @override
  String get bulkWithCover => 'Con cover';

  @override
  String get bulkWithoutCover => 'Sin cover';

  @override
  String get bulkSelected => 'Seleccionados';

  @override
  String get bulkNewFields => 'Campos nuevos';

  @override
  String get bulkReplacedFields => 'Campos reemplazados';

  @override
  String get bulkNewCovers => 'Covers nuevos';

  @override
  String get bulkReplacedCovers => 'Covers reemplazados';

  @override
  String get bulkSelectVisible => 'Seleccionar visibles';

  @override
  String get bulkDeselectAll => 'Deseleccionar todos';

  @override
  String get bulkSelectSafe => 'Seleccionar seguros';

  @override
  String get bulkNewCoverSelection => 'Portadas nuevas';

  @override
  String get bulkCoverReplacements => 'Reemplazos portada';

  @override
  String get bulkReplaceableFields => 'Campos reemplazables';

  @override
  String get bulkNoGamesForFilter => 'No hay juegos para este filtro';

  @override
  String get bulkNoGamesForFilterMessage =>
      'Probá cambiar el filtro del preview o revisar el alcance seleccionado en el paso anterior.';

  @override
  String get bulkCandidates => 'Candidatos';

  @override
  String get bulkUse => 'Usar';

  @override
  String get bulkNoMetadataFields => 'No hay campos de metadata para aplicar.';

  @override
  String get bulkFields => 'Campos';

  @override
  String bulkCurrentExternal(Object current, Object external) {
    return 'Actual: $current\nExterno: $external';
  }

  @override
  String get bulkSaveCover => 'Guardar portada';

  @override
  String get bulkChooseCover => 'Elegir portada';

  @override
  String get bulkNoCoverFound => 'Sin cover encontrado';

  @override
  String get bulkCoverReplacementSelected =>
      'Reemplazo de portada seleccionado';

  @override
  String get bulkNewCoverSelected => 'Portada nueva seleccionada';

  @override
  String get bulkAlreadyHasCover => 'Ya tiene portada';

  @override
  String get bulkCoverFound => 'Cover encontrado';

  @override
  String bulkChooseCoverFor(Object title) {
    return 'Elegir portada · $title';
  }

  @override
  String get bulkFinalConfirmation => 'Confirmación final';

  @override
  String get bulkFinalConfirmationDescription =>
      'Se aplican solo los juegos, campos y covers que siguen seleccionados en el preview.';

  @override
  String bulkFinalSummary(
    Object games,
    Object newCovers,
    Object newFields,
    Object replacedCovers,
    Object replacedFields,
  ) {
    return '$games juegos seleccionados · $newFields campos a completar · $replacedFields campos a reemplazar · $newCovers portadas nuevas · $replacedCovers portadas a reemplazar.';
  }

  @override
  String get bulkApplyChanges => 'Aplicar cambios';

  @override
  String get bulkResultTitle => 'Importación finalizada';

  @override
  String get bulkResultDescription =>
      'Resumen de coincidencias, cambios guardados y warnings o errores devueltos por el proceso.';

  @override
  String get bulkProcessed => 'Procesados';

  @override
  String get bulkNewMetadata => 'Metadata nueva';

  @override
  String get bulkReplacedMetadata => 'Metadata reemplazada';

  @override
  String get bulkLinks => 'Vínculos';

  @override
  String get bulkSkipped => 'Omitidos';

  @override
  String get bulkNewPreview => 'Generar nuevo preview';

  @override
  String get bulkFilterAll => 'Todos';

  @override
  String get bulkFilterSelected => 'Seleccionados';

  @override
  String get bulkFilterSafe => 'Seguros';

  @override
  String get bulkFilterProbable => 'Probables';

  @override
  String get bulkFilterAmbiguous => 'Ambiguos';

  @override
  String get bulkFilterErrors => 'Errores';

  @override
  String get bulkFilterNoResult => 'Sin resultado';

  @override
  String get bulkFilterMetadata => 'Con metadata';

  @override
  String get bulkFilterCover => 'Con cover';

  @override
  String get bulkFilterReplacements => 'Con reemplazos';

  @override
  String get bulkScopeAll => 'Todos los juegos activos';

  @override
  String get bulkScopeNoMetadata => 'Solo sin metadata';

  @override
  String get bulkScopeNoCover => 'Solo sin portada';

  @override
  String get bulkScopeIncomplete => 'Solo datos incompletos';

  @override
  String get bulkContentMetadataOnly => 'Solo metadata';

  @override
  String get bulkContentCoverOnly => 'Solo cover art';

  @override
  String get bulkContentBoth => 'Metadata + cover art';

  @override
  String get bulkContentMetadataOnlyDescription =>
      'Completar o revisar campos de metadata sin descargar portadas.';

  @override
  String get bulkContentCoverOnlyDescription =>
      'Buscar portadas para juegos existentes sin aplicar campos de metadata.';

  @override
  String get bulkContentBothDescription =>
      'Revisar metadata y portadas en el mismo preview antes de aplicar.';

  @override
  String get bulkConfidenceSafe => 'Seguro';

  @override
  String get bulkConfidenceProbable => 'Probable';

  @override
  String get bulkConfidenceAmbiguous => 'Ambiguo';

  @override
  String get bulkConfidenceNone => 'Sin match';

  @override
  String get bulkCompleteMissing => 'Completar faltantes';

  @override
  String get bulkReviewReplace => 'Revisar y reemplazar';

  @override
  String get bulkNoCovers => 'No importar covers';

  @override
  String get bulkIgdbFirst => 'IGDB primero + SteamGridDB fallback';

  @override
  String get bulkSteamFirst => 'SteamGridDB primero + IGDB fallback';

  @override
  String get bulkKeepCovers => 'Mantener portadas existentes';

  @override
  String get bulkAllowCoverReplace => 'Permitir reemplazo con confirmación';

  @override
  String get bulkCurrentCover => 'portada actual';

  @override
  String bulkReplacesCover(Object cover) {
    return 'reemplaza $cover';
  }

  @override
  String get syncSectionTitle => 'Sincronización';

  @override
  String get syncSectionDescription =>
      'Mantené alineados dos dispositivos de Backlog Vault sin cuenta ni cloud.';

  @override
  String get syncFoundationReady => 'Base técnica preparada';

  @override
  String get syncManualAvailable =>
      'Los paquetes cifrados de sincronización manual están disponibles.';

  @override
  String get syncNotReady =>
      'La base de sincronización no está lista en este dispositivo.';

  @override
  String get syncLocalDevice => 'Dispositivo local';

  @override
  String get syncExportPackage => 'Exportar paquete de cambios';

  @override
  String get syncImportPackage => 'Importar paquete de cambios';

  @override
  String get syncEncryptedNotice => 'Este paquete está cifrado con contraseña.';

  @override
  String get syncConflictNotice =>
      'Los cambios conflictivos no se aplicarán automáticamente.';

  @override
  String get syncMediaNotice =>
      'También se transfieren portadas gestionadas por la app cuando sea posible.';

  @override
  String get syncPackageVsBackup =>
      '.vaultsync transporta cambios cifrados; no es un backup completo. Usá .vaultbackup.enc para migración o recuperación completa.';

  @override
  String get syncPasswordExportTitle => 'Proteger paquete de cambios';

  @override
  String get syncPasswordImportTitle => 'Abrir paquete de cambios';

  @override
  String get syncPassword => 'Contraseña';

  @override
  String get syncRepeatPassword => 'Repetir contraseña';

  @override
  String get syncPasswordRequired => 'Ingresá una contraseña.';

  @override
  String get syncPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get syncPasswordForgotten =>
      'La contraseña no se guarda. Si la perdés, este paquete no se puede recuperar.';

  @override
  String get syncSaveDialogTitle => 'Guardar paquete cifrado de sincronización';

  @override
  String syncExportCreated(Object count) {
    return 'Paquete cifrado creado con $count cambios.';
  }

  @override
  String get syncPreviewTitle => 'Vista previa del paquete de sincronización';

  @override
  String syncFromDevice(Object name) {
    return 'Origen: $name';
  }

  @override
  String syncPackageDate(Object date) {
    return 'Creado: $date';
  }

  @override
  String syncPreviewChanges(Object count) {
    return 'Cambios: $count';
  }

  @override
  String syncPreviewAlreadyApplied(Object count) {
    return 'Ya aplicados: $count';
  }

  @override
  String syncPreviewApplicable(Object count) {
    return 'Seguros para aplicar: $count';
  }

  @override
  String syncPreviewConflicts(Object count) {
    return 'Conflictos omitidos: $count';
  }

  @override
  String syncPreviewUnsupported(Object count) {
    return 'No soportados: $count';
  }

  @override
  String syncPreviewInvalid(Object count) {
    return 'Inválidos: $count';
  }

  @override
  String syncPreviewPendingMedia(Object count) {
    return 'Archivos de portada pendientes: $count';
  }

  @override
  String get syncApplySafeChanges => 'Aplicar cambios seguros';

  @override
  String syncAppliedCount(Object count) {
    return 'Se aplicaron $count cambios seguros.';
  }

  @override
  String get syncNoSafeChanges => 'No hay cambios seguros nuevos para aplicar.';

  @override
  String get syncImportResultTitle => 'Resultado de sincronización manual';

  @override
  String get syncOperationFailed =>
      'No se pudo completar la operación del paquete. Revisá la contraseña y el archivo.';

  @override
  String get syncPairingTitle => 'Emparejamiento de dispositivos';

  @override
  String get syncPairingDescription =>
      'El emparejamiento permite usar paquetes de sincronización sin escribir una contraseña cada vez y habilita sync manual por red local.';

  @override
  String get syncNoGroup =>
      'Este dispositivo todavía no está conectado a ningún grupo de sincronización.';

  @override
  String get syncGroupConfigured => 'Dispositivo listo para sincronizar';

  @override
  String syncGroupName(Object name) {
    return 'Grupo: $name';
  }

  @override
  String syncPairedDevices(Object count) {
    return 'Dispositivos emparejados conocidos: $count';
  }

  @override
  String get syncGroupKeyAvailable =>
      'Este dispositivo tiene la información local necesaria para sincronizar.';

  @override
  String get syncGroupKeyMissing =>
      'Este dispositivo necesita conectarse de nuevo antes de sincronizar.';

  @override
  String get syncCreateGroup => 'Conectar otro dispositivo';

  @override
  String get syncCreateGroupTitle => 'Nombrar grupo de sincronización';

  @override
  String get syncGroupNameLabel => 'Nombre del grupo';

  @override
  String get syncGroupNameRequired => 'Ingresá un nombre para el grupo.';

  @override
  String get syncExportInvitation => 'Crear invitación como archivo';

  @override
  String get syncImportInvitation => 'Importar archivo de invitación';

  @override
  String get syncInvitationNotice =>
      'Compartí la invitación y su contraseña temporal por canales separados.';

  @override
  String get syncPairingPasswordTitle =>
      'Proteger invitación de emparejamiento';

  @override
  String get syncPairingPasswordOpenTitle =>
      'Abrir invitación de emparejamiento';

  @override
  String get syncPairingSaveDialogTitle =>
      'Guardar invitación cifrada de emparejamiento';

  @override
  String get syncInvitationCreated =>
      'Invitación cifrada creada. Vence después de 24 horas.';

  @override
  String get syncInvitationImported =>
      'Este dispositivo se unió al grupo de sincronización.';

  @override
  String get syncInvitationExpired =>
      'Esta invitación de emparejamiento venció.';

  @override
  String get syncPairingExistingGroup =>
      'Este dispositivo ya pertenece a otro grupo. Salí de ese grupo antes de importar una invitación distinta.';

  @override
  String get syncGroupPackageMismatch =>
      'Este paquete pertenece a otro grupo de sincronización.';

  @override
  String get syncGroupKeyMismatch =>
      'Este paquete usa otra clave de grupo. Volvé a emparejar este dispositivo.';

  @override
  String get syncLeaveGroup => 'Salir del grupo de sincronización';

  @override
  String get syncLeaveGroupTitle => '¿Salir del grupo de sincronización?';

  @override
  String get syncLeaveGroupWarning =>
      'La clave del grupo se borrará del secure storage. La biblioteca y el historial de cambios no se eliminarán.';

  @override
  String get syncLeaveGroupDone =>
      'Este dispositivo salió del grupo de sincronización.';

  @override
  String get syncGroupPackagesTitle => 'Paquetes manuales de cambios';

  @override
  String get syncExportGroupPackage => 'Exportar paquete de cambios';

  @override
  String get syncImportGroupPackage => 'Importar paquete de cambios';

  @override
  String syncGroupPackageCreated(Object count) {
    return 'Paquete cifrado con clave de grupo creado con $count cambios.';
  }

  @override
  String get syncPairingOperationFailed =>
      'No se pudo completar el emparejamiento. Revisá la invitación y la contraseña temporal.';

  @override
  String get syncNoAutomaticSync =>
      'El emparejamiento no sincroniza automáticamente ni habilita sync en segundo plano.';

  @override
  String get syncShowPairingQr => 'Mostrar QR de invitación';

  @override
  String get syncScanPairingQr => 'Escanear QR de invitación';

  @override
  String get syncPastePairingCode => 'Pegar código de invitación';

  @override
  String get syncPairingQrTitle => 'QR de invitación';

  @override
  String get syncPairingQrHelp =>
      'El QR transporta la invitación protegida. Seguí usando la contraseña temporal y compartila por un canal confiable separado.';

  @override
  String get syncPairingManualFallback =>
      'También podés exportar un archivo .vaultpair o pegar el código de invitación manualmente.';

  @override
  String get syncQrDoesNotReplaceEncryption =>
      'El QR no reemplaza el cifrado; sólo simplifica la conexión.';

  @override
  String get syncQrNoPlaintextSecrets =>
      'Este QR no contiene tu biblioteca ni tus claves en claro.';

  @override
  String get syncQrTemporaryPasswordSeparate =>
      'Compartí la contraseña temporal por un canal separado.';

  @override
  String get syncManualConnectionFallback =>
      'También podés ingresar IP, puerto y código manualmente.';

  @override
  String get syncNoAutomaticDiscovery =>
      'La sincronización automática y el discovery todavía no están disponibles.';

  @override
  String get syncQrPayloadField => 'Payload QR';

  @override
  String get syncQrPayloadInvalid =>
      'El payload QR es inválido o está incompleto.';

  @override
  String get syncQrPayloadTooLarge =>
      'Este payload QR es demasiado grande. Usá el fallback con archivo .vaultpair.';

  @override
  String get syncQrScannerUnavailable =>
      'El escaneo QR está disponible en Android. En esta plataforma, pegá el código manualmente.';

  @override
  String get syncQrCopyPayload => 'Copiar código';

  @override
  String get syncQrCopied => 'Código QR copiado.';

  @override
  String get syncQrCopyHelp =>
      'Si el escaneo no está disponible, copiá o pegá este código de texto en el otro dispositivo.';

  @override
  String get syncUxNoGroupMessage =>
      'Este dispositivo todavía no está conectado a ningún grupo de sincronización.';

  @override
  String get syncUxReadyMessage =>
      'Este dispositivo está listo para sincronizar.';

  @override
  String get syncUxNoCloud =>
      'La sincronización usa cifrado local. No hay cloud.';

  @override
  String get syncUxReconnectNeeded =>
      'Este dispositivo estuvo conectado antes, pero le falta información local de sincronización. Importá una nueva invitación para conectarlo otra vez.';

  @override
  String get syncUxConnectDeviceCta => 'Conectar otro dispositivo';

  @override
  String syncUxLocalDevice(Object id, Object name, Object platform) {
    return 'Este dispositivo: $name · $platform · $id';
  }

  @override
  String get syncUxWifiDescription =>
      'Usá esta opción para sincronizar dos dispositivos emparejados y conectados a la misma red.';

  @override
  String get syncUxWifiDisabledHint => 'Primero conectá otro dispositivo.';

  @override
  String get syncUxPairDeviceTitle => 'Conectar un teléfono o PC';

  @override
  String get syncUxPairDeviceDescription =>
      'Primero conectá tus dispositivos. Después vas a poder sincronizarlos sin escribir una contraseña cada vez.';

  @override
  String get syncUxAdvancedTitle => 'Opciones avanzadas';

  @override
  String get syncUxAdvancedDescription =>
      'Usá paquetes manuales si no podés sincronizar por Wi-Fi.';

  @override
  String get syncUxExportPasswordPackage => 'Exportar con contraseña';

  @override
  String get syncUxImportPasswordPackage => 'Importar con contraseña';

  @override
  String get syncLanTitle => 'Sincronizar por Wi-Fi';

  @override
  String get syncLanDescription =>
      'Iniciá una sesión temporal de sync por Wi-Fi en un dispositivo emparejado y conectate desde el otro con la IP, puerto y código de sesión mostrados.';

  @override
  String get syncLanPairFirst => 'Primero conectá otro dispositivo.';

  @override
  String get syncLanMediaNotice =>
      'También se transfieren portadas gestionadas por la app cuando sea posible.';

  @override
  String get syncLanStartSession => 'Iniciar sincronización';

  @override
  String get syncLanStopSession => 'Detener sesión';

  @override
  String get syncLanConnectSession => 'Unirse a sincronización';

  @override
  String get syncShowLanQr => 'Mostrar QR de conexión';

  @override
  String get syncScanLanQr => 'Escanear QR de conexión';

  @override
  String get syncPasteLanQr => 'Pegar código de conexión';

  @override
  String get syncLanQrTitle => 'QR de conexión LAN';

  @override
  String get syncLanQrHelp =>
      'Este QR transporta sólo host, puerto, código de sesión, group id y key id. No contiene la clave del grupo ni datos de biblioteca.';

  @override
  String get syncLanWaiting => 'Esperando un dispositivo emparejado.';

  @override
  String syncLanHostAddress(Object host) {
    return 'Host/IP: $host';
  }

  @override
  String syncLanPort(Object port) {
    return 'Puerto: $port';
  }

  @override
  String syncLanSessionCode(Object code) {
    return 'Código de sesión: $code';
  }

  @override
  String syncLanHostDevice(Object name) {
    return 'Dispositivo host: $name';
  }

  @override
  String get syncLanClientHelp =>
      'Ingresá la IP/host, puerto y código de sesión que muestra el otro dispositivo emparejado.';

  @override
  String get syncLanHostField => 'IP o host';

  @override
  String get syncLanPortField => 'Puerto';

  @override
  String get syncLanSessionCodeField => 'Código de sesión';

  @override
  String get syncLanConnectAndSync => 'Conectar y sincronizar';

  @override
  String get syncLanInvalidInput =>
      'Ingresá un host, puerto válido y código de sesión.';

  @override
  String get syncLanInvalidSessionCode => 'Código incorrecto o sesión vencida.';

  @override
  String get syncLanGroupMismatch =>
      'El dispositivo pertenece a otro grupo de sincronización.';

  @override
  String get syncLanKeyMismatch =>
      'La clave de sincronización no coincide. Volvé a emparejar este dispositivo.';

  @override
  String get syncLanProtocolMismatch =>
      'La versión del protocolo de sync es incompatible.';

  @override
  String get syncLanRequestTooLarge =>
      'El paquete de sincronización excede el tamaño máximo permitido.';

  @override
  String get syncLanPackageRejected =>
      'El paquete de sincronización está dañado o no se pudo verificar.';

  @override
  String get syncLanNetworkUnavailable =>
      'No se pudo conectar con el dispositivo.';

  @override
  String get syncLanConnectionInterrupted =>
      'La conexión se interrumpió antes de completar la sincronización.';

  @override
  String get syncLanTimeout => 'Tiempo de espera agotado.';

  @override
  String get syncLanFailed => 'No se pudo completar la sesión de sync LAN.';

  @override
  String get syncLanStopped => 'La sincronización fue cancelada.';

  @override
  String syncLanResultPeer(Object name) {
    return 'Par: $name';
  }

  @override
  String syncLanResultSent(Object count) {
    return 'Cambios enviados: $count';
  }

  @override
  String syncLanResultReceived(Object count) {
    return 'Cambios recibidos: $count';
  }

  @override
  String syncLanResultApplied(Object count) {
    return 'Aplicados localmente: $count';
  }

  @override
  String syncLanResultAlreadyApplied(Object count) {
    return 'Ya aplicados localmente: $count';
  }

  @override
  String syncLanResultConflicts(Object count) {
    return 'Conflictos locales omitidos: $count';
  }

  @override
  String syncLanResultPendingMedia(Object count) {
    return 'Portadas locales pendientes: $count';
  }

  @override
  String syncLanResultMediaRequested(Object count) {
    return 'Portadas solicitadas: $count';
  }

  @override
  String syncLanResultMediaReceived(Object count) {
    return 'Portadas recibidas: $count';
  }

  @override
  String syncLanResultMediaSkipped(Object count) {
    return 'Portadas omitidas: $count';
  }

  @override
  String syncLanResultMediaFailed(Object count) {
    return 'Portadas fallidas: $count';
  }

  @override
  String syncLanResultMediaBytes(Object count) {
    return 'Bytes de portada transferidos: $count';
  }

  @override
  String syncLanPeerApplied(Object count) {
    return 'El otro dispositivo aplicó: $count';
  }

  @override
  String syncLanPeerConflicts(Object count) {
    return 'Conflictos omitidos en el otro dispositivo: $count';
  }

  @override
  String syncLanPeerPendingMedia(Object count) {
    return 'Portadas pendientes en el otro dispositivo: $count';
  }

  @override
  String syncLanPeerMediaReceived(Object count) {
    return 'El otro dispositivo recibió portadas: $count';
  }

  @override
  String syncLanPeerMediaFailed(Object count) {
    return 'Portadas fallidas en el otro dispositivo: $count';
  }
}
