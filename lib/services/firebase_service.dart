import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Users Collection
  static const String _usersCollection = 'users';
  static const String _lessonsCollection = 'lessons';
  static const String _enrollmentsCollection = 'enrollments';

  // Current user getter
  static User? get currentUser => _auth.currentUser;

  // User operations
  static Future<void> createUser(UserModel user) async {
    await _firestore.collection(_usersCollection).doc(user.uid).set(user.toMap());
  }

  static Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(_usersCollection).doc(uid).update(data);
  }

  static Future<void> deleteUser(String uid) async {
    await _firestore.collection(_usersCollection).doc(uid).delete();
  }

  // Get all users with specific role
  static Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: role.toString().split('.').last)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  // Lesson operations (for future use)
  static Future<void> createLesson(Map<String, dynamic> lessonData) async {
    await _firestore.collection(_lessonsCollection).add(lessonData);
  }

  static Future<List<Map<String, dynamic>>> getLessons() async {
    try {
      final querySnapshot = await _firestore.collection(_lessonsCollection).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting lessons: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getLessonsByTeacher(String teacherId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_lessonsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting lessons by teacher: $e');
      return [];
    }
  }

  // Enrollment operations (for future use)
  static Future<void> enrollStudent(String studentId, String lessonId) async {
    await _firestore.collection(_enrollmentsCollection).add({
      'studentId': studentId,
      'lessonId': lessonId,
      'enrolledAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<String>> getEnrolledLessons(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_enrollmentsCollection)
          .where('studentId', isEqualTo: studentId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['lessonId'] as String)
          .toList();
    } catch (e) {
      print('Error getting enrolled lessons: $e');
      return [];
    }
  }

  // Utility methods
  static Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  static Future<int> getUserCount() async {
    try {
      final querySnapshot = await _firestore.collection(_usersCollection).get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting user count: $e');
      return 0;
    }
  }

  static Future<int> getTeacherCount() async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'teacher')
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting teacher count: $e');
      return 0;
    }
  }

  static Future<int> getStudentCount() async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'student')
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting student count: $e');
      return 0;
    }
  }
}