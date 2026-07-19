/// Catalog value exposed outside persistence.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.name,
    this.shortName,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String? shortName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
}
