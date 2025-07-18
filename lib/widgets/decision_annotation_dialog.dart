import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/driving_decision.dart';

class DecisionAnnotationDialog extends StatefulWidget {
  final Function(DrivingDecision) onDecisionAdded;
  final double currentSpeed;
  final Position? currentPosition;
  final List<DetectedObject> detectedObjects;
  final EnvironmentalConditions environmentalConditions;

  const DecisionAnnotationDialog({super.key, 
    required this.onDecisionAdded,
    required this.currentSpeed,
    required this.currentPosition,
    required this.detectedObjects,
    required this.environmentalConditions,
  });

  @override
  _DecisionAnnotationDialogState createState() => _DecisionAnnotationDialogState();
}

class _DecisionAnnotationDialogState extends State<DecisionAnnotationDialog> {
  String _selectedAction = 'accelerate';
  String _reasoning = '';
  int _riskLevel = 1;
  final List<String> _selectedAlternatives = [];

  final List<String> _actions = [
    'accelerate',
    'brake',
    'turn_left',
    'turn_right',
    'lane_change_left',
    'lane_change_right',
    'stop',
    'yield',
    'maintain_speed',
  ];

  final List<String> _alternativeActions = [
    'accelerate',
    'brake',
    'turn_left',
    'turn_right',
    'lane_change_left',
    'lane_change_right',
    'stop',
    'yield',
    'maintain_speed',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Annotate Driving Decision'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current context info
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Context:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Speed: ${widget.currentSpeed.toStringAsFixed(1)} km/h'),
                  Text('Objects detected: ${widget.detectedObjects.length}'),
                  Text('Weather: ${widget.environmentalConditions.weather}'),
                  Text('Traffic: ${widget.environmentalConditions.trafficDensity}'),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            // Action selection
            Text('Action Taken:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedAction,
              isExpanded: true,
              items: _actions.map((action) {
                return DropdownMenuItem(
                  value: action,
                  child: Text(action.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAction = value!;
                });
              },
            ),
            SizedBox(height: 16),
            
            // Reasoning
            Text('Reasoning:', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              onChanged: (value) => _reasoning = value,
              decoration: InputDecoration(
                hintText: 'Explain why you made this decision...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            
            // Risk level
            Text('Risk Level (1-10):', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _riskLevel.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _riskLevel.toString(),
              onChanged: (value) {
                setState(() {
                  _riskLevel = value.round();
                });
              },
            ),
            Text('Current: $_riskLevel (${_getRiskDescription(_riskLevel)})',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            SizedBox(height: 16),
            
            // Alternative actions
            Text('Alternative Actions Considered:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              children: _alternativeActions.where((action) => action != _selectedAction).map((action) {
                bool isSelected = _selectedAlternatives.contains(action);
                return FilterChip(
                  label: Text(action.replaceAll('_', ' ')),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAlternatives.add(action);
                      } else {
                        _selectedAlternatives.remove(action);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _reasoning.isNotEmpty ? () {
            DrivingDecision decision = DrivingDecision(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              timestamp: DateTime.now(),
              action: _selectedAction,
              reasoning: _reasoning,
              riskLevel: _riskLevel,
              alternativeActions: _selectedAlternatives,
              context: {
                'speed': widget.currentSpeed,
                'position': widget.currentPosition != null ? {
                  'latitude': widget.currentPosition!.latitude,
                  'longitude': widget.currentPosition!.longitude,
                } : null,
              },
              detectedObjects: widget.detectedObjects,
              laneInfo: LaneInfo(
                leftLaneAvailable: true, // This would be detected in real implementation
                rightLaneAvailable: true,
                laneWidth: 3.5,
                lanePosition: 'center',
                isChangingLanes: false,
              ),
              environmentalConditions: widget.environmentalConditions,
            );
            
            widget.onDecisionAdded(decision);
            Navigator.of(context).pop();
          } : null,
          child: Text('Add Decision'),
        ),
      ],
    );
  }

  String _getRiskDescription(int risk) {
    if (risk <= 2) return 'Very Safe';
    if (risk <= 4) return 'Safe';
    if (risk <= 6) return 'Moderate';
    if (risk <= 8) return 'Risky';
    return 'Very Risky';
  }
}
