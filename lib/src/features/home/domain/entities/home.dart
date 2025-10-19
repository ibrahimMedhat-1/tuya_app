import 'package:equatable/equatable.dart';

class HomeEntity extends Equatable {
  final int homeId;
  final String name;

  const HomeEntity({
    required this.homeId,
    required this.name,
  });

  @override
  List<Object?> get props => [homeId, name];
}
