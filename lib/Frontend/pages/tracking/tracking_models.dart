class TrackingSession {
  final String sessionId;
  final String tripId;
  final String tourGuideId;
  final DateTime startTime;
  DateTime? endTime;
  bool isActive;

  TrackingSession({
    required this.sessionId,
    required this.tripId,
    required this.tourGuideId,
    required this.startTime,
    this.endTime,
    this.isActive = true,
  });

  factory TrackingSession.fromJson(Map<String, dynamic> json) {
    return TrackingSession(
      sessionId: json['session_id'],
      tripId: json['trip_id'],
      tourGuideId: json['tour_guide_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      isActive: json['status'] == 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'trip_id': tripId,
      'tour_guide_id': tourGuideId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': isActive ? 'active' : 'ended',
    };
  }
}

class LocationUpdate {
  final String sessionId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationUpdate({
    required this.sessionId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}