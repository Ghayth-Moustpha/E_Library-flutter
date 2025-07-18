import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/recording_session.dart';

class DataService {
  static const String _sessionsFileName = 'recording_sessions.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _sessionsFile async {
    final path = await _localPath;
    return File('$path/$_sessionsFileName');
  }

  Future<List<RecordingSession>> getAllRecordingSessions() async {
    try {
      final file = await _sessionsFile;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      
      return jsonList.map((json) => RecordingSession.fromJson(json)).toList();
    } catch (e) {
      print('Error reading recording sessions: $e');
      return [];
    }
  }

  Future<void> saveRecordingSession(RecordingSession session) async {
    try {
      List<RecordingSession> sessions = await getAllRecordingSessions();
      
      sessions.removeWhere((s) => s.id == session.id);
      sessions.add(session);
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      
      final file = await _sessionsFile;
      final jsonList = sessions.map((s) => s.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      
      print('Recording session saved: ${session.id}');
    } catch (e) {
      print('Error saving recording session: $e');
      rethrow;
    }
  }

  Future<void> deleteRecordingSession(String sessionId) async {
    try {
      List<RecordingSession> sessions = await getAllRecordingSessions();
      
      RecordingSession? sessionToDelete = sessions.where((s) => s.id == sessionId).isNotEmpty
          ? sessions.firstWhere((s) => s.id == sessionId)
          : null;
      
      if (sessionToDelete == null) {
        throw Exception('Session not found');
      }
      
      if (sessionToDelete.videoPath != null) {
        final videoFile = File(sessionToDelete.videoPath!);
        if (await videoFile.exists()) {
          await videoFile.delete();
        }
      }
      
      if (sessionToDelete.audioPath != null) {
        final audioFile = File(sessionToDelete.audioPath!);
        if (await audioFile.exists()) {
          await audioFile.delete();
        }
      }
      
      sessions.removeWhere((s) => s.id == sessionId);
      
      final file = await _sessionsFile;
      final jsonList = sessions.map((s) => s.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      
      print('Recording session deleted: $sessionId');
    } catch (e) {
      print('Error deleting recording session: $e');
      rethrow;
    }
  }
}
