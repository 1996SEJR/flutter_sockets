import 'package:flutter/material.dart';

class TakePictureNotifier with ChangeNotifier {
  bool _isCameraGranted = false;
  bool _isPlaying = false;
  double _smallRadius = 0.39;
  Future<void> _initializeControllerFuture;

  bool get isCameraGranted => _isCameraGranted;
  bool get isPlaying => _isPlaying;
  double get smallRadius => _smallRadius;
  Future<void> get initializeControllerFuture => _initializeControllerFuture;

  set isCameraGranted(bool value) {
    _isCameraGranted = value;
    notifyListeners();
  }

  set smallRadius(double value) {
    _smallRadius = value;
    notifyListeners();
  }

  set isPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  set initializeControllerFuture(Future<void> value) {
    _initializeControllerFuture = value;
    notifyListeners();
  }
}
