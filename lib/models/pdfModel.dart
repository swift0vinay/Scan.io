import 'package:scan_io/models/simpleFileModel.dart';

class PdfModel {
  List<SimpleFileModel> modelList;
  String fileName;
  PdfModel({this.fileName, this.modelList});

  Map<String, dynamic> listToMap() {
    Map<String, dynamic> map = {};
    for (SimpleFileModel model in modelList) {
      map.putIfAbsent(model.filePath, () => model.toMap());
    }
    return map;
  }

  List<SimpleFileModel> listFromMap(Map<String, dynamic> map) {
    List<SimpleFileModel> models = [];
    map.forEach((key, value) {
      Map<String, dynamic> maps = Map.from(value);
      SimpleFileModel simpleFileModel = SimpleFileModel().fromMap(maps);
      models.add(simpleFileModel);
    });
    return models;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fileName': fileName,
      'modelList': listToMap(),
    };
  }

  PdfModel fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> modelMap = Map.from(map['modelList']);
    List<SimpleFileModel> models = listFromMap(modelMap);
    return PdfModel(fileName: map['fileName'], modelList: models);
  }

  String toString() {
    return '[ $fileName ${modelList.length} ]';
  }
}
