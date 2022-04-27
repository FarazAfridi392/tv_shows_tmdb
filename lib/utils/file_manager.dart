import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:tv_shows_tmdb/utils/constants.dart';

Future<bool> _write({required String text, required String root}) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/$root');
  try {
    await file.writeAsString(text);
    return true;
  } catch (e, s) {
    print(e);
    print(s);
    return false;
  }
}

Future<String> _read({required String root}) async {
  String text;
  try {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/$root');
    text = await file.readAsString();
  } catch (e) {
    print(e);
    text = "";
  }
  return text;
}

Future<bool> saveTheme({required String color}) async {
  return await _write(text: color, root: "color.txt");
}

Future<bool> addFavorite({required String tvSID}) async {
  List<String> listedText = await getFavoritesID();
  bool result = false;
  if (!listedText.contains(tvSID)) {
    listedText.insert(0, tvSID);
    result = await _write(text: listedText.join(';'), root: "favorite.txt");
  }
  return result;
}

Future<bool> removeFavorite({required String tvSID}) async {
  List<String> listedText = await getFavoritesID();
  bool result = false;
  try {
    
    listedText.remove(tvSID);
    result = await _write(text: listedText.join(';'), root: "favorite.txt");
  } catch (e, s) {
    print(s);
    result = false;
  }
  return result;
}

Future<Color> currentTheme() async {
  Color color;
  String text = await _read(root: "color.txt");
  switch (text) {
    case "orange":
      color = kMainOrangeColor;
      break;
    case "blue":
      color = kMainBlueColor;
      break;
    case "pink":
      color = kMainPinkColor;
      break;
    default:
      color = kMainGreenColor;
  }

  return Future.value(color);
}

Future<bool> isTVShowInFavorites({required String tvSID}) async {
  String result = await _read(root: "favorite.txt");
  return result.split(';').contains(tvSID);
}

Future<List<String>> getFavoritesID() async {
  String result = await _read(root: "favorite.txt");
  return result.split(';');
}
