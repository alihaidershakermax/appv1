import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return await repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}