import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/app_drawer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class AskAIScreen extends ConsumerStatefulWidget {
  const AskAIScreen({super.key});

  @override
  ConsumerState<AskAIScreen> createState() => _AskAIScreenState();
}

class _AskAIScreenState extends ConsumerState<AskAIScreen> {
  int _selectedIndex = 2;

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final aiText = '';

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/main');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/inbox');
    }
  }

  void _sendMessage() async{
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.insert(0, {
        'isUser': true,
        'text': text,
        'avatar': 'assets/avatar.png',
        'image': null,
      });
      _controller.clear();
    });
       // ... inside your widget or a dedicated service class
    final model = GenerativeModel(model:'gemini-2.5-flash', apiKey: dotenv.env['API_KEY'] ?? '');
    final prompt = text;
    try{
      final response = await model.generateContent([Content.text(prompt)],);
      final aiText = response.text is String ? response.text : response.text?.toString() ?? 'No response';
      setState(() {
        _messages.insert(0, {
          'isUser': false,
          'text': aiText,
          'avatar': 'https://robohash.org/ai-avatar',
          'image': null,
        });
      });
    }catch(e){
      print(e);
      setState(() {
        _messages.insert(0, {
        'isUser': false,
        'text': 'Something went wrong',
        'avatar': 'https://robohash.org/ai-avatar',
        'image': null,
      });
      });
    }
  }

  void _onMicPressed() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      // Request permission
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required to use voice input.'),
            ),
          );
        }
        return;
      }
    }
    // Permission granted, but actual recording will be implemented later
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission granted. Voice input coming soon!'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Ask AI',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 18),
          // Chat area
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg['isUser'] == true) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(right: 18, top: 8, left: 60),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            msg['text'],
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, top: 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage('assets/avatar.png'),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(left: 18, top: 18, right: 60),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF6FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            msg['text'] is String ? msg['text'] : msg['text'].toString(),
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(msg['avatar']),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          // Input bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type here...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GestureDetector(
                    onTap: _onMicPressed,
                    child: const Icon(Icons.mic, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}