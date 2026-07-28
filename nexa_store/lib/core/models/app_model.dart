import 'package:json_annotation/json_annotation.dart';

part 'app_model.g.dart';

@JsonSerializable()
class AppModel {
  @JsonKey(name: 'id') // نستقبلها من JSON كـ id
  final String? appId; // ونخزنها في Dart كـ appId

  final String name;
  final String? description;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  @JsonKey(name: 'package_name')
  final String? packageName;
  final String version;
  final int? size;
  @JsonKey(name: 'download_url')
  final String? downloadUrl;
  @JsonKey(name: 'sha256')
  final String? sha256Checksum;
  @JsonKey(name: 'patch_url')
  final String? patchUrl;
  @JsonKey(name: 'patch_sha256')
  final String? patchSha256;
  final String? category;
  final List<String>? screenshots;
  @JsonKey(name: 'downloads_count')
  final int? downloadsCount;
  final double? rating;

  AppModel({
    this.appId, // تم التعديل هنا
    required this.name,
    this.description,
    this.iconUrl,
    this.packageName,
    required this.version,
    this.size,
    this.downloadUrl,
    this.sha256Checksum,
    this.patchUrl,
    this.patchSha256,
    this.category,
    this.screenshots,
    this.downloadsCount,
    this.rating,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) =>
      _$AppModelFromJson(json);
  Map<String, dynamic> toJson() => _$AppModelToJson(this);
}
