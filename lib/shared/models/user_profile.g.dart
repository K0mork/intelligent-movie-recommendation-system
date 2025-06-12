// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  photoURL: json['photoURL'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  favoriteGenres:
      (json['favorite_genres'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
  preferenceProfile: json['preference_profile'] as Map<String, dynamic>,
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'favorite_genres': instance.favoriteGenres,
      'preference_profile': instance.preferenceProfile,
    };
