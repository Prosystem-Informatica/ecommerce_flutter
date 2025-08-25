
import 'model/login_model.dart';

abstract class ILoginRepository {
  Future<void> checkUrl();
  Future<LoginModel> login(String login, String password);
}
