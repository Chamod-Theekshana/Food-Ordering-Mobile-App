import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageService {
  static const String baseUrl = 'http://localhost:8080/api';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/image'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      
      var response = await request.send();
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseData);
        return jsonData['url'];
      }
      return null;
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }
}