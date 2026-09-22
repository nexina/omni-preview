import 'package:file_picker/file_picker.dart';

Future<PlatformFile?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null && result.files.isNotEmpty) {
    return result.files.first;
  }
  return null;
}
