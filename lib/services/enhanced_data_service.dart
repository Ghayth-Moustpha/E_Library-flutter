import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/enhanced_recording_session.dart';

class EnhancedDataService {
  static const String _enhancedSessionsFileName = 'enhanced_recording_sessions.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _enhancedSessionsFile async {
    final path = await _localPath;
    return File('$path/$_enhancedSessionsFileName');
  }

  Future<List<EnhancedRecordingSession>> getAllEnhancedRecordingSessions() async {
    try {
      final file = await _enhancedSessionsFile;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      
      return jsonList.map((json) => EnhancedRecordingSession.fromJson(json)).toList();
    } catch (e) {
      print('Error reading enhanced recording sessions: $e');
      return [];
    }
  }

  Future<void> saveEnhancedRecordingSession(EnhancedRecordingSession session) async {
    try {
      List<EnhancedRecordingSession> sessions = await getAllEnhancedRecordingSessions();
      
      sessions.removeWhere((s) => s.id == session.id);
      sessions.add(session);
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      
      final file = await _enhancedSessionsFile;
      final jsonList = sessions.map((s) => s.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      
      print('Enhanced recording session saved: ${session.id}');
    } catch (e) {
      print('Error saving enhanced recording session: $e');
      rethrow;
    }
  }

  Future<void> exportForMLTraining(EnhancedRecordingSession session, String exportPath) async {
    try {
      // Create ML training format
      final mlData = {
        'session_id': session.id,
        'metadata': {
          'duration_seconds': session.endTime != null 
              ? session.endTime!.difference(session.startTime).inSeconds 
              : 0,
          'total_decisions': session.drivingDecisions.length,
          'total_objects_detected': session.drivingDecisions
              .map((d) => d.detectedObjects.length)
              .fold(0, (a, b) => a + b),
          'environmental_conditions': session.sessionMetadata['initialEnvironmentalConditions'],
        },
        'training_data': session.drivingDecisions.map((decision) => {
          'input_features': {
            'speed_kmh': decision.context['speed'],
            'detected_objects': decision.detectedObjects.map((obj) => {
              'type': obj.type,
              'distance': obj.distance,
              'confidence': obj.confidence,
              'subtype': obj.subType,
            }).toList(),
            'environmental_conditions': decision.environmentalConditions.toJson(),
            'lane_info': decision.laneInfo.toJson(),
            'sensor_context': _getNearestSensorData(session, decision.timestamp),
          },
          'target_output': {
            'action': decision.action,
            'reasoning': decision.reasoning,
            'risk_level': decision.riskLevel,
            'alternative_actions': decision.alternativeActions,
          },
        }).toList(),
        'sensor_data_summary': {
          'total_points': session.sensorData.length,
          'avg_speed': _calculateAverageSpeed(session.sensorData),
          'max_acceleration': _calculateMaxAcceleration(session.sensorData),
        },
      };
      
      final exportFile = File('$exportPath/ml_training_data_${session.id}.json');
      await exportFile.writeAsString(json.encode(mlData));
      
      print('ML training data exported to: ${exportFile.path}');
    } catch (e) {
      print('Error exporting ML training data: $e');
      rethrow;
    }
  }

  Map<String, dynamic>? _getNearestSensorData(EnhancedRecordingSession session, DateTime timestamp) {
    if (session.sensorData.isEmpty) return null;
    
    // Find sensor data point closest to decision timestamp
    var closest = session.sensorData.reduce((a, b) {
      int aTimestamp = a['timestamp'];
      int bTimestamp = b['timestamp'];
      int targetTimestamp = timestamp.millisecondsSinceEpoch;
      
      return (aTimestamp - targetTimestamp).abs() < (bTimestamp - targetTimestamp).abs() ? a : b;
    });
    
    return closest;
  }

  double _calculateAverageSpeed(List<Map<String, dynamic>> sensorData) {
    if (sensorData.isEmpty) return 0.0;
    
    double totalSpeed = sensorData
        .map((data) => data['speed'] as double? ?? 0.0)
        .fold(0.0, (a, b) => a + b);
    
    return totalSpeed / sensorData.length;
  }

  double _calculateMaxAcceleration(List<Map<String, dynamic>> sensorData) {
    if (sensorData.isEmpty) return 0.0;
    
    return sensorData
        .map((data) => (data['accelerometer']['x'] as double? ?? 0.0).abs())
        .fold(0.0, (a, b) => a > b ? a : b);
  }
}
