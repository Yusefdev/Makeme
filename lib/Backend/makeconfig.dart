import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class JsonStore {
  final String fileName;
  late File _jsonFile;
  Map<String, dynamic> _cachedData = {};

  JsonStore(this.fileName);

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _jsonFile = File('${dir.path}/$fileName');

    if (!await _jsonFile.exists()) {
      await _jsonFile.writeAsString(jsonEncode({}));
    }

    await _loadData();
  }

  Future<void> _loadData() async {
    final contents = await _jsonFile.readAsString();
    _cachedData = jsonDecode(contents);
  }

  Map<String, dynamic> get data => Map.unmodifiable(_cachedData);

  dynamic getValue(String key) => _cachedData[key];

  Future<void> setValue(String key, dynamic value) async {
    if (!mapEquals(_cachedData[key], value)) {
      _cachedData[key] = value;
      await _save();
    }
  }

  Future<void> removeValue(String key) async {
    if (_cachedData.containsKey(key)) {
      _cachedData.remove(key);
      await _save();
    }
  }

  Future<void> _save() async {
    await _jsonFile.writeAsString(jsonEncode(_cachedData));
  }
}