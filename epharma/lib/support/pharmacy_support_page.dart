import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/support_provider.dart';
import '../../models/support_model.dart';
import '../../widgets/app_colors.dart';

class PharmacySupportPage extends StatefulWidget {
  const PharmacySupportPage({super.key});

  @override
  State<PharmacySupportPage> createState() => _PharmacySupportPageState();
}

class _PharmacySupportPageState extends State<PharmacySupportPage> {
  SupportQuestion? _selectedQuestion;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().loadQuestions();
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // Left Side: Question List
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                children: [
                  _buildListHeader(),
                  Expanded(child: _buildQuestionList()),
                ],
              ),
            ),
          ),
          
          // Right Side: Details/Conversation
          Expanded(
            flex: 3,
            child: _selectedQuestion == null
                ? _buildNoSelection()
                : _buildConversation(),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Support Client',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            'Répondez aux questions de vos clients',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          // Filter tabs can go here
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    return Consumer<SupportProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.questions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Aucune question pour le moment', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: provider.questions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final q = provider.questions[index];
            final isSelected = _selectedQuestion?.id == q.id;
            
            return ListTile(
              onTap: () {
                setState(() {
                  _selectedQuestion = q;
                });
              },
              selected: isSelected,
              selectedTileColor: kAccentBlue.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      q.subject,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  _buildStatusChip(q),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.clientName, style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      q.messages.last.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

  Widget _buildNoSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 24),
          Text(
            'Sélectionnez une discussion pour commencer',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildConversation() {
    final q = _selectedQuestion!;
    
    return Column(
      children: [
        // Conversation Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: kAccentBlue.withOpacity(0.1),
                child: Text(q.clientName[0], style: const TextStyle(color: kAccentBlue)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('De: ${q.clientName}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              if (q.status != 'ferme')
                TextButton.icon(
                  onPressed: () async {
                    await context.read<SupportProvider>().closeQuestion(q.id);
                    setState(() {
                      _selectedQuestion = context.read<SupportProvider>().questions.firstWhere((element) => element.id == q.id);
                    });
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Clôturer'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
            ],
          ),
        ),
        
        // Messages list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: q.messages.length,
            itemBuilder: (context, index) {
              final msg = q.messages[index];
              final isMe = msg.senderType == 'pharmacie';
              
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    color: isMe ? kAccentBlue : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.content,
                        style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(msg.createdAt),
                        style: TextStyle(color: isMe ? Colors.white70 : Colors.grey[400], fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Reply Box
        if (q.status != 'ferme')
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Tapez votre réponse...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton.filled(
                  onPressed: _sendReply,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: kAccentBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _sendReply() async {
    if (_replyController.text.trim().isEmpty) return;
    
    final content = _replyController.text.trim();
    _replyController.clear();
    
    try {
      await context.read<SupportProvider>().sendMessage(_selectedQuestion!.id, content);
      setState(() {
        _selectedQuestion = context.read<SupportProvider>().questions.firstWhere((q) => q.id == _selectedQuestion!.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
