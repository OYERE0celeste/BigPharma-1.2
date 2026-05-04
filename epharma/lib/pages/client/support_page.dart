import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/support_provider.dart';
import '../../models/support_model.dart';
import '../../widgets/app_colors.dart';

class ClientSupportPage extends StatefulWidget {
  const ClientSupportPage({super.key});

  @override
  State<ClientSupportPage> createState() => _ClientSupportPageState();
}

class _ClientSupportPageState extends State<ClientSupportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mes Questions', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: () => _showNewQuestionDialog(context),
            icon: const Icon(Icons.add_comment_outlined, color: kAccentBlue),
          ),
        ],
      ),
      body: Consumer<SupportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Vous n\'avez pas encore posé de questions'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showNewQuestionDialog(context),
                    style: ElevatedButton.styleFrom(backgroundColor: kAccentBlue, foregroundColor: Colors.white),
                    child: const Text('Poser ma première question'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.questions.length,
            itemBuilder: (context, index) {
              final q = provider.questions[index];
              return _buildQuestionCard(q);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(SupportQuestion q) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => _navigateToChat(q),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      q.subject,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  _buildStatusChip(q),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                q.messages.last.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dernière activité: ${_formatDate(q.updatedAt)}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(SupportQuestion q) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: q.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        q.statusLabel,
        style: TextStyle(color: q.statusColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showNewQuestionDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nouvelle Question', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Sujet',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Votre message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (subjectController.text.isNotEmpty && contentController.text.isNotEmpty) {
                    await context.read<SupportProvider>().createQuestion(
                      subjectController.text,
                      contentController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Envoyer'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _navigateToChat(SupportQuestion q) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClientChatPage(question: q)),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class ClientChatPage extends StatefulWidget {
  final SupportQuestion question;
  const ClientChatPage({super.key, required this.question});

  @override
  State<ClientChatPage> createState() => _ClientChatPageState();
}

class _ClientChatPageState extends State<ClientChatPage> {
  late SupportQuestion _currentQuestion;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.question;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentQuestion.subject),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _currentQuestion.messages.length,
              itemBuilder: (context, index) {
                final msg = _currentQuestion.messages[index];
                final isMe = msg.senderType == 'client';
                
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isMe ? kAccentBlue : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.content,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(color: isMe ? Colors.white70 : Colors.grey[600], fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_currentQuestion.status != 'ferme')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Votre message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: kAccentBlue),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final content = _messageController.text.trim();
    _messageController.clear();
    
    try {
      await context.read<SupportProvider>().sendMessage(_currentQuestion.id, content);
      setState(() {
        _currentQuestion = context.read<SupportProvider>().questions.firstWhere((q) => q.id == _currentQuestion.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }
}
