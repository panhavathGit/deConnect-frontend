// lib/core/services/file_picker_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  bool get isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  bool get isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Pick multiple images (up to maxImages)
  Future<List<File>> pickMultipleImages({int maxImages = 100}) async {
    if (isDesktop) {
      const XTypeGroup imageGroup = XTypeGroup(
        label: 'Images',
        extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      );
      final files = await openFiles(acceptedTypeGroups: [imageGroup]);
      return files.take(maxImages).map((f) => File(f.path)).toList();
    } else {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return images.take(maxImages).map((f) => File(f.path)).toList();
    }
  }

  /// Pick multiple files (up to maxFiles)
  Future<List<File>> pickMultipleFiles({
    int maxFiles = 20,
    int maxFileSizeBytes = 150 * 1024 * 1024,
  }) async {
    const XTypeGroup allGroup = XTypeGroup(
      label: 'All Files',
      extensions: [
        'jpg', 'jpeg', 'png', 'gif', 'webp',
        'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
        'txt', 'csv', 'zip', 'mp3', 'wav', 'mp4', 'mov'
      ],
    );
    final files = await openFiles(acceptedTypeGroups: [allGroup]);
    
    final validFiles = <File>[];
    for (final xfile in files.take(maxFiles)) {
      final file = File(xfile.path);
      final size = await file.length();
      if (size <= maxFileSizeBytes) {
        validFiles.add(file);
      }
    }
    return validFiles;
  }

  /// Take a photo using camera
  Future<File?> takePhoto() async {
    if (!isMobile) return null;
    
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    return image != null ? File(image.path) : null;
  }

  /// Record a video using camera
  Future<File?> recordVideo() async {
    if (!isMobile) return null;
    
    final video = await _imagePicker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );
    return video != null ? File(video.path) : null;
  }
}