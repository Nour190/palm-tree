/// States
abstract class TabsState {
  const TabsState();
}

class TabsInitial extends TabsState {
  const TabsInitial();
}

class SelectedIndexChanged extends TabsState {
  final int selectedIndex;
  const SelectedIndexChanged(this.selectedIndex);
}

class SelectedSubIndexChanged extends TabsState {
  final int selectedSubIndex;
  const SelectedSubIndexChanged(this.selectedSubIndex);
}
