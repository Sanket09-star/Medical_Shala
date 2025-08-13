import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider for appointments
final appointmentsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    yield [];
    return;
  }

  // Listen to appointments collection for the current user
  yield* FirebaseFirestore.instance
      .collection('appointments')
      .where('doctorId', isEqualTo: user.uid)
      .orderBy('appointmentDate', descending: false)
      .orderBy('appointmentTime', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'avatar': data['avatar'] ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(data['patientName'] ?? 'Patient')}&background=EAF6FF&color=1976D2&rounded=true',
              'time': data['appointmentTime'] ?? '',
              'status': data['status'] ?? 'UPCOMING',
              'statusColor': _getStatusColor(data['status'] ?? 'UPCOMING'),
              'name': data['patientName'] ?? '',
              'patientId': data['patientId'] ?? '',
              'age': data['patientAge'] ?? 0,
              'gender': data['patientGender'] ?? '',
              'visited': data['visited'] ?? 'New',
              'statusTimeColor': _getStatusTimeColor(data['status'] ?? 'UPCOMING'),
              'reason': data['reason'] ?? '',
              'doctorName': data['doctorName'] ?? '',
              'hospitalName': data['hospitalName'] ?? '',
              'contactNumber': data['contactNumber'] ?? '',
              'appointmentDate': data['appointmentDate'] ?? '',
              'createdAt': data['createdAt'],
              'updatedAt': data['updatedAt'],
            };
          }).toList());
});

// Provider for appointment statistics
final appointmentStatsProvider = Provider<Map<String, int>>((ref) {
  final appointmentsAsync = ref.watch(appointmentsProvider);
  return appointmentsAsync.when(
    data: (appointments) {
      int total = appointments.length;
      int upcoming = appointments.where((apt) => apt['status'] == 'UPCOMING').length;
      int ongoing = appointments.where((apt) => apt['status'] == 'ONGOING').length;
      int completed = appointments.where((apt) => apt['status'] == 'COMPLETED').length;
      int missed = appointments.where((apt) => apt['status'] == 'MISSED').length;

      return {
        'total': total,
        'upcoming': upcoming,
        'ongoing': ongoing,
        'completed': completed,
        'missed': missed,
      };
    },
    loading: () => {'total': 0, 'upcoming': 0, 'ongoing': 0, 'completed': 0, 'missed': 0},
    error: (_, __) => {'total': 0, 'upcoming': 0, 'ongoing': 0, 'completed': 0, 'missed': 0},
  );
});

// Helper functions
Color _getStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'ONGOING':
      return const Color(0xFF22C55E);
    case 'UPCOMING':
      return const Color(0xFF1976D2);
    case 'COMPLETED':
      return const Color(0xFF10B981);
    case 'MISSED':
      return const Color(0xFFEC4899);
    default:
      return const Color(0xFF1976D2);
  }
}

Color _getStatusTimeColor(String status) {
  switch (status.toUpperCase()) {
    case 'ONGOING':
      return Colors.green;
    case 'UPCOMING':
      return Colors.blue;
    case 'COMPLETED':
      return Colors.green;
    case 'MISSED':
      return Colors.red;
    default:
      return Colors.blue;
  }
}

// Service class for appointment operations
class AppointmentService {
  static Future<void> createAppointment(Map<String, dynamic> appointmentData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await FirebaseFirestore.instance.collection('appointments').add({
        'doctorId': user.uid,
        'patientName': appointmentData['patientName'],
        'patientAge': appointmentData['patientAge'],
        'patientGender': appointmentData['patientGender'],
        'reason': appointmentData['reason'],
        'doctorName': appointmentData['doctorName'],
        'hospitalName': appointmentData['hospitalName'],
        'appointmentDate': appointmentData['appointmentDate'],
        'appointmentTime': appointmentData['appointmentTime'],
        'contactNumber': appointmentData['contactNumber'],
        'status': 'UPCOMING',
        'visited': 'New',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  static Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update appointment status: $e');
    }
  }

  static Future<void> deleteAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }
} 