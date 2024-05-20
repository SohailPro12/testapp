import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:testapp/services/crud2/firestore.dart';

class FitMeAIView extends StatefulWidget {
  const FitMeAIView({Key? key}) : super(key: key);

  @override
  _FitMeAIViewState createState() => _FitMeAIViewState();
}

class _FitMeAIViewState extends State<FitMeAIView> {
  final TextEditingController _userInput = TextEditingController();
  static const apiKey = "AIzaSyDs27HKXbyiQDteepNcZUDcSwYQZCmV55c";
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final List<Message> _messages = [];
  late String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    try {
      final FireStoreService fireStoreService = FireStoreService();
      _userEmail = await fireStoreService.getUserField('email');
    } catch (e) {
      _userEmail = '';
    }
  }

  Future<String> _generateUserPrompt(String userMessage) async {
    if (userMessage.length > 10) {
      final fireStoreService = FireStoreService();
      final userData = await fireStoreService.getUserData(_userEmail);

      final userType = userData['type'];
      final gender = userData['gender'];
      final fullName = userData['full_name'];

      if (userType == 'coach') {
        final yearsOfExperience = userData['Years Of Experience'];
        final domain = userData['Domain'];
        final availability = userData['Availability'];
        final website = userData['Website'];
        final bio = userData['Bio'];
        return '$userMessage. Based on this information: my name is $fullName, a $gender coach. My experience in $domain spans $yearsOfExperience years. I am available $availability. Visit my website $website also $bio';
      } else {
        final weight = userData['weight'] ?? '';
        final height = userData['height'] ?? '';
        return '$userMessage. Based on this information: my name is $fullName, $gender. My weight is $weight and my height is $height.';
      }
    } else {
      return userMessage; // Return only user message if it's not long enough
    }
  }

  Future<void> _sendMessage() async {
    final userMessage = _userInput.text.trim(); // Trim whitespace
    if (userMessage.isNotEmpty) {
      final userPrompt = await _generateUserPrompt(userMessage);

      setState(() {
        _messages.add(Message(
          isUser: true,
          message: userPrompt,
          date: DateTime.now(),
        ));
        _userInput.clear();
      });

      final content = [Content.text(userMessage)]; // Send only user's message
      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(
          isUser: false,
          message: response.text ?? "",
          date: DateTime.now(),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FitMeAI Chat'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.8),
              BlendMode.dstATop,
            ),
            image: AssetImage('assets/images/fitme.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true, // Reverse the scroll
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: _messages.map((message) {
                      return Messages(
                        isUser: message.isUser,
                        message: message.message,
                        date: DateFormat('HH:mm').format(message.date),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      controller: _userInput,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        labelText: 'Enter Your Message',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: const EdgeInsets.all(12),
                    iconSize: 30,
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({required this.isUser, required this.message, required this.date});
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    Key? key,
    required this.isUser,
    required this.message,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int index = message.indexOf('based on this information');
    final String mainMessage =
        index == -1 ? message : message.substring(0, index).trim();
    final String detailsMessage =
        index == -1 ? '' : message.substring(index).trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.blueAccent : Colors.grey.shade400,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          bottomLeft: isUser ? const Radius.circular(10) : Radius.zero,
          topRight: const Radius.circular(10),
          bottomRight: isUser ? Radius.zero : const Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mainMessage,
            style: TextStyle(
              fontSize: 16,
              color: isUser ? Colors.white : Colors.black,
            ),
          ),
          if (detailsMessage.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              detailsMessage,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isUser
                    ? Colors.white.withOpacity(0.6)
                    : Colors.black.withOpacity(0.6),
              ),
            ),
          ],
          Text(
            date,
            style: TextStyle(
              fontSize: 10,
              color: isUser ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
