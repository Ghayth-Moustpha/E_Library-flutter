class DrivingDecision {
  final String id;
  final DateTime timestamp;
  final String action; // accelerate, brake, turn_left, turn_right, lane_change, stop, yield
  final String reasoning;
  final int riskLevel; // 1-10 scale
  final List<String> alternativeActions;
  final Map<String, dynamic> context;
  final List<DetectedObject> detectedObjects;
  final LaneInfo laneInfo;
  final EnvironmentalConditions environmentalConditions;

  DrivingDecision({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.reasoning,
    required this.riskLevel,
    required this.alternativeActions,
    required this.context,
    required this.detectedObjects,
    required this.laneInfo,
    required this.environmentalConditions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'action': action,
      'reasoning': reasoning,
      'riskLevel': riskLevel,
      'alternativeActions': alternativeActions,
      'context': context,
      'detectedObjects': detectedObjects.map((obj) => obj.toJson()).toList(),
      'laneInfo': laneInfo.toJson(),
      'environmentalConditions': environmentalConditions.toJson(),
    };
  }

  factory DrivingDecision.fromJson(Map<String, dynamic> json) {
    return DrivingDecision(
      id: json['id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      action: json['action'],
      reasoning: json['reasoning'],
      riskLevel: json['riskLevel'],
      alternativeActions: List<String>.from(json['alternativeActions']),
      context: json['context'],
      detectedObjects: (json['detectedObjects'] as List)
          .map((obj) => DetectedObject.fromJson(obj))
          .toList(),
      laneInfo: LaneInfo.fromJson(json['laneInfo']),
      environmentalConditions: EnvironmentalConditions.fromJson(json['environmentalConditions']),
    );
  }
}

class DetectedObject {
  final String type; // car, pedestrian, cyclist, traffic_sign, traffic_light
  final double confidence;
  final Map<String, double> boundingBox; // x, y, width, height
  final double? distance;
  final String? subType; // for traffic signs: stop, yield, speed_limit_30, etc.
  final String? state; // for traffic lights: red, yellow, green

  DetectedObject({
    required this.type,
    required this.confidence,
    required this.boundingBox,
    this.distance,
    this.subType,
    this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'confidence': confidence,
      'boundingBox': boundingBox,
      'distance': distance,
      'subType': subType,
      'state': state,
    };
  }

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    return DetectedObject(
      type: json['type'],
      confidence: json['confidence'],
      boundingBox: Map<String, double>.from(json['boundingBox']),
      distance: json['distance'],
      subType: json['subType'],
      state: json['state'],
    );
  }
}

class LaneInfo {
  final bool leftLaneAvailable;
  final bool rightLaneAvailable;
  final double laneWidth;
  final String lanePosition; // center, left, right
  final bool isChangingLanes;
  final String? laneChangeDirection;

  LaneInfo({
    required this.leftLaneAvailable,
    required this.rightLaneAvailable,
    required this.laneWidth,
    required this.lanePosition,
    required this.isChangingLanes,
    this.laneChangeDirection,
  });

  Map<String, dynamic> toJson() {
    return {
      'leftLaneAvailable': leftLaneAvailable,
      'rightLaneAvailable': rightLaneAvailable,
      'laneWidth': laneWidth,
      'lanePosition': lanePosition,
      'isChangingLanes': isChangingLanes,
      'laneChangeDirection': laneChangeDirection,
    };
  }

  factory LaneInfo.fromJson(Map<String, dynamic> json) {
    return LaneInfo(
      leftLaneAvailable: json['leftLaneAvailable'],
      rightLaneAvailable: json['rightLaneAvailable'],
      laneWidth: json['laneWidth'],
      lanePosition: json['lanePosition'],
      isChangingLanes: json['isChangingLanes'],
      laneChangeDirection: json['laneChangeDirection'],
    );
  }
}

class EnvironmentalConditions {
  final String weather; // sunny, rainy, foggy, snowy
  final String roadCondition; // dry, wet, icy, construction
  final String trafficDensity; // light, moderate, heavy
  final String timeOfDay; // morning, afternoon, evening, night
  final bool isRushHour;
  final double visibility; // 1-10 scale

  EnvironmentalConditions({
    required this.weather,
    required this.roadCondition,
    required this.trafficDensity,
    required this.timeOfDay,
    required this.isRushHour,
    required this.visibility,
  });

  Map<String, dynamic> toJson() {
    return {
      'weather': weather,
      'roadCondition': roadCondition,
      'trafficDensity': trafficDensity,
      'timeOfDay': timeOfDay,
      'isRushHour': isRushHour,
      'visibility': visibility,
    };
  }

  factory EnvironmentalConditions.fromJson(Map<String, dynamic> json) {
    return EnvironmentalConditions(
      weather: json['weather'],
      roadCondition: json['roadCondition'],
      trafficDensity: json['trafficDensity'],
      timeOfDay: json['timeOfDay'],
      isRushHour: json['isRushHour'],
      visibility: json['visibility'],
    );
  }
}
