/// Width thresholds based on available layout space, never platform identity.
class BvBreakpoints {
  const BvBreakpoints._();

  static const double mobile = 600;
  static const double navigationRail = 840;
  static const double libraryWide = 900;
  static const double detailWide = 920;
  static const double desktop = 1200;

  /// Whether a surface should use its narrow, single-column composition.
  static bool isCompact(double width) => width < mobile;

  /// Whether primary app navigation has room for a labeled rail.
  static bool usesNavigationRail(double width) => width >= navigationRail;

  /// Whether a surface has room for its widest desktop composition.
  static bool isDesktop(double width) => width >= desktop;
}
