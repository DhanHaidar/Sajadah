import 'package:get_it/get_it.dart';
import 'package:sajadah/data/repository/auth/auth_repository_impl.dart';
import 'package:sajadah/data/repository/event/event_repository_impl.dart';
import 'package:sajadah/data/repository/jamaah/jamaah_repository_impl.dart';
import 'package:sajadah/data/repository/masjid/masjid_repository_impl.dart'; // Import untuk Payment
import 'package:sajadah/data/repository/payment/payment_impl.dart';

import 'package:sajadah/data/sources/auth/auth_firebase_service.dart';
import 'package:sajadah/data/sources/event/event_firebase_service.dart';
import 'package:sajadah/data/sources/jamaah/jamaah_firebase_service.dart';
import 'package:sajadah/data/sources/masjid/masjid_firebase_service.dart'; // Import untuk Payment
import 'package:sajadah/data/sources/payment/payment_remote_source.dart';

import 'package:sajadah/domain/repository/auth/auth.dart';
import 'package:sajadah/domain/repository/event/event.dart';
import 'package:sajadah/domain/repository/jamaah/jamaah.dart';
import 'package:sajadah/domain/repository/masjid/masjid.dart'; // Import untuk Payment
import 'package:sajadah/domain/repository/payment/payment.dart';
import 'package:sajadah/domain/usecases/payment/check_payment_status.dart';

import 'package:sajadah/domain/usecases/auth/signin.dart';
import 'package:sajadah/domain/usecases/auth/signup.dart';
import 'package:sajadah/domain/usecases/event/create_event.dart';
import 'package:sajadah/domain/usecases/event/get_news_events.dart';
import 'package:sajadah/domain/usecases/event/get_events_by_masjid.dart';
import 'package:sajadah/domain/usecases/event/create_event_for_masjid.dart';
import 'package:sajadah/domain/usecases/jamaah/create_jamaah.dart';
import 'package:sajadah/domain/usecases/jamaah/get_jamaah.dart';
import 'package:sajadah/domain/usecases/jamaah/update_jamaah.dart';
import 'package:sajadah/domain/usecases/jamaah/delete_jamaah.dart';
import 'package:sajadah/domain/usecases/masjid/create_masjid.dart';
import 'package:sajadah/domain/usecases/masjid/get_news_masjid.dart'; // Import untuk Payment
import 'package:sajadah/domain/usecases/payment/create_payment.dart';

final sl = GetIt.instance;

Future<void> intializeDependencies() async {
  // Register your dependencies here
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  sl.registerSingleton<EventFirebaseService>(EventFirebaseServiceImpl());
  sl.registerSingleton<MasjidFirebaseService>(MasjidFirebaseServiceImpl());
  sl.registerSingleton<JamaahFirebaseService>(JamaahFirebaseServiceImpl());
  sl.registerSingleton<PaymentRemoteSource>(PaymentRemoteSourceImpl());

  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  sl.registerSingleton<EventRepository>(EventRepositoryImpl());
  sl.registerSingleton<MasjidRepository>(MasjidRepositoryImpl());
  sl.registerSingleton<JamaahRepository>(JamaahRepositoryImpl());
  sl.registerSingleton<PaymentRepository>(
    PaymentRepositoryImpl(remoteSource: sl()),
  );

  sl.registerSingleton<SignupUseCase>(SignupUseCase());
  sl.registerSingleton<SigninUseCase>(SigninUseCase());
  sl.registerSingleton<GetNewsEventsUseCase>(GetNewsEventsUseCase());
  sl.registerSingleton<CreateEventUseCase>(CreateEventUseCase());
  sl.registerSingleton<GetEventsByMasjidUseCase>(GetEventsByMasjidUseCase());
  sl.registerSingleton<CreateEventForMasjidUseCase>(
    CreateEventForMasjidUseCase(),
  );
  sl.registerSingleton<GetJamaahsByMasjidUseCase>(GetJamaahsByMasjidUseCase());
  sl.registerSingleton<UpdateJamaahUseCase>(UpdateJamaahUseCase());
  sl.registerSingleton<DeleteJamaahUseCase>(DeleteJamaahUseCase());

  sl.registerSingleton<GetNewsMasjidsUseCase>(GetNewsMasjidsUseCase());
  sl.registerSingleton<CreateMasjidUseCase>(CreateMasjidUseCase());
  sl.registerSingleton<CreateJamaahUseCase>(CreateJamaahUseCase());
  sl.registerSingleton<CheckPaymentStatusUseCase>(
    CheckPaymentStatusUseCase(sl()),
  );
  sl.registerSingleton<CreatePaymentUseCase>(CreatePaymentUseCase(sl()));
}
