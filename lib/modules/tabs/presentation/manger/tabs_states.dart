class TabsState {
  final int topIndex; // TopBar selected index
  final int tabIndex; // TabBar selected index within current section

  const TabsState({this.topIndex = 0, this.tabIndex = 0});

  TabsState copyWith({int? topIndex, int? tabIndex}) => TabsState(
    topIndex: topIndex ?? this.topIndex,
    tabIndex: tabIndex ?? this.tabIndex,
  );
}
