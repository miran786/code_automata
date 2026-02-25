import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isListening = false;

  // Speech & TTS
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  // Gemini config
  static const String apiKey = 'AIzaSyAU1yg56DP_TDkfoHjDr1QGzC_u94KFn5Y';
  static const String modelName = 'gemini-2.5-flash';

  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();

    // Initialize Gemini model with system instruction
    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: Content.text(
        'You are a preventive health assistant. '
        'Answer only health-related questions. '
        'Be empathetic. Never diagnose. '
        'Always suggest consulting a doctor.',
      ),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 400,
      ),
    );
    _chat = _model.startChat();

    // Welcome message
    _addBotMessage(
      "Hello Aarya! I'm your preventive health companion.\n\n"
      "I can help with:\n"
      "• Understanding your vitals\n"
      "• Diet & lifestyle suggestions\n"
      "• General wellness questions\n"
      "• Explaining symptoms in simple terms\n\n"
      "Important: I'm not a doctor — always consult a healthcare professional.\n\n"
      "How can I assist you today? (tap 🎤 to speak)",
    );
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );
    if (!available) {
      _addBotMessage("Speech recognition is not available on this device.");
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-IN"); // Indian English
    await _flutterTts.setSpeechRate(0.9);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          cancelOnError: true,
          localeId: "en_IN",
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'role': 'assistant', 'content': text});
    });
    _speak(text); // Auto-read bot reply
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': userMessage});
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(userMessage));
      final botReply =
          response.text?.trim() ?? "Sorry, I couldn't generate a response.";
      _addBotMessage(botReply);
    } catch (e) {
      _addBotMessage("Error: $e\nPlease check your internet connection.");
    }

    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 380;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Assistant – Gemini'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 10 : 14,
                vertical: 12,
              ),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final msg = _messages[index];
                final isUser = msg['role'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 14 : 18,
                      vertical: isSmall ? 10 : 12,
                    ),
                    constraints: BoxConstraints(maxWidth: size.width * 0.78),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['content']!,
                      style: TextStyle(
                        fontSize: isSmall ? 15 : 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input area with voice button
          Container(
            padding: EdgeInsets.all(isSmall ? 8 : 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : null,
                  ),
                  onPressed: _listen,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about health, diet, vitals...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isSmall ? 12 : 14,
                      ),
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }
}
