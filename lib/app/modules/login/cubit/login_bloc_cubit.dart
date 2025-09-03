import 'package:bloc/bloc.dart';

import '../../../repositories/login/login_repository.dart';
import 'login_bloc_state.dart';

class LoginBlocCubit extends Cubit<LoginBlocState> {
  final LoginRepository loginRepository;
  LoginBlocCubit({required this.loginRepository})
    : super(LoginBlocState.initial());

  Future<void> checkUrl() async {
    try {
      emit(state.copyWith(status: LoginStateStatus.loading));
      final loginValidation = await loginRepository.checkUrl();
    } on Exception {
      emit(
        state.copyWith(
          status: LoginStateStatus.error,
          errorMessage: "Erro ao efetuar Login",
        ),
      );
    }
  }

  Future<void> login(String login, String password) async {
    try {
      emit(state.copyWith(status: LoginStateStatus.loading));
      final loginValidation = await loginRepository.login(login, password);
      if (loginValidation.validado == 'T' && login != "" && password != "") {
        emit(state.copyWith(status: LoginStateStatus.success));
      } else {
        emit(
          state.copyWith(
            status: LoginStateStatus.error,
            errorMessage: 'Usuário ou senha incorretos',
          ),
        );
      }
    } on Exception {
      emit(
        state.copyWith(
          status: LoginStateStatus.error,
          errorMessage: "Erro ao efetuar Login",
        ),
      );
    }
  }
}
