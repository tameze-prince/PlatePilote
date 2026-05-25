import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/repositories/base_repository.dart';
import '../../shared/models/notification.dart';

class NotificationRepository extends BaseRepository {
  NotificationRepository(super.apiClient);

  Future<PageResponse<AppNotification>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/notifications',
        query: {'page': page, 'size': size},
      );
      return handlePageResponse(response, AppNotification.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await apiClient.get('/notifications/unread/count');
      final data = response.data;
      if (data is Map && data['data'] != null) {
        return (data['data'] as num).toInt();
      }
      return 0;
    } on DioException {
      return 0;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await apiClient.patch('/notifications/$notificationId/read');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await apiClient.patch('/notifications/read-all');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      await apiClient.delete('/notifications/$notificationId');
      return true;
    } on DioException {
      return false;
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});
