import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/chat_message.dart';

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final ScrollController scrollController = ScrollController();

  // Gemini API key
  static const String _apiKey = 'AIzaSyD6_S-1r7wrJ4YWJsAnsfGG-FloktB9pmk';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';

  @override
  void onInit() {
    super.onInit();
    // Thêm tin nhắn chào mừng
    messages.add(
      ChatMessage(
        message:
            'Xin chào! Tôi là trợ lý AI có thể giúp bạn nghiên cứu sâu về thể thao. Bạn muốn hỏi điều gì?',
        isUser: false,
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Thêm tin nhắn người dùng
    final userMessage = ChatMessage(message: text, isUser: true);
    messages.add(userMessage);

    // Bắt đầu tải
    isLoading.value = true;

    try {
      // Gọi API Gemini
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': text}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.2,
            'topP': 0.8,
            'topK': 40,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse = '';

        // Parse phản hồi từ Gemini
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          aiResponse = 'Không thể trích xuất câu trả lời từ AI.';
        }

        // Thêm phản hồi của AI
        messages.add(ChatMessage(message: aiResponse, isUser: false));
      } else {
        // Thêm thông báo lỗi
        messages.add(ChatMessage(
          message: 'Đã xảy ra lỗi: ${response.statusCode}',
          isUser: false,
        ));
      }
    } catch (e) {
      // Thêm thông báo lỗi
      messages.add(ChatMessage(
        message: 'Đã xảy ra lỗi: $e',
        isUser: false,
      ));
    } finally {
      // Kết thúc tải
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
