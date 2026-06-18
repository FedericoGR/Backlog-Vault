class BvBreakpoints {
  const BvBreakpoints._();

  static const double mobile = 600;
  static const double navigationRail = 840;
  static const double libraryWide = 900;
  static const double detailWide = 920;
  static const double desktop = 1200;

  static bool isCompact(double width) => width < mobile;
  static bool usesNavigationRail(double width) => width >= navigationRail;
  static bool isDesktop(double width) => width >= desktop;
}
