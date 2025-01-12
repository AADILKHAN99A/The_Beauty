part of 'internet_cubit.dart';

@immutable
sealed class InternetState {}

final class InternetLoadingState extends InternetState {}
final class InternetConnectedState extends InternetState {

  final ConnectionType connectionType;
  InternetConnectedState({required this.connectionType});
}

final class InternetDisconnectedState extends InternetState {}
