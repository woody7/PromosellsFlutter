import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

enum _LocationCaptureState { idle, capturing, success, error }

/// Port of the React app's OfficeCaptureFields.js: office photo capture,
/// geolocation capture, and a "demo app installed" yes/no choice. Reused
/// across the drop-off flow (Stage 1/2) and customer edit (Stage 7) — any
/// field already populated on an existing customer (`existingPhotoUrl`,
/// `existingLatitude`/`existingLongitude`, `demoAppInstalled == true`) hides
/// that section, matching the React version's behavior of not re-prompting
/// for data that's already on file.
class OfficeCaptureFields extends StatefulWidget {
  const OfficeCaptureFields({
    super.key,
    required this.demoAppInstalled,
    required this.onDemoAppInstalledChange,
    required this.onPhotoSelected,
    required this.onLocationCaptured,
    this.existingPhotoUrl,
    this.existingLatitude,
    this.existingLongitude,
  });

  final bool? demoAppInstalled;
  final ValueChanged<bool?> onDemoAppInstalledChange;
  final ValueChanged<XFile?> onPhotoSelected;
  final void Function(double latitude, double longitude) onLocationCaptured;
  final String? existingPhotoUrl;
  final double? existingLatitude;
  final double? existingLongitude;

  @override
  State<OfficeCaptureFields> createState() => _OfficeCaptureFieldsState();
}

class _OfficeCaptureFieldsState extends State<OfficeCaptureFields> {
  XFile? _photo;
  _LocationCaptureState _locationState = _LocationCaptureState.idle;
  String _locationError = '';
  (double, double)? _capturedCoords;

  Future<void> _takePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked == null) return;
    setState(() => _photo = picked);
    widget.onPhotoSelected(picked);
  }

  void _removePhoto() {
    setState(() => _photo = null);
    widget.onPhotoSelected(null);
  }

  Future<void> _captureLocation() async {
    setState(() {
      _locationState = _LocationCaptureState.capturing;
      _locationError = '';
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Location services are turned off.';
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw 'Location permission was denied.';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
      setState(() {
        _capturedCoords = (position.latitude, position.longitude);
        _locationState = _LocationCaptureState.success;
      });
      widget.onLocationCaptured(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _locationState = _LocationCaptureState.error;
        _locationError = e is String ? e : 'Could not get your location.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasExistingPhoto = widget.existingPhotoUrl != null;
    final hasExistingLocation = widget.existingLatitude != null && widget.existingLongitude != null;
    final hasExistingDemoAppInstalled = widget.demoAppInstalled == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hasExistingPhoto) ...[
          MyText.bodySmall('Office Photo'),
          MySpacing.height(8),
          if (_photo != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(File(_photo!.path), width: 160, height: 160, fit: BoxFit.cover),
            ),
            MySpacing.height(4),
            MyButton.text(onPressed: _removePhoto, child: MyText.bodySmall('Remove')),
          ] else
            MyButton.outlined(
              onPressed: _takePhoto,
              child: MyText.bodySmall('Take Office Photo'),
            ),
          MySpacing.height(16),
        ],
        if (!hasExistingLocation) ...[
          MyText.bodySmall('Office Location'),
          MySpacing.height(8),
          MyButton.outlined(
            onPressed: _locationState == _LocationCaptureState.capturing ? null : _captureLocation,
            child: MyText.bodySmall(_locationState == _LocationCaptureState.capturing ? 'Capturing…' : '📍 Capture Current Location'),
          ),
          if (_locationState == _LocationCaptureState.success && _capturedCoords != null)
            Padding(
              padding: MySpacing.top(4),
              child: MyText.bodySmall(
                '✓ Location captured (${_capturedCoords!.$1.toStringAsFixed(5)}, ${_capturedCoords!.$2.toStringAsFixed(5)})',
                color: Colors.green,
              ),
            ),
          if (_locationState == _LocationCaptureState.error)
            Padding(
              padding: MySpacing.top(4),
              child: MyText.bodySmall(_locationError, color: Theme.of(context).colorScheme.error),
            ),
          MySpacing.height(16),
        ],
        if (!hasExistingDemoAppInstalled) ...[
          MyText.bodySmall('Demo App Installed'),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: widget.demoAppInstalled,
                onChanged: widget.onDemoAppInstalledChange,
              ),
              MyText('Yes'),
              MySpacing.width(16),
              Radio<bool>(
                value: false,
                groupValue: widget.demoAppInstalled,
                onChanged: widget.onDemoAppInstalledChange,
              ),
              MyText('No'),
            ],
          ),
        ],
      ],
    );
  }
}
