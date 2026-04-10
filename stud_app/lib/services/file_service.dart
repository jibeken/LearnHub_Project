import 'package:file_picker/file_picker.dart';

class FileService {
  ///один файл любого типа
  static Future<({String name, String path})?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return null;
    return (name: result.files.single.name, path: result.files.single.path!);
  }

  ///несколько файлов любого типа
  static Future<List<({String name, String path})>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null) return [];
    return result.files
        .where((f) => f.path != null)
        .map((f) => (name: f.name, path: f.path!))
        .toList();
  }

  ///выбрать изображения
  static Future<List<({String name, String path})>> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null) return [];
    return result.files
        .where((f) => f.path != null)
        .map((f) => (name: f.name, path: f.path!))
        .toList();
  }

  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String extensionLabel(String fileName) {
    final ext = fileName.split('.').last.toUpperCase();
    return ext.length > 4 ? ext.substring(0, 4) : ext;
  }

  static bool isImage(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  static bool isAudio(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return ['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(ext);
  }
}
