import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'favorite_genres')
  final List<int> favoriteGenres;
  @JsonKey(name: 'preference_profile')
  final Map<String, dynamic> preferenceProfile;

  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.updatedAt,
    required this.favoriteGenres,
    required this.preferenceProfile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => 
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<int>? favoriteGenres,
    Map<String, dynamic>? preferenceProfile,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      preferenceProfile: preferenceProfile ?? this.preferenceProfile,
    );
  }
}