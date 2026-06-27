import 'package:equatable/equatable.dart';

abstract class StoresEvent extends Equatable {
  const StoresEvent();

  @override
  List<Object?> get props => [];
}

class StoresLoadRequested extends StoresEvent {
  const StoresLoadRequested({this.countryCode});

  final String? countryCode;

  @override
  List<Object?> get props => [countryCode];
}
