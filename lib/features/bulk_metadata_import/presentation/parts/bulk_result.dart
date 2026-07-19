part of '../bulk_metadata_import_page.dart';

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({
    required this.plan,
    required this.applying,
    required this.onApply,
  });

  final BulkMetadataImportPlan plan;
  final bool applying;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return BvWizardStep(
      step: context.l10n.stepThree,
      title: context.l10n.bulkFinalConfirmation,
      subtitle: context.l10n.bulkFinalConfirmationDescription,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              context.l10n.bulkFinalSummary(
                plan.selectedItems,
                plan.selectedNewFieldChanges,
                plan.selectedReplacementFieldChanges,
                plan.selectedNewCovers,
                plan.selectedReplacementCovers,
              ),
            ),
          ),
          BvAsyncActionButton(
            label: context.l10n.bulkApplyChanges,
            icon: Icons.check,
            onPressed: plan.selectedItems == 0 ? null : onApply,
            busy: applying,
            busyLabel: context.l10n.loading,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.onNewPreview,
    required this.onBackToLibrary,
  });

  final BulkImportResult result;
  final VoidCallback onNewPreview;
  final VoidCallback onBackToLibrary;

  @override
  Widget build(BuildContext context) {
    return BvWizardStep(
      step: context.l10n.csvResult,
      title: context.l10n.bulkResultTitle,
      subtitle: context.l10n.bulkResultDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: BvSpacing.xs,
            runSpacing: BvSpacing.xs,
            children: [
              _chip(context.l10n.bulkAnalyzed, result.analyzed.toString()),
              _chip(context.l10n.bulkWithMatch, result.matched.toString()),
              _chip(
                context.l10n.bulkWithoutMatch,
                result.withoutMatch.toString(),
              ),
              _chip(context.l10n.bulkSafe, result.safeMatches.toString()),
              _chip(
                context.l10n.bulkProbable,
                result.probableMatches.toString(),
              ),
              _chip(
                context.l10n.bulkAmbiguous,
                result.ambiguousMatches.toString(),
              ),
              _chip(context.l10n.bulkProcessed, result.processed.toString()),
              _chip(
                context.l10n.bulkNewMetadata,
                result.newFieldChangesApplied.toString(),
              ),
              _chip(
                context.l10n.bulkReplacedMetadata,
                result.replacedFieldChangesApplied.toString(),
              ),
              _chip(
                context.l10n.bulkLinks,
                result.externalLinksSaved.toString(),
              ),
              _chip(
                context.l10n.bulkNewCovers,
                result.newCoversSaved.toString(),
              ),
              _chip(
                context.l10n.bulkReplacedCovers,
                result.replacedCoversSaved.toString(),
              ),
              _chip(context.l10n.bulkSkipped, result.skipped.toString()),
              _chip(context.l10n.warnings, result.warnings.length.toString()),
              _chip(context.l10n.errors, result.errors.length.toString()),
            ],
          ),
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: BvSpacing.md),
            Text(
              context.l10n.warnings,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (final warning in result.warnings)
              Text(_localizedBulkIssue(context, warning)),
          ],
          if (result.errors.isNotEmpty) ...[
            const SizedBox(height: BvSpacing.md),
            Text(
              context.l10n.errors,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (final error in result.errors)
              Text(_localizedBulkIssue(context, error)),
          ],
          const SizedBox(height: BvSpacing.md),
          Wrap(
            spacing: BvSpacing.xs,
            runSpacing: BvSpacing.xs,
            children: [
              FilledButton.icon(
                onPressed: onBackToLibrary,
                icon: const Icon(Icons.library_books_outlined),
                label: Text(context.l10n.csvBackToLibrary),
              ),
              OutlinedButton.icon(
                onPressed: onNewPreview,
                icon: const Icon(Icons.manage_search_outlined),
                label: Text(context.l10n.bulkNewPreview),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    return BvChip(label: '$label: $value');
  }
}

String _localizedBulkIssue(BuildContext context, BulkImportIssue issue) {
  final raw = issue.message;
  final message = switch (raw) {
    'El proveedor no devolvió candidatos.' =>
      context.l10n.bulkIssueNoCandidates,
    'Match probable: revisar antes de aplicar.' =>
      context.l10n.bulkIssueProbableMatch,
    'Match ambiguo: requiere revisión manual.' =>
      context.l10n.bulkIssueAmbiguousMatch,
    'Este juego ya tiene otro match externo para el proveedor. Se reemplaza solo si incluís este juego y confirmás REEMPLAZAR.' =>
      context.l10n.bulkIssueExternalReplacementAllowed,
    'Este juego ya tiene otro match externo para el proveedor. Cambiá a Revisar y reemplazar para permitir el reemplazo.' =>
      context.l10n.bulkIssueExternalReplacementBlocked,
    'Ya tiene portada seleccionada.' => context.l10n.bulkIssueExistingCover,
    'Reemplazo disponible.' => context.l10n.bulkIssueReplacementAvailable,
    'No se encontró portada aplicable.' => context.l10n.bulkIssueNoCover,
    _ when issue.severity == BulkImportIssueSeverity.error =>
      context.l10n.bulkOperationFailed,
    _ when issue.severity == BulkImportIssueSeverity.info =>
      context.l10n.bulkIssueNoCover,
    _ => context.l10n.bulkIssueReviewRequired,
  };
  final contextParts = [
    if (issue.isGlobal) context.l10n.bulkGlobalIssue,
    if (issue.gameTitle?.trim().isNotEmpty == true) issue.gameTitle!.trim(),
    if (issue.providerName?.trim().isNotEmpty == true)
      issue.providerName!.trim()
    else if (issue.providerId?.trim().isNotEmpty == true)
      issue.providerId!.trim(),
    message,
  ];
  return contextParts.join(' · ');
}

String _localizedBulkMatchReason(BuildContext context, String reason) {
  return switch (reason) {
    'external ID existente' => context.l10n.bulkMatchReasonExistingExternalId,
    'título exacto' => context.l10n.bulkMatchReasonExactTitle,
    'título parecido' => context.l10n.bulkMatchReasonSimilarTitle,
    'mismo año' => context.l10n.bulkMatchReasonSameYear,
    'año cercano' => context.l10n.bulkMatchReasonNearbyYear,
    'plataforma coincidente' => context.l10n.bulkMatchReasonMatchingPlatform,
    'primer candidato' => context.l10n.bulkMatchReasonFirstCandidate,
    _ => context.l10n.bulkMatchReasonOther,
  };
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return BvStatusBanner(
      title: context.l10n.cannotContinue,
      tone: BvBannerTone.danger,
      message: message,
    );
  }
}
