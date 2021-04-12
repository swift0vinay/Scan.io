import 'dart:io';

class SimpleFileModel {
  String filePath;
  int filterType;
  File file;
  SimpleFileModel({
    this.filePath,
    this.file,
    this.filterType,
  });

  SimpleFileModel fromMap(Map<String, dynamic> map) {
    return SimpleFileModel(
      filePath: map['filePath'],
      file: new File(map['filePath']),
      filterType: map['filterType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'filePath': filePath,
      'filterType': filterType,
    };
  }
}
