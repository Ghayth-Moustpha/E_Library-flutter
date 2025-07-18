import 'package:camera/camera.dart';

class CameraService {
  static List<CameraDescription> _cameras = [];
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _cameras = await availableCameras();
      _initialized = true;
    } on CameraException catch (e) {
      print('Error initializing cameras: $e');
    }
  }

  static List<CameraDescription> get cameras => _cameras;
  static bool get isInitialized => _initialized;
  static bool get hasCameras => _cameras.isNotEmpty;
  
  static CameraDescription? get primaryCamera => 
      _cameras.isNotEmpty ? _cameras.first : null;
}
