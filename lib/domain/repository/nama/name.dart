import 'package:dartz/dartz.dart';

abstract class NameRepository {
  Future<Either> getName();
}
