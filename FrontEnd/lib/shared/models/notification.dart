class AppNotification {
  const AppNotification({
    required this.id,
    this.type,
    this.title,
    this.body,
    this.dataPayload,
    this.isRead = false,
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String? type;
  final String? title;
  final String? body;
  final String? dataPayload;
  final bool isRead;
  final String? readAt;
  final String? createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      dataPayload: json['data'] as String?,
      isRead: json['read'] as bool? ?? false,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'data': dataPayload,
    };
  }
}
