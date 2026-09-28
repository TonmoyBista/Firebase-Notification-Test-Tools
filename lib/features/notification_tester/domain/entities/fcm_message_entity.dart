enum TargetType {
  token,
  topic,
  condition;

  String get label {
    switch (this) {
      case TargetType.token:
        return 'Device Token';
      case TargetType.topic:
        return 'Topic';
      case TargetType.condition:
        return 'Condition';
    }
  }
}

class FcmMessageEntity {
  final TargetType targetType;
  final String targetValue;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, String> data;
  final String androidPriority; // 'high' or 'normal'
  final int? apnsBadge;
  final String? apnsSound;
  final String? rawJsonOverride;

  const FcmMessageEntity({
    required this.targetType,
    required this.targetValue,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data = const {},
    this.androidPriority = 'high',
    this.apnsBadge,
    this.apnsSound = 'default',
    this.rawJsonOverride,
  });

  Map<String, dynamic> toFcmPayload() {
    if (rawJsonOverride != null && rawJsonOverride!.trim().isNotEmpty) {
      // If user is overriding with direct JSON, that JSON is used
      return {};
    }

    final Map<String, dynamic> message = {};

    switch (targetType) {
      case TargetType.token:
        message['token'] = targetValue.trim();
        break;
      case TargetType.topic:
        message['topic'] = targetValue.trim().replaceAll('^/topics/', '');
        break;
      case TargetType.condition:
        message['condition'] = targetValue.trim();
        break;
    }

    if (title.isNotEmpty || body.isNotEmpty || (imageUrl != null && imageUrl!.isNotEmpty)) {
      final Map<String, dynamic> notification = {};
      if (title.isNotEmpty) notification['title'] = title;
      if (body.isNotEmpty) notification['body'] = body;
      if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
        notification['image'] = imageUrl!.trim();
      }
      message['notification'] = notification;
    }

    if (data.isNotEmpty) {
      message['data'] = data;
    }

    message['android'] = {
      'priority': androidPriority,
      'notification': {
        'sound': 'default',
        'default_sound': true,
        'default_vibrate_timings': true,
      }
    };

    final Map<String, dynamic> aps = {
      'sound': apnsSound ?? 'default',
    };
    if (apnsBadge != null) {
      aps['badge'] = apnsBadge;
    }

    message['apns'] = {
      'payload': {
        'aps': aps,
      }
    };

    return {'message': message};
  }

  FcmMessageEntity copyWith({
    TargetType? targetType,
    String? targetValue,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, String>? data,
    String? androidPriority,
    int? apnsBadge,
    String? apnsSound,
    String? rawJsonOverride,
  }) {
    return FcmMessageEntity(
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      androidPriority: androidPriority ?? this.androidPriority,
      apnsBadge: apnsBadge ?? this.apnsBadge,
      apnsSound: apnsSound ?? this.apnsSound,
      rawJsonOverride: rawJsonOverride ?? this.rawJsonOverride,
    );
  }
}
