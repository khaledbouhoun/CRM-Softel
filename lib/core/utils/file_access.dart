import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

/// A file chosen by the employee (attachment or installer).
class PickedFile {
  const PickedFile({required this.name, required this.path, required this.size});

  final String name;
  final String path;
  final int size;

  String get extension => FileAccess.extensionOf(name);
}

/// Everything the app needs from the local file system, in one place: native
/// file dialogs, saving downloads and opening them. Pure helpers are static
/// and unit tested; the dialogs themselves are not testable headlessly.
class FileAccess {
  const FileAccess._();

  /// Extensions the CRM accepts for staff replies (`crm.uploads`).
  static const attachmentExtensions = [
    'pdf',
    'docx',
    'txt',
    'exe',
    'zip',
    'rar',
    'jpg',
    'jpeg',
    'png',
  ];

  /// Extensions accepted for a product image (server limit: 5 MB).
  static const productImageExtensions = ['png', 'jpg', 'jpeg', 'webp', 'svg'];

  /// Extensions of a release installer.
  static const installerExtensions = ['exe', 'zip', 'rar'];

  /// Lower-case extension without the dot ('' when there is none).
  static String extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  static const _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp'};

  static bool isImage({String? mime, String? name}) =>
      (mime?.toLowerCase().startsWith('image/') ?? false) ||
      _imageExtensions.contains(extensionOf(name ?? ''));

  static bool isPdf({String? mime, String? name}) =>
      mime?.toLowerCase() == 'application/pdf' || extensionOf(name ?? '') == 'pdf';

  /// Removes path separators and characters Windows refuses in file names.
  static String sanitizeFileName(String name) {
    final cleaned = name
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_')
        .trim()
        .replaceAll(RegExp(r'^\.+'), '');
    return cleaned.isEmpty ? 'file' : cleaned;
  }

  /// `report.pdf` -> `report (1).pdf` -> `report (2).pdf`... until [exists]
  /// says the name is free.
  static String uniqueName(String name, bool Function(String) exists) {
    if (!exists(name)) return name;
    final dot = name.lastIndexOf('.');
    final stem = dot > 0 ? name.substring(0, dot) : name;
    final ext = dot > 0 ? name.substring(dot) : '';
    for (var i = 1; i < 1000; i++) {
      final candidate = '$stem ($i)$ext';
      if (!exists(candidate)) return candidate;
    }
    return '$stem (${DateTime.now().millisecondsSinceEpoch})$ext';
  }

  /// Opens the native multi-file dialog restricted to [extensions].
  static Future<List<PickedFile>> pick({
    required List<String> extensions,
    bool multiple = true,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: multiple,
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    if (result == null) return const [];
    return [
      for (final f in result.files)
        if (f.path != null) PickedFile(name: f.name, path: f.path!, size: f.size),
    ];
  }

  /// The user's Downloads folder, or the temp folder when it cannot be found.
  static Directory downloadsDirectory() {
    final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
    if (home != null) {
      final dir = Directory('$home${Platform.pathSeparator}Downloads');
      if (dir.existsSync()) return dir;
    }
    return Directory.systemTemp;
  }

  static Directory tempDirectory() => Directory.systemTemp;

  /// Allocates a free path for [name] inside [dir] (never overwrites).
  static String freePath(Directory dir, String name) {
    final safe = sanitizeFileName(name);
    final unique = uniqueName(
      safe,
      (n) => File('${dir.path}${Platform.pathSeparator}$n').existsSync(),
    );
    return '${dir.path}${Platform.pathSeparator}$unique';
  }

  /// Saves [bytes] under [name] in [dir] and returns the written path.
  static Future<String> saveBytes(Directory dir, String name, Uint8List bytes) async {
    final path = freePath(dir, name);
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  /// Opens [path] with the application associated by the OS.
  static Future<bool> open(String path) =>
      launchUrl(Uri.file(path), mode: LaunchMode.externalApplication);
}
