part of '../import_notion_csv_page.dart';

class _ImportResultStep extends StatelessWidget {
  const _ImportResultStep({
    required this.result,
    required this.onBackToLibrary,
  });

  final ImportResult result;
  final VoidCallback onBackToLibrary;

  @override
  Widget build(BuildContext context) {
    return BvWizardStep(
      step: context.l10n.stepFour,
      title: context.l10n.csvResult,
      subtitle: context.l10n.csvResultDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: BvSpacing.xs,
            runSpacing: BvSpacing.xs,
            children: [
              BvChip(
                label: context.l10n.csvImported(result.importedGames),
                selected: true,
              ),
              BvChip(label: context.l10n.csvSkipped(result.skippedRows)),
              BvChip(
                label: context.l10n.csvDuplicateSkipped(
                  result.duplicatesSkipped,
                ),
              ),
              BvChip(
                label: context.l10n.csvPlatformsCreated(
                  result.platformsCreated,
                ),
              ),
              BvChip(
                label: context.l10n.csvGenresCreated(result.genresCreated),
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          FilledButton.icon(
            onPressed: onBackToLibrary,
            icon: const Icon(Icons.library_books_outlined),
            label: Text(context.l10n.csvBackToLibrary),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return BvStatusBanner(
      tone: BvBannerTone.danger,
      title: context.l10n.cannotContinue,
      message: message,
    );
  }
}
