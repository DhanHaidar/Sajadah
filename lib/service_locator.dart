import 'package:get_it/get_it.dart';
import 'package:sajadah/data/repository/auth/auth_repository_impl.dart';
import 'package:sajadah/data/repository/event/event_repository_impl.dart';
import 'package:sajadah/data/sources/auth/auth_firebase_service.dart';
import 'package:sajadah/data/sources/event/event_firebase_service.dart';
import 'package:sajadah/domain/repository/auth/auth.dart';
import 'package:sajadah/domain/repository/event/event.dart';
import 'package:sajadah/domain/usecases/auth/signin.dart';
import 'package:sajadah/domain/usecases/auth/signup.dart';
import 'package:sajadah/domain/usecases/event/create_event.dart';
import 'package:sajadah/domain/usecases/event/get_news_events.dart';

final sl = GetIt.instance;

Future<void> intializeDependencies() async {
  // Register your dependencies here
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  sl.registerSingleton<EventFirebaseService>(EventFirebaseServiceImpl());

  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  sl.registerSingleton<EventRepository>(EventRepositoryImpl());

  sl.registerSingleton<SignupUseCase>(SignupUseCase());
  sl.registerSingleton<SigninUseCase>(SigninUseCase());
  sl.registerSingleton<GetNewsEventsUseCase>(GetNewsEventsUseCase());
  sl.registerSingleton<CreateEventUseCase>(CreateEventUseCase());
  // Name-related services removed (not used for greeting in _homeTopCard)
}
