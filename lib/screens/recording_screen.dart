import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart';
import '../models/recording_session.dart';
import '../services/data_service.dart';
import '../services/camera_service.dart';

class RecordingScreen extends StatefulWidget {
  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  CameraController? _cameraController;
  DataService _dataService = DataService();
  
  bool _isRecording = false;
  bool _isInitialized = false;
  Position? _currentPosition;
  double _currentSpeed = 0.0;
  double _previousSpeed = 0.0;
  
  Timer? _gpsTimer;
  Timer? _recordingTimer;
  DateTime? _recordingStartTime;
  Duration _recordingDuration = Duration.zero;
  
  RecordingSession? _currentSession;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();
  }

  Future<void> _initializeCamera() async {
    if (!CameraService.hasCameras) return;
  
    _cameraController = CameraController(
      CameraService.primaryCamera!,
      ResolutionPreset.high,
      enableAudio: true,
    );
  
    try {
      await _cameraController!.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _currentSpeed = position.speed * 3.6;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _startGPSTracking() {
    _gpsTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        setState(() {
          _previousSpeed = _currentSpeed;
          _currentPosition = position;
          _currentSpeed = position.speed * 3.6;
        });
        
        if (_currentSession != null) {
          _currentSession!.gpsData.add({
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'altitude': position.altitude,
            'accuracy': position.accuracy,
            'speed': position.speed,
            'speedKmh': _currentSpeed,
            'heading': position.heading,
          });
        }
      } catch (e) {
        print('Error tracking GPS: $e');
      }
    });
  }

  void _updateRecordingDuration() {
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_recordingStartTime != null) {
        setState(() {
          _recordingDuration = DateTime.now().difference(_recordingStartTime!);
        });
      }
    });
  }

  Future<void> _startRecording() async {
    if (!_isInitialized || _cameraController == null) return;
    
    try {
      _currentSession = RecordingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
        gpsData: [],
        voiceNotes: [],
      );
      
      await _cameraController!.startVideoRecording();
      
      setState(() {
        _isRecording = true;
        _recordingStartTime = DateTime.now();
      });
      
      _startGPSTracking();
      _updateRecordingDuration();
      
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    
    try {
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      
      _gpsTimer?.cancel();
      _recordingTimer?.cancel();
      
      if (_currentSession != null) {
        _currentSession!.endTime = DateTime.now();
        _currentSession!.videoPath = videoFile.path;
        
        await _dataService.saveRecordingSession(_currentSession!);
      }
      
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
        _recordingStartTime = null;
      });
      
      _showRecordingCompleteDialog();
      
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  void _showRecordingCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Recording Complete'),
          content: Text('Your driving session has been saved successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Color _getSpeedColor() {
    if (_currentSpeed > _previousSpeed) {
      return Colors.green;
    } else if (_currentSpeed < _previousSpeed) {
      return Colors.red;
    }
    return Colors.blue;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraController == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isRecording ? Icons.fiber_manual_record : Icons.stop,
                            color: _isRecording ? Colors.red : Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            _isRecording ? 'RECORDING' : 'STOPPED',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatDuration(_recordingDuration),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Positioned(
            top: 150,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed, color: _getSpeedColor()),
                      SizedBox(width: 5),
                      Text(
                        '${_currentSpeed.toStringAsFixed(1)} km/h',
                        style: TextStyle(
                          color: _getSpeedColor(),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (_currentPosition != null) ...[
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 16),
                        SizedBox(width: 5),
                        Text(
                          'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 16),
                        SizedBox(width: 5),
                        Text(
                          'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    if (_isRecording) {
                      _stopRecording();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  backgroundColor: Colors.grey[800],
                  child: Icon(Icons.arrow_back),
                ),
                
                FloatingActionButton(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  backgroundColor: _isRecording ? Colors.red : Colors.green,
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.fiber_manual_record,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _gpsTimer?.cancel();
    _recordingTimer?.cancel();
    super.dispose();
  }
}
