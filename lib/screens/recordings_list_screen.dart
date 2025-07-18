import 'package:flutter/material.dart';
import '../models/recording_session.dart';
import '../services/data_service.dart';

class RecordingsListScreen extends StatefulWidget {
  const RecordingsListScreen({super.key});

  @override
  _RecordingsListScreenState createState() => _RecordingsListScreenState();
}

class _RecordingsListScreenState extends State<RecordingsListScreen> {
  final DataService _dataService = DataService();
  List<RecordingSession> _recordings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }

  Future<void> _loadRecordings() async {
    try {
      List<RecordingSession> recordings = await _dataService.getAllRecordingSessions();
      setState(() {
        _recordings = recordings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading recordings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDuration(DateTime start, DateTime? end) {
    if (end == null) return 'Incomplete';
    Duration duration = end.difference(start);
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recorded Sessions'),
        backgroundColor: Colors.blue[800],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _recordings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No recordings yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _recordings.length,
                  itemBuilder: (context, index) {
                    RecordingSession session = _recordings[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[800],
                          child: Icon(
                            Icons.drive_eta,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          'Session ${session.id}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatDateTime(session.startTime)),
                            Text('Duration: ${_formatDuration(session.startTime, session.endTime)}'),
                            Text('GPS Points: ${session.gpsData.length}'),
                          ],
                        ),
                        onTap: () {
                          // Show session details
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
