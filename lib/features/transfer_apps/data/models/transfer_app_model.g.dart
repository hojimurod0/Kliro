// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_app_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferAppModel _$TransferAppModelFromJson(Map<String, dynamic> json) =>
    TransferAppModel(
      id: _intFromJson(json['id']),
      name: _stringFromJson(_readName(json, 'name')),
      bank: _stringFromJson(_readBank(json, 'bank')),
      commission: _stringOrNull(_readCommission(json, 'commission')),
      limit: _stringOrNull(_readLimit(json, 'limit')),
      speed: _stringOrNull(_readSpeed(json, 'speed')),
      tags: _readTags(json, 'tags') == null
          ? []
          : _stringListFromJson(_readTags(json, 'tags')),
      advantages: _readAdvantages(json, 'advantages') == null
          ? []
          : _stringListFromJson(_readAdvantages(json, 'advantages')),
      rating: _stringOrNull(_readRating(json, 'rating')),
      users: _stringOrNull(_readUsers(json, 'users')),
      channel: _stringOrNull(_readChannel(json, 'channel')),
      downloadUrl: _stringOrNull(_readDownloadUrl(json, 'download_url')),
      logo: _stringOrNull(_readLogo(json, 'logo')),
      description: _stringOrNull(_readDescription(json, 'description')),
      platforms: _readPlatforms(json, 'platforms') == null
          ? []
          : _stringListFromJson(_readPlatforms(json, 'platforms')),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TransferAppModelToJson(TransferAppModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bank': instance.bank,
      'commission': instance.commission,
      'limit': instance.limit,
      'speed': instance.speed,
      'tags': instance.tags,
      'advantages': instance.advantages,
      'rating': instance.rating,
      'users': instance.users,
      'channel': instance.channel,
      'download_url': instance.downloadUrl,
      'logo': instance.logo,
      'description': instance.description,
      'platforms': instance.platforms,
      'created_at': instance.createdAt?.toIso8601String(),
    };
