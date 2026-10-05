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
  String get navigationLibrary => 'Juegos';

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
  String get unexpectedErrorMessage => 'Algo salió mal. Volvé a intentarlo.';

  @override
  String get gameLoadError => 'No se pudo cargar el juego.';

  @override
  String get gameSaveFailed => 'No se pudo guardar el juego.';

  @override
  String get csvOperationFailed => 'No se pudo completar la operación del CSV.';

  @override
  String get bulkOperationFailed => 'No se pudo completar la operación masiva.';

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
      'La base local y los archivos de media permanecen en este dispositivo. La exportación excluye imágenes y credenciales.';

  @override
  String get settingsLibraryData => 'Datos de la biblioteca';

  @override
  String get settingsLibraryDataSubtitle =>
      'Guarda tus juegos y datos personales en un archivo JSON. La exportación no incluye imágenes ni credenciales.';

  @override
  String get settingsExportLibrary => 'Exportar biblioteca';

  @override
  String get libraryExportSucceeded => 'Biblioteca exportada correctamente.';

  @override
  String get libraryExportCancelled => 'No se seleccionó una ubicación.';

  @override
  String get libraryExportFailed => 'No se pudo exportar la biblioteca.';

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
  String get settingsClientId => 'Client ID';

  @override
  String get settingsClientSecret => 'Client Secret';

  @override
  String get settingsApiKeyHelper =>
      'No se incluye en exportaciones de biblioteca, no se muestra en claro y no debe terminar en commits.';

  @override
  String get settingsClientIdHelper =>
      'Se guarda solo en este dispositivo y no se incluye en exportaciones de biblioteca.';

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
  String get statusBacklog => 'No terminado';

  @override
  String get statusCompleted => 'Terminado';

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
  String get completed => 'Completados';

  @override
  String get missingCover => 'Sin portada';

  @override
  String get missingMetadata => 'Sin metadata';

  @override
  String get missingGenre => 'Sin género';

  @override
  String get statisticsLibraryLoading => 'Cargando biblioteca';

  @override
  String get statisticsLoadError => 'No se pudo cargar estadísticas';

  @override
  String get statisticsAverageRating => 'Rating promedio';

  @override
  String hoursShort(Object value) {
    return '$value h';
  }

  @override
  String get apply => 'Aplicar';

  @override
  String get name => 'Nombre';

  @override
  String get view => 'Vista';

  @override
  String get importCsv => 'Importar CSV';

  @override
  String get importMetadata => 'Importar metadata';

  @override
  String get libraryLoading => 'Cargando biblioteca';

  @override
  String get libraryLoadError => 'No se pudo cargar la biblioteca';

  @override
  String get libraryConfirmation => 'Confirmación';

  @override
  String get libraryPlatforms => 'Plataformas';

  @override
  String get libraryGenres => 'Géneros';

  @override
  String get libraryType => 'Tipo';

  @override
  String get libraryDeleteGameTitle => 'Eliminar juego';

  @override
  String libraryDeleteGameMessage(Object title) {
    return 'Se ocultará “$title” de la biblioteca.';
  }

  @override
  String get libraryHours => 'Horas';

  @override
  String get gameCreateTitle => 'Crear juego';

  @override
  String get gameEditTitle => 'Editar juego';

  @override
  String get gameName => 'Nombre';

  @override
  String get gameNameRequired => 'El nombre es obligatorio.';

  @override
  String get gameReleaseDate => 'Fecha de salida';

  @override
  String get gameMyRecord => 'Mi registro';

  @override
  String get gameMyRecordHint =>
      'Tu experiencia con el juego. Todos los datos son opcionales.';

  @override
  String get gameInformation => 'Información del juego';

  @override
  String get gameInformationHint =>
      'Lanzamiento, tipo, géneros y plataformas del catálogo.';

  @override
  String get gameFindGame => 'Buscar juego';

  @override
  String get gameIdentifyHint =>
      'Buscá un juego o escribí su nombre para agregarlo manualmente.';

  @override
  String get gameFinishDate => 'Fecha de finalización (opcional)';

  @override
  String get gameRating => 'Puntaje';

  @override
  String get gamePersonalRating => 'Puntaje personal';

  @override
  String get gamePersonalNotes => 'Notas personales';

  @override
  String get gameAddPlatform => 'Agregar plataforma';

  @override
  String get gameAddGenre => 'Agregar género';

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
  String gamePendingCover(Object provider) {
    return 'Portada pendiente: $provider';
  }

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
  String get gameNote => 'Nota';

  @override
  String get gameNotes => 'Notas';

  @override
  String get metadataDialogTitle => 'Buscar metadata';

  @override
  String get metadataTitleField => 'Título';

  @override
  String externalIdValue(Object id, Object provider) {
    return '$provider · ID $id';
  }

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
  String get metadataCoverSaveFailed =>
      'Metadata aplicada, pero no se pudo guardar la portada.';

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
  String get bulkPreviewFailed => 'No se pudo generar el preview.';

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
  String bulkScoreValue(Object score) {
    return 'Puntaje $score';
  }

  @override
  String get bulkGlobalIssue => 'Global';

  @override
  String get bulkIssueNoCandidates => 'El proveedor no devolvió candidatos.';

  @override
  String get bulkIssueProbableMatch =>
      'Match probable: revisalo antes de aplicar.';

  @override
  String get bulkIssueAmbiguousMatch =>
      'Match ambiguo: requiere revisión manual.';

  @override
  String get bulkIssueExternalReplacementAllowed =>
      'Este juego ya tiene otro match externo para el proveedor. Se reemplaza sólo si incluís el juego y confirmás el reemplazo.';

  @override
  String get bulkIssueExternalReplacementBlocked =>
      'Este juego ya tiene otro match externo para el proveedor. Elegí Revisar y reemplazar para permitir el reemplazo.';

  @override
  String get bulkIssueExistingCover => 'Ya hay una portada seleccionada.';

  @override
  String get bulkIssueReplacementAvailable =>
      'Hay un reemplazo de portada disponible.';

  @override
  String get bulkIssueNoCover => 'No se encontró una portada aplicable.';

  @override
  String get bulkIssueReviewRequired =>
      'Revisá este elemento antes de aplicar cambios.';

  @override
  String get bulkMatchReasonExistingExternalId => 'ID externo existente';

  @override
  String get bulkMatchReasonExactTitle => 'título exacto';

  @override
  String get bulkMatchReasonSimilarTitle => 'título parecido';

  @override
  String get bulkMatchReasonSameYear => 'mismo año';

  @override
  String get bulkMatchReasonNearbyYear => 'año cercano';

  @override
  String get bulkMatchReasonMatchingPlatform => 'plataforma coincidente';

  @override
  String get bulkMatchReasonFirstCandidate => 'primer candidato';

  @override
  String get bulkMatchReasonOther => 'coincidencia del proveedor';

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
  String get gamePlayedPlatform => 'Jugado en';

  @override
  String get gameHoursInvalid => 'Ingresá un número mayor o igual a cero.';

  @override
  String get logPreviousYear => 'Año anterior';

  @override
  String get logNextYear => 'Año siguiente';

  @override
  String get logUnknownYear => 'Sin año';

  @override
  String get logPlayedYear => 'Año jugado (opcional)';

  @override
  String get logInvalidYear => 'Ingresá un año entre 1 y 9999.';

  @override
  String get logAddGame => 'Agregar juego';

  @override
  String get logEmptyYear => 'Todavía no hay juegos acá';

  @override
  String get logEmptyYearHint =>
      'Agregá un juego o elegí otro año. Los registros sin fecha están en Sin año.';

  @override
  String get logNoSearchResults => 'No encontramos ese juego';

  @override
  String get logSearchHint => 'Probá con otro título o elegí otro año.';

  @override
  String get statisticsFinished => 'Terminados';

  @override
  String get statisticsUnavailable => 'Sin datos';

  @override
  String get statisticsEmptyYear => 'Sin juegos en este año';

  @override
  String get statisticsEmptyYearHint =>
      'Los juegos sin año siguen disponibles en Juegos → Sin año.';

  @override
  String get statisticsFavorites => 'Favoritos';

  @override
  String get statisticsNoRatedGames =>
      'Todavía no hay juegos con puntaje en este año.';

  @override
  String get statisticsPlayedPlatforms => 'Dónde jugué';

  @override
  String get statisticsPlayedPlatformsHint =>
      'Juegos por plataforma jugada registrada.';

  @override
  String get statisticsNoPlayedPlatforms =>
      'Todavía no hay plataformas jugadas registradas en este año.';

  @override
  String get columnTitle => 'Título';
}
