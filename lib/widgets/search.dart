import 'package:scan_io/constants.dart';
import 'package:scan_io/widgets/bottomSheet.dart';
import 'package:scan_io/models/fileModel.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class SearchFile extends SearchDelegate<List<FileModel>> {
  List<FileModel> recentModels;
  SearchFile({this.recentModels});
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  String get searchFieldLabel => "Search Files";

  @override
  TextInputAction get textInputAction => TextInputAction.search;
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 50,
              color: secondary,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Search Files!!",
              style: TextStyle(
                fontSize: 15.0,
                letterSpacing: 1.2,
                color: secondary,
              ),
            ),
          ],
        ),
      );
    } else {
      List<FileModel> suggestions = List.from(
        recentModels.where(
          (element) =>
              element.fileName.toLowerCase().contains(query.toLowerCase()),
        ),
      );
      return suggestions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 50,
                    color: secondary,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "No Results Found!!",
                    style: TextStyle(
                      fontSize: 15.0,
                      letterSpacing: 1.2,
                      color: secondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              itemBuilder: (context, i) {
                String org = suggestions[i].fileName;
                String fileName = suggestions[i].fileName.toLowerCase();
                int part1Index = fileName.indexOf(query.toLowerCase());
                String part1 =
                    part1Index == 0 ? "" : org.substring(0, part1Index);
                String part2 = org.substring(part1Index + query.length);
                String qq =
                    org.substring(part1Index, part1Index + query.length);
                return ListTile(
                  onTap: () async {
                    await OpenFile.open(suggestions[i].filePath);
                  },
                  trailing: IconButton(
                    icon: Icon(
                      Icons.more_vert_rounded,
                    ),
                    onPressed: () {
                      int index = recentModels.indexWhere((element) =>
                          element.fileName == suggestions[i].fileName);
                      showSheet(context, i, index);
                    },
                  ),
                  leading: CircleAvatar(
                    backgroundColor: secondary,
                    child: Text(
                      suggestions[i].fileName[0].toUpperCase(),
                      style: TextStyle(
                        color: white,
                      ),
                    ),
                  ),
                  title: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: part1,
                        style: TextStyle(color: black, fontFamily: "Segoe"),
                      ),
                      TextSpan(
                        text: qq,
                        style: TextStyle(color: primary, fontFamily: "Segoe"),
                      ),
                      TextSpan(
                        text: part2,
                        style: TextStyle(color: black, fontFamily: "Segoe"),
                      ),
                    ]),
                  ),
                  subtitle: Text(
                    suggestions[i].creationDate,
                    style: TextStyle(color: textColor),
                  ),
                );
              },
            );
    }
  }

  deleteFromIndex(int curr, int i) {
    recentModels.removeAt(curr);
  }

  showSheet(BuildContext context, int i, int index) async {
    String file = await showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (context) {
          return MyBottomSheet(
            fileModel: recentModels[index],
            i: i,
            search: true,
          );
        });
    if (file != null) {
      recentModels[index].filePath = file;
      String fileName = recentModels[index]
          .filePath
          .substring(recentModels[i].filePath.lastIndexOf('/') + 1);
      recentModels[index].fileName = fileName;
    }
  }
}
