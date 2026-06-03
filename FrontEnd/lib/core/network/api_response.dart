/// Réponse générique de l'API encapsulant le succès, le message, les données et l'horodatage.
class ApiResponse<T> {
  /// Crée une [ApiResponse] avec les champs requis.
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  /// Indique si la requête a réussi.
  final bool success;

  /// Message optionnel de l'API (ex: message d'erreur).
  final String? message;

  /// Données typées renvoyées par l'API.
  final T? data;

  /// Horodatage de la réponse.
  final String? timestamp;

  /// Construit une [ApiResponse] à partir d'un JSON avec un mapping objet unique.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromData,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromData != null
          ? fromData(json['data'] as Map<String, dynamic>)
          : null,
      timestamp: json['timestamp'] as String?,
    );
  }

  /// Construit une [ApiResponse] à partir d'un JSON avec un mapping de liste.
  factory ApiResponse.fromJsonList(
    Map<String, dynamic> json,
    T Function(List<dynamic>) fromDataList,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null
          ? fromDataList(json['data'] as List<dynamic>)
          : null,
      timestamp: json['timestamp'] as String?,
    );
  }
}

/// Réponse paginée générique de l'API contenant la liste des éléments et les métadonnées de pagination.
class PageResponse<T> {
  /// Crée une [PageResponse] avec les champs de pagination requis.
  const PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  /// Liste des éléments de la page courante.
  final List<T> content;

  /// Numéro de la page courante (indexé à 0).
  final int page;

  /// Nombre d'éléments par page.
  final int size;

  /// Nombre total d'éléments sur toutes les pages.
  final int totalElements;

  /// Nombre total de pages.
  final int totalPages;

  /// Indique s'il s'agit de la dernière page.
  final bool last;

  /// Construit une [PageResponse] à partir d'un JSON de réponse paginée.
  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawContent = json['content'];
    final contentList = rawContent is List
        ? rawContent
            .map((e) => fromItem(e as Map<String, dynamic>))
            .toList()
        : <T>[];

    return PageResponse(
      content: contentList,
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 20,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }
}
