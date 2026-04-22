import 'package:sajadah/domain/entities/event/event.dart';

abstract class NewsEventState {}

class NewsEventLoading extends NewsEventState {}

class NewsEventLoaded extends NewsEventState {
  final List<EventEntity> events;

  NewsEventLoaded({required this.events});
}

class NewsEventsFailure extends NewsEventState{}