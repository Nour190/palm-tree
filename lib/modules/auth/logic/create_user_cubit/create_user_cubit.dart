import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_model.dart';
import '../../data/repos/auth_repo.dart';
import 'create_user_states.dart';

class CreateUserCubit extends Cubit<CreateUserStates> {
  final AuthRepo authRepo;
  CreateUserCubit(this.authRepo) : super(CreateUserInitialState());

  Future<void> createUser(UserModel userModel) async {
    final result = await authRepo.createUser(userModel);
    result.fold(
      (failure) => emit(CreateUserErrorState(failure.errorMessage)),
      (unit) => emit(CreateUserSuccessState()),
    );
  }
}
