import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String _apiKey = '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'; // Replace with your actual API key

  // Rainbow colors mapped to emotion labels
  final Map<String, Color> emotionBaseColors = {
    'angry': Colors.red,
    'calm': Colors.green,
    'disgust': Colors.green.shade700,
    'fearful': Colors.deepPurple,
    'happy': Colors.yellow,
    'neutral': Color(0xFFD2B48C),
    'sad': Colors.blue,
    'surprised': Colors.orange,
  };

  Future<List<Color>?> sendToAudioModel(String filePath) async {
    final url = Uri.parse(
      'https://api-inference.huggingface.co/models/ehcalabres/wav2vec2-lg-xlsr-en-speech-emotion-recognition/',
    );

    try {
      File audioFile = File(filePath);
      List<int> fileBytes = await audioFile.readAsBytes();

      var request = http.Request('POST', url)
        ..headers['Authorization'] = 'Bearer $_apiKey'
        ..bodyBytes = fileBytes;

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        List<dynamic> resultList = jsonDecode(responseBody);

        resultList.sort(
                (a, b) => (b['score'] as double).compareTo(a['score'] as double));

        final topResults = resultList.take(2).toList();

        List<Color> newColors = topResults
            .map((result) => emotionBaseColors[result['label']] ?? Colors.grey)
            .toList();

        // Display the results
        for (var result in topResults) {
          print('Label: ${result['label']}, Score: ${result['score']}');
        }

        return newColors;
      } else {
        print("Failed to send file: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error occurred: $e");
      return null;
    }
  }
}
