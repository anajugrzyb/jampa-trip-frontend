import 'user_model.dart';

class AuthResponse {
  final String message;
  final String type;
  final UserModel data;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  AuthResponse({
    required this.message,
    required this.type,
    required this.data,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? '',
      type: json['type'] ?? 'client',
      data: UserModel.fromJson(json['data'] ?? {}),
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type,
      'data': data.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }

  @override
  String toString() {
    return 'AuthResponse(message: $message, type: $type, data: $data)';
  }
}
