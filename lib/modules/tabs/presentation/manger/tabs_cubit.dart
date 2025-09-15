import 'package:baseqat/modules/tabs/presentation/manger/tabs_states.dart';
import 'package:bloc/bloc.dart';

class TabsCubit extends Cubit<TabsState> {
  TabsCubit() : super(const TabsState());

  void selectTop(int i) => emit(state.copyWith(topIndex: i, tabIndex: 0));
  void selectTab(int i) => emit(state.copyWith(tabIndex: i));
}
