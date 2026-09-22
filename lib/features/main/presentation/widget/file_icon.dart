import 'package:flutter/material.dart';
import 'package:omni_preview/core/utililty/utility.dart';

class FileIcon extends StatelessWidget {
  final String filePath;
  const FileIcon({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    String extension = getExtension(filePath);
    Color color = setColorByExtension(extension);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color.fromARGB(23, 255, 255, 255),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Stack(
        children: [
          Center(child: Icon(Icons.insert_drive_file, color: color)),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  (extension.length > 5)
                      ? extension.toUpperCase().substring(0, 5)
                      : extension.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
