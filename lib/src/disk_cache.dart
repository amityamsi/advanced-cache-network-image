import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

class DiskCache {
  Future<File> getFile(String url) async {
    final dir = await getTemporaryDirectory();

    final key = md5.convert(utf8.encode(url)).toString();

    final file = File("${dir.path}/$key");

    return file;
  }
}
