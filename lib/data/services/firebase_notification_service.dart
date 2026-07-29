// import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseNotificationService {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection name for storing read notifications
  static const String _collectionName = 'user_read_notifications';

  /// Mark a single notification as read for a specific user
  // Future<void> markNotificationAsRead(String userId, int notificationId) async {
  //   try {
  //     await _firestore
  //         .collection(_collectionName)
  //         .doc(userId)
  //         .set({
  //       'notificationIds': FieldValue.arrayUnion([notificationId]),
  //       'lastUpdated': FieldValue.serverTimestamp(),
  //     }, SetOptions(merge: true));
  //   } catch (e) {
  //     print('Error marking notification as read: $e');
  //     rethrow;
  //   }
  // }

  /// Mark all notifications as read for a specific user
  // Future<void> markAllNotificationsAsRead(String userId, List<int> notificationIds) async {
  //   try {
  //     await _firestore
  //         .collection(_collectionName)
  //         .doc(userId)
  //         .set({
  //       'notificationIds': notificationIds,
  //       'lastUpdated': FieldValue.serverTimestamp(),
  //     }, SetOptions(merge: true));
  //   } catch (e) {
  //     print('Error marking all notifications as read: $e');
  //     rethrow;
  //   }
  // }

  /// Get list of read notification IDs for a specific user
  // Future<List<int>> getReadNotifications(String userId) async {
  //   try {
  //     final doc = await _firestore
  //         .collection(_collectionName)
  //         .doc(userId)
  //         .get();
  //
  //     if (!doc.exists || doc.data() == null) {
  //       return [];
  //     }
  //
  //     final data = doc.data()!;
  //     final notificationIds = data['notificationIds'] as List<dynamic>?;
  //
  //     if (notificationIds == null) {
  //       return [];
  //     }
  //
  //     return notificationIds.cast<int>();
  //   } catch (e) {
  //     print('Error getting read notifications: $e');
  //     return [];
  //   }
  // }

  /// Clear all read notifications for a user (useful for logout)
  // Future<void> clearReadNotifications(String userId) async {
  //   try {
  //     await _firestore
  //         .collection(_collectionName)
  //         .doc(userId)
  //         .delete();
  //   } catch (e) {
  //     print('Error clearing read notifications: $e');
  //     rethrow;
  //   }
  // }
}
