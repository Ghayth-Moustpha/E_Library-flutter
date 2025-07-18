class RecordingSession {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  String? videoPath;
  String? audioPath;
  List<Map<String, dynamic>> gpsData;
  List<Map<String, dynamic>> voiceNotes;

  RecordingSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.videoPath,
    this.audioPath,
    required this.gpsData,
    required this.voiceNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'videoPath': videoPath,
      'audioPath': audioPath,
      'gpsData': gpsData,
      'voiceNotes': voiceNotes,
    };
  }

  factory RecordingSession.fromJson(Map<String, dynamic> json) {
    return RecordingSession(
      id: json['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
      endTime: json['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['endTime'])
          : null,
      videoPath: json['videoPath'],
      audioPath: json['audioPath'],
      gpsData: List<Map<String, dynamic>>.from(json['gpsData'] ?? []),
      voiceNotes: List<Map<String, dynamic>>.from(json['voiceNotes'] ?? []),
    );
  }
}
