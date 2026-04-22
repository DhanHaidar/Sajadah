// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sajadah/domain/usecases/event/get_news_events.dart';
// import 'package:sajadah/presentation/dashboard/bloc/news_event_state.dart';
// import 'package:sajadah/service_locator.dart';

// class NewsEventsCubit extends Cubit<NewsEventState> {
//   NewsEventsCubit() : super(NewsEventLoading());
//   Future<void> getNewsEvents() async {
//     var returnedEvents = await sl<GetNewsEventsUseCase>().call();
//     returnedEvents.fold(
//       (l) {
//         print('NewsEventsCubit.getNewsEvents failed: $l');
//         emit(NewsEventsFailure());
//       },
//       (data) {
//         print('NewsEventsCubit.getNewsEvents loaded ${data.length} events');
//         for (var e in data) {
//           print(
//             'EventEntity -> title: "${e.title}", deskripsi: "${e.deskripsi}", location: "${e.location}"',
//           );
//         }
//         emit(NewsEventLoaded(events: data));
//       },
//     );
//   }
// }
