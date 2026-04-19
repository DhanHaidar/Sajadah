import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/data/models/auth/signin_user_req.dart';
import 'package:sajadah/domain/repository/auth/auth.dart';
import 'package:sajadah/service_locator.dart';

class SigninUseCase implements UseCase<Either, SigninUserReq> {
  @override
  Future<Either> call({SigninUserReq? params}) async {
    return await sl<AuthRepository>().signin(params!);
  }
}
