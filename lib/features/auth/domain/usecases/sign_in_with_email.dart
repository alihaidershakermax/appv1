import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmail {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    return await repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}