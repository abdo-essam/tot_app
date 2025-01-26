
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;
import 'tracking_models.dart';

class TrackingService {
  final Dio _dio = Dio();
  static const String _sessionKey = 'tracking_session_id';
  static const String _tripKey = 'tracking_trip_id';

  Future<TrackingSession?> startSession(String tripId, String tourGuideId) async {
    try {
      print('Starting tracking session with tripId: $tripId, tourGuideId: $tourGuideId');
      final response = await _dio.post(
        '${globals.apiUrl}/api/tracking-sessions/start',
        data: {
          'tripId': tripId,
          'tourGuideId': tourGuideId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Tracking session response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final session = TrackingSession.fromJson(response.data);
        await _saveSession(session);
        return session;
      }
      return null;
    } catch (e) {
      print('Error starting session: $e');
      if (e is DioException) {
        print('DioError details: ${e.response?.data}');
      }
      return null;
    }
  }

  Future<void> _saveSession(TrackingSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, session.sessionId);
    await prefs.setString(_tripKey, session.tripId);
  }

  Future<TrackingSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString(_sessionKey);
    if (sessionId == null) return null;

    try {
      final response = await _dio.get(
        '${globals.apiUrl}/api/tracking-sessions/$sessionId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return TrackingSession.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error loading session: $e');
      return null;
    }
  }

  Future<bool> updateLocation(LocationUpdate update) async {
    try {
      final response = await _dio.post(
        '${globals.apiUrl}/api/update-location',
        data: update.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
          },
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating location: $e');
      return false;
    }
  }

  Future<bool> endSession(String sessionId) async {
    try {
      final response = await _dio.post(
        '${globals.apiUrl}/api/tracking-sessions/end',
        data: {'sessionId': sessionId},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_sessionKey);
        await prefs.remove(_tripKey);
        return true;
      }
      return false;
    } catch (e) {
      print('Error ending session: $e');
      return false;
    }
  }
}