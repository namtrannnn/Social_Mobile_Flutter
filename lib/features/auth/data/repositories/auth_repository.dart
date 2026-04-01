import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository(this.remoteDataSource);

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) {
    final request = LoginRequestModel(email: email, password: password);
    return remoteDataSource.login(request);
  }

  Future<RegisterResponseModel> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    final request = RegisterRequestModel(
      fullName: fullName,
      email: email,
      password: password,
    );

    return remoteDataSource.register(request);
  }
}
