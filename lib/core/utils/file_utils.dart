// lib/core/utils/file_utils.dart
import 'package:flutter/material.dart';

class FileUtils {
  /// Returns an appropriate icon for a file based on its path extension
  static IconData getFileIcon(String path) {
    final ext = path.split('.').last.toLowerCase();
    return getFileIconFromExtension(ext);
  }

  /// Returns an appropriate icon for a file based on its type string
  static IconData getFileIconFromType(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      case 'spreadsheet':
        return Icons.table_chart;
      case 'presentation':
        return Icons.slideshow;
      case 'video':
        return Icons.video_file;
      case 'audio':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Returns an appropriate icon for a file based on its extension
  static IconData getFileIconFromExtension(String ext) {
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      case 'mp3':
      case 'wav':
      case 'ogg':
        return Icons.audio_file;
      case 'mp4':
      case 'webm':
      case 'mov':
      case '3gp':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Gets the filename from a full path
  static String getFileName(String path) {
    return path.split('/').last;
  }
}