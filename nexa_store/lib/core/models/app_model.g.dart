// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppModel _$AppModelFromJson(Map<String, dynamic> json) => AppModel(
      appId: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      packageName: json['package_name'] as String?,
      version: json['version'] as String,
      size: (json['size'] as num?)?.toInt(),
      downloadUrl: json['download_url'] as String?,
      sha256Checksum: json['sha256'] as String?,
      patchUrl: json['patch_url'] as String?,
      patchSha256: json['patch_sha256'] as String?,
      category: json['category'] as String?,
      screenshots: (json['screenshots'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      downloadsCount: (json['downloads_count'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AppModelToJson(AppModel instance) => <String, dynamic>{
      'id': instance.appId,
      'name': instance.name,
      'description': instance.description,
      'icon_url': instance.iconUrl,
      'package_name': instance.packageName,
      'version': instance.version,
      'size': instance.size,
      'download_url': instance.downloadUrl,
      'sha256': instance.sha256Checksum,
      'patch_url': instance.patchUrl,
      'patch_sha256': instance.patchSha256,
      'category': instance.category,
      'screenshots': instance.screenshots,
      'downloads_count': instance.downloadsCount,
      'rating': instance.rating,
    };
