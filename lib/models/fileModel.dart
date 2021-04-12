
class FileModel {
  int fileSize;
  String filesSizeString;
  String fileName;
  DateTime lastModified;
  String creationDate;
  String filePath;
  FileModel({
    this.filePath,
    this.fileName,
    this.lastModified,
    this.fileSize,
    this.filesSizeString,
    this.creationDate,
  });
}