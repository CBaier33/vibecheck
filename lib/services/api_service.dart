import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String _apiKey =
      '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'; // Replace with your actual API key

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

  final Map<String, String> audioEmotionPairNames = {
    'angry_calm': "Vehemence",
    'angry_disgust': "Revulsion",
    'angry_fearful': "Dread",
    'angry_happy': "Jubilance",
    'angry_neutral': "Apathy",
    'angry_sad': "Sorrow",
    'angry_surprised': "Shock",
    'calm_disgust': "Repulsion",
    'calm_fearful': "Anxiety",
    'calm_happy': "Serenity",
    'calm_neutral': "Equanimity",
    'calm_sad': "Melancholy",
    'calm_surprised': "Awakening",
    'disgust_fearful': "Horror",
    'disgust_happy': "Contradiction",
    'disgust_neutral': "Indifference",
    'disgust_sad': "Despair",
    'disgust_surprised': "Astonishment",
    'fearful_happy': "Elation",
    'fearful_neutral': "Unease",
    'fearful_sad': "Despondency",
    'fearful_surprised': "Trepidation",
    'happy_neutral': "Contentment",
    'happy_sad': "Bittersweet",
    'happy_surprised': "Amazement",
    'neutral_sad': "Nostalgia",
    'neutral_surprised': "Intrigue",
    'sad_surprised': "Disbelief",
  };

// Function to get emotion name based on List<Color>
  String? getAudioEmotionPairName(String emotions) {
    return audioEmotionPairNames[emotions];
  }

  Future<List<dynamic>?> sendToAudioModel(String filePath) async {
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

        List<String> emotions =
            topResults.map((result) => result['label'].toString()).toList();

        emotions.sort();

        return [newColors, emotions];
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
