import 'package:flutter/material.dart';
import '../models/driving_decision.dart';

class ObjectDetectionOverlay extends StatefulWidget {
  final List<DetectedObject> detectedObjects;
  final Function(List<DetectedObject>) onObjectsDetected;

  const ObjectDetectionOverlay({super.key, 
    required this.detectedObjects,
    required this.onObjectsDetected,
  });

  @override
  _ObjectDetectionOverlayState createState() => _ObjectDetectionOverlayState();
}

class _ObjectDetectionOverlayState extends State<ObjectDetectionOverlay> {
  final List<DetectedObject> _manualObjects = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Manual object detection interface
        Positioned(
          bottom: 150,
          right: 20,
          child: Column(
            children: [
              FloatingActionButton.small(
                onPressed: () => _showObjectDetectionDialog(),
                backgroundColor: Colors.purple,
                child: Icon(Icons.add_box, size: 20),
              ),
              SizedBox(height: 8),
              Text(
                'Add\nObject',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        // Display detected objects
        ...widget.detectedObjects.map((obj) => _buildObjectBox(obj)),
      ],
    );
  }

  Widget _buildObjectBox(DetectedObject obj) {
    Color boxColor = _getObjectColor(obj.type);
    
    return Positioned(
      left: obj.boundingBox['x']! * MediaQuery.of(context).size.width,
      top: obj.boundingBox['y']! * MediaQuery.of(context).size.height,
      child: Container(
        width: obj.boundingBox['width']! * MediaQuery.of(context).size.width,
        height: obj.boundingBox['height']! * MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          border: Border.all(color: boxColor, width: 2),
          color: boxColor.withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: boxColor,
              child: Text(
                '${obj.type.toUpperCase()}${obj.subType != null ? ' (${obj.subType})' : ''}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (obj.distance != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                color: Colors.black.withOpacity(0.7),
                child: Text(
                  '${obj.distance!.toStringAsFixed(1)}m',
                  style: TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getObjectColor(String type) {
    switch (type) {
      case 'car': return Colors.blue;
      case 'pedestrian': return Colors.red;
      case 'cyclist': return Colors.green;
      case 'traffic_sign': return Colors.yellow;
      case 'traffic_light': return Colors.orange;
      default: return Colors.purple;
    }
  }

  void _showObjectDetectionDialog() {
    String selectedType = 'car';
    String? selectedSubType;
    double distance = 10.0;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Detected Object'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    items: ['car', 'pedestrian', 'cyclist', 'traffic_sign', 'traffic_light']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                        selectedSubType = null;
                      });
                    },
                  ),
                  
                  if (selectedType == 'traffic_sign') ...[
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedSubType,
                      hint: Text('Sign Type'),
                      isExpanded: true,
                      items: ['stop', 'yield', 'speed_limit_30', 'speed_limit_50', 'no_entry']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubType = value;
                        });
                      },
                    ),
                  ],
                  
                  if (selectedType == 'traffic_light') ...[
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedSubType,
                      hint: Text('Light State'),
                      isExpanded: true,
                      items: ['red', 'yellow', 'green']
                          .map((state) => DropdownMenuItem(value: state, child: Text(state)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubType = value;
                        });
                      },
                    ),
                  ],
                  
                  SizedBox(height: 10),
                  Text('Distance: ${distance.toStringAsFixed(1)}m'),
                  Slider(
                    value: distance,
                    min: 1.0,
                    max: 100.0,
                    onChanged: (value) {
                      setState(() {
                        distance = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    DetectedObject newObject = DetectedObject(
                      type: selectedType,
                      confidence: 0.9, // Manual detection assumed high confidence
                      boundingBox: {
                        'x': 0.3,
                        'y': 0.3,
                        'width': 0.2,
                        'height': 0.2,
                      },
                      distance: distance,
                      subType: selectedSubType,
                      state: selectedType == 'traffic_light' ? selectedSubType : null,
                    );
                    
                    List<DetectedObject> updatedObjects = [...widget.detectedObjects, newObject];
                    widget.onObjectsDetected(updatedObjects);
                    Navigator.of(context).pop();
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
