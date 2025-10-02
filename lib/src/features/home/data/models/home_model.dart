import '../../domain/entities/home.dart';

class HomeModel {
  final int homeId;
  final String name;

  const HomeModel({required this.homeId, required this.name});

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      homeId: (json['homeId'] ?? json['home_id'] ?? json['id']) as int,
      name: (json['name'] ?? json['homeName'] ?? '') as String,
    );
  }

  HomeEntity toEntity() => HomeEntity(homeId: homeId, name: name);
}


