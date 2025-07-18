import 'package:flutter/material.dart';
import '../models/driving_decision.dart';

class EnvironmentalConditionsPanel extends StatelessWidget {
  final EnvironmentalConditions conditions;
  final Function(EnvironmentalConditions) onConditionsChanged;

  const EnvironmentalConditionsPanel({super.key, 
    required this.conditions,
    required this.onConditionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _showConditionsDialog(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings, color: Colors.white, size: 16),
                SizedBox(width: 5),
                Text(
                  'Conditions',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Text(
            conditions.weather.toUpperCase(),
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            conditions.trafficDensity.toUpperCase(),
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            'Vis: ${conditions.visibility.toInt()}/10',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _showConditionsDialog(BuildContext context) {
    String weather = conditions.weather;
    String roadCondition = conditions.roadCondition;
    String trafficDensity = conditions.trafficDensity;
    String timeOfDay = conditions.timeOfDay;
    bool isRushHour = conditions.isRushHour;
    double visibility = conditions.visibility;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Environmental Conditions'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDropdown('Weather', weather, 
                        ['sunny', 'cloudy', 'rainy', 'foggy', 'snowy'], 
                        (value) => setState(() => weather = value!)),
                    
                    _buildDropdown('Road Condition', roadCondition,
                        ['dry', 'wet', 'icy', 'construction'],
                        (value) => setState(() => roadCondition = value!)),
                    
                    _buildDropdown('Traffic Density', trafficDensity,
                        ['light', 'moderate', 'heavy'],
                        (value) => setState(() => trafficDensity = value!)),
                    
                    _buildDropdown('Time of Day', timeOfDay,
                        ['morning', 'afternoon', 'evening', 'night'],
                        (value) => setState(() => timeOfDay = value!)),
                    
                    SwitchListTile(
                      title: Text('Rush Hour'),
                      value: isRushHour,
                      onChanged: (value) => setState(() => isRushHour = value),
                    ),
                    
                    Text('Visibility: ${visibility.toInt()}/10'),
                    Slider(
                      value: visibility,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (value) => setState(() => visibility = value),
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
                  onPressed: () {
                    EnvironmentalConditions newConditions = EnvironmentalConditions(
                      weather: weather,
                      roadCondition: roadCondition,
                      trafficDensity: trafficDensity,
                      timeOfDay: timeOfDay,
                      isRushHour: isRushHour,
                      visibility: visibility,
                    );
                    onConditionsChanged(newConditions);
                    Navigator.of(context).pop();
                  },
                  child: Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: options.map((option) => 
                DropdownMenuItem(value: option, child: Text(option.toUpperCase()))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
