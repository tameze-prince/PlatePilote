/// Modèle représentant une notification de l'application.
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

  /// Identifiant unique de la notification.
  final String id;
  /// Type de notification (pantry, budget, mealPlan, etc.).
  final String? type;
  /// Titre de la notification.
  final String? title;
  /// Corps du message.
  final String? body;
  /// Payload de données supplémentaires.
  final String? dataPayload;
  /// Indique si la notification a été lue.
  final bool isRead;
  /// Date de lecture.
  final String? readAt;
  /// Date de création.
  final String? createdAt;

  /// Crée une [AppNotification] depuis une map JSON.
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

  /// Retourne une copie avec les champs modifiés.
  AppNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? dataPayload,
    bool? isRead,
    String? readAt,
    String? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      dataPayload: dataPayload ?? this.dataPayload,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convertit cette [AppNotification] en map JSON.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'data': dataPayload,
    };
  }
}
