import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Gemini");

  Map<String, String> _userResponses = {};
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  bool _questionnaireCompleted = false;
  bool _isOnline = true;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the temperature in your region?',
      'options': ['Cool (0-10°C)', 'Mild (10-20°C)', 'Warm (20-30°C)', 'Hot (30°C+)'],
    },
    {
      'question': 'What is the humidity level in your region?',
      'options': ['Low', 'Medium', 'High', 'Very High'],
    },
    {
      'question': 'What is the size of your house?',
      'options': ['Small (<50m²)', 'Medium (50-200m²)', 'Large (200-600m²)', 'Very Large (600m²+)'],
    },
    {
      'question': 'What is your budget for pet maintenance?',
      'options': ['Low (Rs.0-Rs.1000/month)', 'Medium (Rs.1000-Rs.3000/month)', 'High (Rs.3000/month)'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _addQuestion();
    });
  }

    Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(connectivityResult);
    Connectivity().onConnectivityChanged.listen(_updateConnectivityStatus);
  }

  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) return;
    ConnectivityResult result = results.first;
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
    if (_isOnline) {
      _retryFailedRequests();
    } else {
      _showNetworkStatusMessage("No internet connection. Please check your network.");
    }
  }

  void _retryFailedRequests() {
    // Implement logic to retry any failed requests
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gemini Chatbot"),
        centerTitle: true,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (!_isOnline) {
      return Center(child: Text("No internet connection. Please check your network."));
    }
    return Column(
      children: [
        _buildNetworkStatusBar(),
        if (!_questionnaireCompleted) _buildCurrentQuestion(),
        if (_questionnaireCompleted)
          Expanded(
            child: DashChat(
              messageOptions: MessageOptions(
                showTime: false,
                messageTextBuilder: (message, previousMessage, nextMessage) {
                  Color textColor = message.user == currentUser ? Colors.white : Colors.black;
                  return Text.rich(
                    TextSpan(
                      children: _parseText(message.text, textColor),
                    ),
                  );
                },
              ),
              messages: messages,
              onSend: (chatMessage) => _sendMessage(chatMessage),
              currentUser: currentUser,
              messageListOptions: MessageListOptions(
                chatFooterBuilder: Container(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNetworkStatusBar() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isOnline ? 0 : 30,
      color: Colors.red,
      child: Center(
        child: Text(
          "No internet connection",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCurrentQuestion() {
    if (_currentQuestionIndex >= _questions.length) {
      return Container();
    }
    
    Map<String, dynamic> currentQuestion = _questions[_currentQuestionIndex];
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            currentQuestion['question'],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ...currentQuestion['options'].map<Widget>((option) {
            return ElevatedButton(
              onPressed: () => _selectOption(option),
              child: Text(option),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _selectOption(String option) {
    setState(() {
      _userResponses[_questions[_currentQuestionIndex]['question']] = option;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _questionnaireCompleted = true;
        _sendDataToGemini();
      }
    });
  }

  void _sendDataToGemini() {
    setState(() {
      _isLoading = true;
    });

    String fullPrompt = '''
    I want to adopt a pet. The temperature of my city is ${_getTemperature()},
    humidity is ${_getHumidity()}, the size of my house ${_getHouseSize()},
    and my budget of maintenance is ${_getBudget()}.
    Suggest the best possible pet that I can adopt and also suggest the pets that I should not adopt.
    Provide a bulleted approach and include breeds of dogs and cats as a priority in each the best and the worst pets.
    Provide a concise answer and do not provide any tables of comparison and images just stick to the data.
    ''';

    String visiblePrompt = "My Preferences:\nTemperature: ${_getTemperature()}\nHumidity: ${_getHumidity()}\nSize of House: ${_getHouseSize()}\nBudget: ${_getBudget()}";

    _sendMessage(ChatMessage(
      text: visiblePrompt,
      user: currentUser,
      createdAt: DateTime.now(),
    ), fullPrompt);
  }

  String _getTemperature() => _userResponses[_questions[0]['question']] ?? '';
  String _getHumidity() => _userResponses[_questions[1]['question']] ?? '';
  String _getHouseSize() => _userResponses[_questions[2]['question']] ?? '';
  String _getBudget() => _userResponses[_questions[3]['question']] ?? '';

  List<TextSpan> _parseText(String text, Color textColor) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'<b>(.*?)</b>');

    int lastIndex = 0;
    for (Match match in boldPattern.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
            text: text.substring(lastIndex, match.start),
            style: TextStyle(color: textColor)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
          text: text.substring(lastIndex), style: TextStyle(color: textColor)));
    }

    return spans;
  }

  void _sendMessage(ChatMessage chatMessage, [String? fullPrompt]) {
     if (!_isOnline) {
      _showNetworkStatusMessage("No internet connection. Your message will be sent when online.");
      _showErrorMessage("No internet connection. Please check your network.");
      return;
    }
    
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = fullPrompt ?? chatMessage.text;

      gemini.streamGenerateContent(question).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += convertMarkdownToHtml(response);
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: convertMarkdownToHtml(response),
          );
          setState(() {
            messages = [message, ...messages];
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      print(e);
      _showErrorMessage("Failed to send message. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    }

  // void _showErrorMessage(String message) {
  //   setState(() {
  //     messages = [
  //       ChatMessage(
  //         text: message,
  //         user: geminiUser,
  //         createdAt: DateTime.now(),
  //       ),
  //       ...messages
  //     ];
  //   });
  // }

  void _showNetworkStatusMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorMessage(String message) {
    setState(() {
      messages = [
        ChatMessage(
          text: message,
          user: geminiUser,
          createdAt: DateTime.now(),
        ),
        ...messages
      ];
    });
  }

  String convertMarkdownToHtml(String text) {
    return text.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) {
      return '<b>${match.group(1)}</b>';
    });
  }


}
