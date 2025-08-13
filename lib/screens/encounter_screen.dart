import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';

class EncounterScreen extends ConsumerStatefulWidget {
  const EncounterScreen({super.key});

  @override
  ConsumerState<EncounterScreen> createState() => _EncounterScreenState();
}

class _EncounterScreenState extends ConsumerState<EncounterScreen> {
  bool _cdsExpanded = false;
  bool _notesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Encounter',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: profileAsync.when(
                data: (profile) {
                  final avatarUrl = profile?['avatarUrl'] as String?;
                  return CircleAvatar(
                    radius: 18,
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const NetworkImage('https://img.freepik.com/free-icon/user_318-159711.jpg'),
                  );
                },
                loading: () => const CircleAvatar(radius: 18, child: CircularProgressIndicator()),
                error: (_, __) => const CircleAvatar(radius: 18, child: Icon(Icons.error)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Audio Recorder UI
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(128, 128, 128, 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.blue,
                        size: 32,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop, color: Colors.red, size: 32),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 24,
                                    child: CustomPaint(
                                      painter: _WaveformPainter(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '0:00',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.black54),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // CDs Dropdown
              ExpansionTile(
                leading: const Icon(Icons.folder_copy_outlined),
                title: const Text(
                  'CDs',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: _cdsExpanded,
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    _cdsExpanded = expanded;
                  });
                },
                children: [
                  const SizedBox(height: 8),
                  // Suggested Interventions
                  const _SuggestionCard(
                    title: 'Suggested Interventions',
                    items: [
                      'Start physical therapy sessions to improve mobility and reduce chronic joint pain.',
                      'Prescribe antibiotics to treat bacterial throat infections and provide symptom relief.',
                      'Initiate a controlled diet and exercise plan for managing Type 2 Diabetes.',
                      'Administer bronchodilators to alleviate acute asthma symptoms.',
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Suggested Tests
                  const _SuggestionCard(
                    title: 'Suggested Tests',
                    items: [
                      'Perform an MRI scan to assess soft tissue and ligament damage.',
                      'Conduct a throat culture test to confirm the presence of streptococcal bacteria.',
                      'Perform an HbA1c test to monitor long-term blood sugar levels.',
                      'Conduct a pulmonary function test (spirometry) to evaluate lung capacity and airflow.',
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _SuggestionCard(
                    title: 'Suggested Questions',
                    items: [],
                    showAdd: true,
                  ),
                ],
              ),

              // Suggested Questions
              const SizedBox(height: 12),
              // Notes
              ExpansionTile(
                leading: const Icon(Icons.edit_note_outlined),
                title: const Text(
                  'Notes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: _notesExpanded,
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    _notesExpanded = expanded;
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Generate Notes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _NotesCard(
                          title: 'Chief Complaints',
                          items: const [
                            'Fever and body aches lasting for more than three days, accompanied by fatigue and chills.',
                            'Severe abdominal pain localized to the lower right side, with nausea and loss of appetite.',
                            'Persistent cough and shortness of breath, especially during physical activities or at night.',
                            'Headache and dizziness, often triggered by standing up, with occasional blurred vision.',
                          ],
                        ),
                        const SizedBox(height: 16),
                        _NotesCard(
                          title: 'History of Present Illness',
                          items: const [
                            'Gradual onset of high fever for the past five days, accompanied by chills, sweating, and generalized weakness, with no significant relief from over-the-counter medications.',
                            'Intermittent headaches over the past month, usually occurring in the morning, with associated lightheadedness and occasional blurry vision, aggravated by skipping meals or dehydration.',
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Conversation
              ExpansionTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: const Text(
                  'Conversation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0.0,
                      vertical: 8.0,
                    ),
                    child: _ConversationCard(
                      messages: const [
                        _ConversationMessage(
                          sender: 'PT',
                          text:
                              "Doctor, I've been having severe stomach pain for the past two days. It feels like it's getting worse, especially after eating.",
                        ),
                        _ConversationMessage(
                          sender: 'DR',
                          text:
                              "I understand, Meera. Of course, I'll examine your abdomen and ask a few more questions to narrow down the cause. Have you noticed any other symptoms, like nausea, vomiting, or changes in your bowel habits?",
                        ),
                        _ConversationMessage(
                          sender: 'PT',
                          text:
                              "Yes, I've felt nauseous, but I haven't vomited. My stools have been irregular, and I feel bloated most of the time.",
                        ),
                        _ConversationMessage(
                          sender: 'DR',
                          text:
                              "Doctor, I've been having severe stomach pain for the past two days. It feels like it's getting worse, especially after eating.",
                        ),
                        _ConversationMessage(
                          sender: 'PT',
                          text:
                              "Doctor, I've been having severe stomach pain for the past two days. It feels like it's getting worse, especially after eating.",
                        ),
                        _ConversationMessage(
                          sender: 'DR',
                          text:
                              "That's helpful to know. It sounds like this could be related to indigestion, an infection, or even a gastric ulcer. Have you eaten anything unusual recently or taken any medications that upset your stomach?",
                        ),
                        _ConversationMessage(
                          sender: 'PT',
                          text:
                              "I ate some street food three days ago, but I didn't feel anything until the day after. I also took some painkillers last week for a headache.",
                        ),
                        _ConversationMessage(
                          sender: 'DR',
                          text:
                              "Street food and painkillers could both be contributing factors. I'll suggest running some tests, including an abdominal ultrasound and a stool test, to check for infections or inflammation.",
                        ),
                        _ConversationMessage(
                          sender: 'PT',
                          text:
                              "Okay, Doctor. Do I need to follow any specific diet or medication in the meantime?",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool showAdd;
  const _SuggestionCard({
    required this.title,
    required this.items,
    this.showAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (showAdd || items.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: () {},
                ),
            ],
          ),
          if (items.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < items.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${i + 1}. ${items[i]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[200]!
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    // Draw a simple waveform
    for (int i = 0; i < size.width; i += 8) {
      final y = (size.height / 2) + (size.height / 3) * (i % 16 == 0 ? 1 : -1);
      canvas.drawLine(
        Offset(i.toDouble(), size.height / 2),
        Offset(i.toDouble(), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotesCard extends StatelessWidget {
  final String title;
  final List<String> items;
  const _NotesCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.blue,
                  size: 28,
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${i + 1}. ${items[i]}',
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final List<_ConversationMessage> messages;
  const _ConversationCard({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final msg in messages) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.sender,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: msg.sender == 'DR' ? Colors.blue : Colors.black,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.sender == 'DR' ? Colors.blue : Colors.black,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _ConversationMessage {
  final String sender;
  final String text;
  const _ConversationMessage({required this.sender, required this.text});
}
