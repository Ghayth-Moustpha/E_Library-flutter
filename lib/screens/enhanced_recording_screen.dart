import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/camera_service.dart';
import '../models/enhanced_recording_session.dart';
import '../models/driving_decision.dart';
import '../services/enhanced_data_service.dart';
import '../widgets/decision_annotation_dialog.dart';
import '../widgets/object_detection_overlay.dart';
import '../widgets/environmental_conditions_panel.dart';

class EnhancedRecordingScreen extends StatefulWidget {
  @override
  _EnhancedRecordingScreenState createState() => _EnhancedRecordingScreenState();
}

class _EnhancedRecordingScreenState extends State<EnhancedRecordingScreen> {
  CameraController? _cameraController;
  EnhancedDataService _dataService = EnhancedDataService();
  
  bool _isRecording = false;
  bool _isInitialized = false;
  Position? _currentPosition;
  double _currentSpeed = 0.0;
  
  // Sensor data
  List<double> _accelerometerValues = [0.0, 0.0, 0.0];
  List<double> _gyroscopeValues = [0.0, 0.0, 0.0];
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  
  // Enhanced session data
  EnhancedRecordingSession? _currentSession;
  List<DetectedObject> _currentDetectedObjects = [];
  EnvironmentalConditions _environmentalConditions = EnvironmentalConditions(
    weather: 'sunny',
    roadCondition: 'dry',
    trafficDensity: 'light',
    timeOfDay: 'afternoon',
    isRushHour: false,
    visibility: 10.0,
  );
  
  Timer? _gpsTimer;
  Timer? _sensorTimer;
  DateTime? _recordingStartTime;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeSensors();
    _getCurrentLocation();
  }

  Future<void> _initializeCamera() async {
    if (!CameraService.hasCameras) return;
    
    _cameraController = CameraController(
      CameraService.primaryCamera!,
      ResolutionPreset.high,
      enableAudio: false,
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

  void _initializeSensors() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = [event.x, event.y, event.z];
      });
    });

    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = [event.x, event.y, event.z];
      });
    });
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

  void _startSensorDataCollection() {
    _sensorTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_currentSession != null) {
        _currentSession!.sensorData.add({
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'accelerometer': {
            'x': _accelerometerValues[0],
            'y': _accelerometerValues[1],
            'z': _accelerometerValues[2],
          },
          'gyroscope': {
            'x': _gyroscopeValues[0],
            'y': _gyroscopeValues[1],
            'z': _gyroscopeValues[2],
          },
          'speed': _currentSpeed,
          'position': _currentPosition != null ? {
            'latitude': _currentPosition!.latitude,
            'longitude': _currentPosition!.longitude,
          } : null,
        });
      }
    });
  }

  Future<void> _startRecording() async {
    if (!_isInitialized || _cameraController == null) return;
    
    try {
      _currentSession = EnhancedRecordingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
        gpsData: [],
        voiceNotes: [],
        drivingDecisions: [],
        sensorData: [],
        sessionMetadata: {
          'initialEnvironmentalConditions': _environmentalConditions.toJson(),
          'deviceInfo': {
            'platform': Platform.operatingSystem,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        },
      );
      
      await _cameraController!.startVideoRecording();
      
      setState(() {
        _isRecording = true;
        _recordingStartTime = DateTime.now();
      });
      
      _startGPSTracking();
      _startSensorDataCollection();
      _updateRecordingDuration();
      
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  void _startGPSTracking() {
    _gpsTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        setState(() {
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
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      if (_recordingStartTime != null) {
        setState(() {
          _recordingDuration = DateTime.now().difference(_recordingStartTime!);
        });
      }
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    
    try {
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      
      _gpsTimer?.cancel();
      _sensorTimer?.cancel();
      
      if (_currentSession != null) {
        _currentSession!.endTime = DateTime.now();
        _currentSession!.videoPath = videoFile.path;
        
        await _dataService.saveEnhancedRecordingSession(_currentSession!);
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your enhanced driving session has been saved.'),
              SizedBox(height: 10),
              if (_currentSession != null) ...[
                Text('Driving Decisions: ${_currentSession!.drivingDecisions.length}'),
                Text('Sensor Data Points: ${_currentSession!.sensorData.length}'),
                Text('GPS Data Points: ${_currentSession!.gpsData.length}'),
              ],
            ],
          ),
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

  void _showDecisionAnnotationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DecisionAnnotationDialog(
          onDecisionAdded: (DrivingDecision decision) {
            if (_currentSession != null) {
              _currentSession!.drivingDecisions.add(decision);
            }
          },
          currentSpeed: _currentSpeed,
          currentPosition: _currentPosition,
          detectedObjects: _currentDetectedObjects,
          environmentalConditions: _environmentalConditions,
        );
      },
    );
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          CameraPreview(_cameraController!),
          
          // Object detection overlay
          ObjectDetectionOverlay(
            detectedObjects: _currentDetectedObjects,
            onObjectsDetected: (objects) {
              setState(() {
                _currentDetectedObjects = objects;
              });
            },
          ),
          
          // Top recording info
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
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
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Decisions', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Text(
                            '${_currentSession?.drivingDecisions.length ?? 0}',
                            style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Objects', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Text(
                            '${_currentDetectedObjects.length}',
                            style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Sensors', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Text(
                            '${_currentSession?.sensorData.length ?? 0}',
                            style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Speed and GPS info
          Positioned(
            top: 180,
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
                      Icon(Icons.speed, color: Colors.green),
                      SizedBox(width: 5),
                      Text(
                        '${_currentSpeed.toStringAsFixed(1)} km/h',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Accel: ${_accelerometerValues[0].toStringAsFixed(1)}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Gyro: ${_gyroscopeValues[2].toStringAsFixed(1)}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          
          // Environmental conditions panel
          Positioned(
            top: 180,
            right: 20,
            child: EnvironmentalConditionsPanel(
              conditions: _environmentalConditions,
              onConditionsChanged: (conditions) {
                setState(() {
                  _environmentalConditions = conditions;
                });
              },
            ),
          ),
          
          // Bottom controls
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
                
                FloatingActionButton(
                  onPressed: _isRecording ? _showDecisionAnnotationDialog : null,
                  backgroundColor: _isRecording ? Colors.blue : Colors.grey,
                  child: Icon(Icons.psychology),
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
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _gpsTimer?.cancel();
    _sensorTimer?.cancel();
    super.dispose();
  }
}
