import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/complaint_model.dart';
import '../models/review_model.dart';
import '../models/support_model.dart';
import '../providers/complaint_provider.dart';
import '../providers/review_provider.dart';
import '../providers/support_provider.dart';
import '../widgets/app_colors.dart';
import '../widgets/app_notification.dart';
import '../widgets/page_stat_cards.dart';

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
      context.read<ReviewProvider>().loadReviews();
      context.read<ComplaintProvider>().loadComplaints();
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      context.read<SupportProvider>().loadQuestions(),
      context.read<ReviewProvider>().loadReviews(),
      context.read<ComplaintProvider>().loadComplaints(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Relation Client',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Suivez les consultations, les avis et les réclamations depuis un seul espace.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _refreshAll,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Actualiser'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const TabBar(
                      labelColor: kAccentBlue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: kAccentBlue,
                      tabs: [
                        Tab(text: 'Questions'),
                        Tab(text: 'Avis'),
                        Tab(text: 'Réclamations'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildQuestionsTab(),
                  _buildReviewsTab(),
                  _buildComplaintsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsTab() {
    final provider = context.watch<SupportProvider>();
    final questions = provider.questions;
    final pending = questions
        .where((question) => question.status == 'en_attente')
        .length;
    final answered = questions
        .where((question) => question.status == 'repondu')
        .length;
    final closed = questions
        .where((question) => question.status == 'ferme')
        .length;
    final messages = questions.fold<int>(
      0,
      (sum, question) => sum + question.messages.length,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PageStatCards(
            items: [
              PageStatCardData(
                label: 'En attente',
                value: '$pending',
                color: Colors.orange,
                icon: Icons.hourglass_top_rounded,
              ),
              PageStatCardData(
                label: 'Répondues',
                value: '$answered',
                color: Colors.green,
                icon: Icons.mark_email_read_outlined,
              ),
              PageStatCardData(
                label: 'Fermées',
                value: '$closed',
                color: Colors.grey,
                icon: Icons.lock_outline_rounded,
              ),
              PageStatCardData(
                label: 'Messages',
                value: '$messages',
                color: Colors.blue,
                icon: Icons.forum_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildQuestionList(provider.questions),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _selectedQuestion == null
                      ? _buildNoSelection()
                      : _buildConversation(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionList(List<SupportQuestion> questions) {
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Aucune question pour le moment',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      separatorBuilder: (_, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final q = questions[index];
        final isSelected = _selectedQuestion?.id == q.id;
        final preview = q.messages.isNotEmpty
            ? q.messages.last.content
            : 'Aucun message';

        return ListTile(
          onTap: () => setState(() => _selectedQuestion = q),
          selected: isSelected,
          selectedTileColor: kAccentBlue.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(12),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  q.subject,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
              _buildSupportStatusChip(q),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.clientName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  preview,
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
  }

  Widget _buildSupportStatusChip(SupportQuestion q) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: q.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        q.statusLabel,
        style: TextStyle(
          color: q.statusColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
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
            'Sélectionnez une conversation pour commencer',
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
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: kAccentBlue.withOpacity(0.1),
                child: Text(
                  q.clientName.isNotEmpty ? q.clientName[0] : '?',
                  style: const TextStyle(color: kAccentBlue),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.subject,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'De: ${q.clientName}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (q.status != 'ferme')
                TextButton.icon(
                  onPressed: () async {
                    await context.read<SupportProvider>().closeQuestion(q.id);
                    if (!mounted) return;
                    setState(() {
                      _selectedQuestion = context
                          .read<SupportProvider>()
                          .questions
                          .firstWhere((element) => element.id == q.id);
                    });
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Clôturer'),
                ),
            ],
          ),
        ),
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
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.content,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(msg.createdAt),
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.grey[400],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (q.status != 'ferme')
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Tapez votre réponse...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    final provider = context.watch<ReviewProvider>();
    final reviews = provider.reviews;
    final average = reviews.isEmpty
        ? 0.0
        : reviews.fold<int>(0, (sum, item) => sum + item.rating) /
              reviews.length;
    final unanswered = reviews.where((review) => !review.hasResponse).length;
    final dissatisfaction = reviews
        .where((review) => review.isLightDissatisfaction)
        .length;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        PageStatCards(
          items: [
            PageStatCardData(
              label: 'Avis',
              value: '${reviews.length}',
              color: Colors.amber.shade700,
              icon: Icons.star_outline_rounded,
            ),
            PageStatCardData(
              label: 'Note moyenne',
              value: average.toStringAsFixed(1),
              color: Colors.orange,
              icon: Icons.grade_outlined,
            ),
            PageStatCardData(
              label: 'À répondre',
              value: '$unanswered',
              color: Colors.blue,
              icon: Icons.chat_outlined,
            ),
            PageStatCardData(
              label: 'Retours sensibles',
              value: '$dissatisfaction',
              color: Colors.deepOrange,
              icon: Icons.report_problem_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 100),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 100),
            child: Center(child: Text('Aucun avis client pour le moment.')),
          )
        else
          ...reviews.map(_buildReviewCard),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        review.clientName,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < review.rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.comment),
            ],
            if (review.serviceComment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Service: ${review.serviceComment}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
            if (review.isLightDissatisfaction) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Insatisfaction légère signalée',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (review.hasResponse) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(review.response!.message),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showReviewResponseDialog(review),
                icon: const Icon(Icons.reply_outlined),
                label: Text(
                  review.hasResponse ? 'Modifier la réponse' : 'Répondre',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintsTab() {
    final provider = context.watch<ComplaintProvider>();
    final complaints = provider.complaints;
    final pending = complaints.where((c) => c.status == 'en_attente').length;
    final inProgress = complaints.where((c) => c.status == 'en_cours').length;
    final resolved = complaints.where((c) => c.status == 'resolue').length;
    final rejected = complaints.where((c) => c.status == 'rejetee').length;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        PageStatCards(
          items: [
            PageStatCardData(
              label: 'En attente',
              value: '$pending',
              color: Colors.orange,
              icon: Icons.schedule_rounded,
            ),
            PageStatCardData(
              label: 'En cours',
              value: '$inProgress',
              color: Colors.blue,
              icon: Icons.pending_actions_outlined,
            ),
            PageStatCardData(
              label: 'Résolues',
              value: '$resolved',
              color: Colors.green,
              icon: Icons.verified_outlined,
            ),
            PageStatCardData(
              label: 'Rejetées',
              value: '$rejected',
              color: Colors.red,
              icon: Icons.block_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 100),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (complaints.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 100),
            child: Center(child: Text('Aucune réclamation client.')),
          )
        else
          ...complaints.map(_buildComplaintCard),
      ],
    );
  }

  Widget _buildComplaintCard(ComplaintModel complaint) {
    final color = switch (complaint.status) {
      'resolue' => Colors.green,
      'rejetee' => Colors.red,
      'en_cours' => Colors.blue,
      _ => Colors.orange,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    complaint.complaintNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    complaint.statusLabel,
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              complaint.subject,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('${complaint.clientName} • ${complaint.categoryLabel}'),
            if (complaint.orderNumber.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Commande: ${complaint.orderNumber}'),
            ],
            if (complaint.invoiceNumber.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Facture: ${complaint.invoiceNumber}'),
            ],
            if (complaint.productName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Produit: ${complaint.productName}'),
            ],
            const SizedBox(height: 12),
            Text(
              complaint.description,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showComplaintStatusDialog(complaint),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Mettre à jour'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReviewResponseDialog(ReviewModel review) async {
    final controller = TextEditingController(
      text: review.response?.message ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Répondre à l’avis'),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Votre réponse au client',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              await context.read<ReviewProvider>().respondToReview(
                review.id,
                controller.text.trim(),
              );
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  Future<void> _showComplaintStatusDialog(ComplaintModel complaint) async {
    var selectedStatus = complaint.status;
    final controller = TextEditingController(text: complaint.resolutionNote);

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Suivi ${complaint.complaintNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'en_attente',
                    child: Text('En attente'),
                  ),
                  DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
                  DropdownMenuItem(value: 'resolue', child: Text('Résolue')),
                  DropdownMenuItem(value: 'rejetee', child: Text('Rejetée')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setModalState(() => selectedStatus = value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Note de traitement',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                await context.read<ComplaintProvider>().updateStatus(
                  complaint.id,
                  selectedStatus,
                  controller.text.trim(),
                );
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendReply() async {
    if (_replyController.text.trim().isEmpty || _selectedQuestion == null) {
      return;
    }

    final content = _replyController.text.trim();
    _replyController.clear();

    try {
      await context.read<SupportProvider>().sendMessage(
        _selectedQuestion!.id,
        content,
      );
      if (!mounted) return;
      setState(() {
        _selectedQuestion = context
            .read<SupportProvider>()
            .questions
            .firstWhere((q) => q.id == _selectedQuestion!.id);
      });
    } catch (e) {
      AppScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
