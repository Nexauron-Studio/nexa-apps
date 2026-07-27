import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  String? userId;
  String? email;
  String? username;
  String? role; // 'user' or 'admin' or 'helper'
  @JsonKey(name: 'avatar_url')
  String? avatarUrl;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;

  UserModel({
    this.userId,
    this.email,
    this.username,
    this.role,
    this.avatarUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
