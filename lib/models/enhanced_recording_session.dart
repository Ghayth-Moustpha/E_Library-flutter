import 'recording_session.dart';
import 'driving_decision.dart';

class EnhancedRecordingSession extends RecordingSession {
  List<DrivingDecision> drivingDecisions;
  List<Map<String, dynamic>> sensorData;
  Map<String, dynamic> sessionMetadata;

  EnhancedRecordingSession({
    required super.id,
    required super.startTime,
    super.endTime,
    super.videoPath,
    super.audioPath,
    required super.gpsData,
    required super.voiceNotes,
    required this.drivingDecisions,
    required this.sensorData,
    required this.sessionMetadata,
  });

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson.addAll({
      'drivingDecisions': drivingDecisions.map((d) => d.toJson()).toList(),
      'sensorData': sensorData,
      'sessionMetadata': sessionMetadata,
    });
    return baseJson;
  }

  factory EnhancedRecordingSession.fromJson(Map<String, dynamic> json) {
    return EnhancedRecordingSession(
      id: json['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
      endTime: json['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['endTime'])
          : null,
      videoPath: json['videoPath'],
      audioPath: json['audioPath'],
      gpsData: List<Map<String, dynamic>>.from(json['gpsData'] ?? []),
      voiceNotes: List<Map<String, dynamic>>.from(json['voiceNotes'] ?? []),
      drivingDecisions: (json['drivingDecisions'] as List? ?? [])
          .map((d) => DrivingDecision.fromJson(d))
          .toList(),
      sensorData: List<Map<String, dynamic>>.from(json['sensorData'] ?? []),
      sessionMetadata: json['sessionMetadata'] ?? {},
    );
  }
}
