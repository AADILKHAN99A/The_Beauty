import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final int streakCount;
  final Timestamp lastLogin;
  final List<Routine> routines;

  User({
    required this.streakCount,
    required this.lastLogin,
    required this.routines,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    var routinesList = (data['routines'] as List)
        .map((routineData) => Routine.fromMap(routineData))
        .toList();

    return User(
      streakCount: data['streakCount'] ?? 0,
      lastLogin: data['lastLogin'] ?? Timestamp.now(),
      routines: routinesList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'streakCount': streakCount,
      'lastLogin': lastLogin,
      'routines': routines.map((routine) => routine.toMap()).toList(),
    };
  }
}

class Routine {
  final Timestamp date;
  final List<RoutineStep> steps;

  Routine({
    required this.date,
    required this.steps,
  });

  factory Routine.fromMap(Map<String, dynamic> data) {
    var stepsList = (data['steps'] as List)
        .map((stepData) => RoutineStep.fromMap(stepData))
        .toList();

    return Routine(
      date: data['date'] ?? Timestamp.now(),
      steps: stepsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'steps': steps.map((step) => step.toMap()).toList(),
    };
  }
}

class RoutineStep {
  final String step;
  final Timestamp time;
  final String product;
  final String imageUrl;

  RoutineStep({
    required this.step,
    required this.time,
    required this.product,
    required this.imageUrl,
  });

  factory RoutineStep.fromMap(Map<String, dynamic> data) {
    return RoutineStep(
      step: data['step'] ?? '',
      time: data['time'] ?? Timestamp.now(),
      product: data['product'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'step': step,
      'time': time,
      'product': product,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return 'RoutineStep{step: $step, time: $time, product: $product, imageUrl: $imageUrl}';
  }

  RoutineStep copyWith({
    String? step,
    Timestamp? time,
    String? product,
    String? imageUrl,
  }) {
    return RoutineStep(
      step: step ?? this.step,
      time: time ?? this.time,
      product: product ?? this.product,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
