import 'package:dartz/dartz.dart';
import 'package:sajadah/core/usecase/usecase.dart';
import 'package:sajadah/domain/repository/event/event.dart';
import 'package:sajadah/service_locator.dart';

class GetNewsEventsUseCase implements UseCase<Either, dynamic> {
  @override
  Future<Either<dynamic, dynamic>> call({params}) async {
    return await sl<EventRepository>().getAllEvents();
  }
}
