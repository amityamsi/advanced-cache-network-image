import 'package:http/http.dart' as http;
import 'dart:typed_data';

class NetworkFetcher {
  Future<Uint8List> download(String url) async {
    final response = await http.get(Uri.parse(url));

    return response.bodyBytes;
  }
}
