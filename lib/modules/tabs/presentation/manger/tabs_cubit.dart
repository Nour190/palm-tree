import 'package:baseqat/modules/tabs/presentation/manger/tabs_states.dart';
import 'package:bloc/bloc.dart';

class TabsCubit extends Cubit<TabsState> {
  TabsCubit() : super(const TabsInitial());

  int selectedIndex = 0;
  int selectedSubIndex = 0;

  void changeSelectedIndex(int i ) {
    selectedIndex = i;
    selectedSubIndex = 0;

    // reset child
    emit(SelectedIndexChanged(selectedIndex));
  }

  void changeSelectedSubIndex(int i) {
    selectedSubIndex = i;
    emit(SelectedSubIndexChanged(selectedSubIndex));
  }
}
