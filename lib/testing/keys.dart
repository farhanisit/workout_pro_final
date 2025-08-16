//Keys.dart - Defines keys for widget testing in Workout Pro
// - Provides unique keys for home tiles, progress charts, and lists
// - Ensures deterministic access in widget tests
// - Supports both production and test environments

import 'package:flutter/widgets.dart';

class TKeys {
  // Home / Dashboard
  static const totalWorkoutsTile = Key('totalWorkoutsTile');
  static const addWorkoutFab = Key('addWorkoutFab');
  static const programsHub = Key('programsHub');

  // Progress
  static const progressBack = Key('progressBack');
  static const donutChart = Key('donutChart');
  static const weeklyBars = Key('weeklyBars');

  // Lists
  static const manageWorkoutsBtn = Key('manageWorkoutsButton');
}
