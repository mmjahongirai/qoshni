import 'package:qoshni/features/auth/domain/auth_failure.dart';

class OtpChallengeCreateRequestDto {
  const OtpChallengeCreateRequestDto({
    required this.phone,
    this.purpose = 'sign_in',
  });

  final String phone;
  final String purpose;

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'purpose': purpose,
      };
}

class OtpChallengeCreatedDto {
  OtpChallengeCreatedDto({
    required this.challengeId,
    required this.expiresAt,
    required this.codeLength,
  });

  factory OtpChallengeCreatedDto.fromJson(Map<String, dynamic> json) {
    return OtpChallengeCreatedDto(
      challengeId: json['challenge_id'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      codeLength: json['code_length'] as int,
    );
  }

  final String challengeId;
  final DateTime expiresAt;
  final int codeLength;
}

class OtpChallengeVerifyRequestDto {
  const OtpChallengeVerifyRequestDto({
    required this.challengeId,
    required this.code,
  });

  final String challengeId;
  final String code;

  Map<String, dynamic> toJson() => {
        'challenge_id': challengeId,
        'code': code,
      };
}

class SessionRefreshRequestDto {
  const SessionRefreshRequestDto({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}

class SessionViewDto {
  SessionViewDto({
    required this.sessionId,
    required this.state,
    required this.createdAt,
    required this.expiresAt,
    this.lastSeenAt,
    this.revokedAt,
    this.deviceLabel,
    this.devicePlatform,
    required this.isCurrent,
  });

  factory SessionViewDto.fromJson(Map<String, dynamic> json) {
    return SessionViewDto(
      sessionId: json['session_id'] as String,
      state: json['state'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      lastSeenAt: json['last_seen_at'] == null
          ? null
          : DateTime.parse(json['last_seen_at'] as String),
      revokedAt: json['revoked_at'] == null
          ? null
          : DateTime.parse(json['revoked_at'] as String),
      deviceLabel: json['device_label'] as String?,
      devicePlatform: json['device_platform'] as String?,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  final String sessionId;
  final String state;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? lastSeenAt;
  final DateTime? revokedAt;
  final String? deviceLabel;
  final String? devicePlatform;
  final bool isCurrent;
}

class SessionTokensDto {
  SessionTokensDto({
    required this.tokenType,
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.userId,
    required this.session,
  });

  factory SessionTokensDto.fromJson(Map<String, dynamic> json) {
    return SessionTokensDto(
      tokenType: json['token_type'] as String? ?? 'bearer',
      accessToken: json['access_token'] as String,
      accessTokenExpiresAt: DateTime.parse(json['access_token_expires_at'] as String),
      refreshToken: json['refresh_token'] as String,
      refreshTokenExpiresAt:
          DateTime.parse(json['refresh_token_expires_at'] as String),
      userId: json['user_id'] as String,
      session: SessionViewDto.fromJson(json['session'] as Map<String, dynamic>),
    );
  }

  final String tokenType;
  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final String userId;
  final SessionViewDto session;
}

class SessionListDto {
  SessionListDto({required this.sessions});

  factory SessionListDto.fromJson(Map<String, dynamic> json) {
    final list = json['sessions'] as List<dynamic>? ?? const [];
    return SessionListDto(
      sessions: list
          .map((e) => SessionViewDto.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final List<SessionViewDto> sessions;
}

class AuthErrorEnvelopeDto {
  AuthErrorEnvelopeDto({
    required this.code,
    required this.message,
    this.retryAfterSeconds,
    this.attemptsRemaining,
  });

  factory AuthErrorEnvelopeDto.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>;
    return AuthErrorEnvelopeDto(
      code: error['code'] as String,
      message: error['message'] as String,
      retryAfterSeconds: error['retry_after_seconds'] as int?,
      attemptsRemaining: error['attempts_remaining'] as int?,
    );
  }

  AuthFailure toFailure() {
    return AuthFailure(
      code: AuthErrorCode.tryParse(code) ?? AuthErrorCode.unknown,
      message: message,
      retryAfterSeconds: retryAfterSeconds,
      attemptsRemaining: attemptsRemaining,
    );
  }

  final String code;
  final String message;
  final int? retryAfterSeconds;
  final int? attemptsRemaining;
}
