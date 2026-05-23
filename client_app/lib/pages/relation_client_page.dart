import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/support_provider.dart';
import '../services/review_provider.dart';
import '../services/complaint_provider.dart';
import '../services/order_provider.dart';
import '../models/support_model.dart';
import '../models/order.dart';
import '../widgets/app_colors.dart';
import '../widgets/app_notification.dart';
import '../widgets/telegram_page_route.dart';
import 'support_page.dart'; // Import to reuse ClientChatPage

class RelationClientPage extends StatefulWidget {
  final int initialIndex;
  final String? initialOrderId;

  const RelationClientPage({
    super.key,
    this.initialIndex = 0,
    this.initialOrderId,
  });

  @override
  State<RelationClientPage> createState() => _RelationClientPageState();
}

class _RelationClientPageState extends State<RelationClientPage> {
  int _currentTabIndex = 0;
  bool _isGoingBack = false;
  String? _selectedComplaintStatus;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().loadQuestions();
      context.read<ReviewProvider>().loadMyReviews();
      context.read<ComplaintProvider>().loadComplaints();
      if (context.read<OrderProvider>().orders.isEmpty) {
        context.read<OrderProvider>().loadMyOrders();
      }
    });
  }

  Future<void> _refreshCurrentTab() async {
    if (_currentTabIndex == 0) {
      await context.read<SupportProvider>().loadQuestions();
    } else if (_currentTabIndex == 1) {
      await context.read<ReviewProvider>().loadMyReviews();
    } else {
      await context.read<ComplaintProvider>().loadComplaints(
        status: _selectedComplaintStatus,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Espace Relation Client',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          _buildTabSelector(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshCurrentTab,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final isEntering = child.key == ValueKey(_currentTabIndex);
                  Offset beginOffset;
                  if (_isGoingBack) {
                    beginOffset = isEntering ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0);
                  } else {
                    beginOffset = isEntering ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
                  }

                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: beginOffset,
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey(_currentTabIndex),
                  child: _buildCurrentTabView(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabButton(0, 'Questions', Icons.chat_bubble_outline_rounded),
          _buildTabButton(1, 'Avis', Icons.star_outline_rounded),
          _buildTabButton(2, 'Réclamations', Icons.report_problem_outlined),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _currentTabIndex == index;
    final primaryColor = Theme.of(context).primaryColor;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == _currentTabIndex) return;
          setState(() {
            _isGoingBack = index < _currentTabIndex;
            _currentTabIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? primaryColor : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black87 : Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabView() {
    switch (_currentTabIndex) {
      case 0:
        return _buildQuestionsList();
      case 1:
        return _buildReviewsList();
      case 2:
        return _buildComplaintsList();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget? _buildFloatingActionButton() {
    if (_currentTabIndex == 0) {
      return FloatingActionButton.extended(
        heroTag: 'fab_support',
        onPressed: () => _showNewQuestionDialog(context),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Poser une question'),
      );
    } else if (_currentTabIndex == 2) {
      return FloatingActionButton.extended(
        heroTag: 'fab_complaints',
        onPressed: _showCreateComplaintSheet,
        icon: const Icon(Icons.report_problem_outlined),
        label: const Text('Nouvelle réclamation'),
      );
    }
    return null;
  }

  // ================= QUESTIONS TAB =================

  Widget _buildQuestionsList() {
    return Consumer<SupportProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.questions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.questions.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.chat_outlined, size: 64, color: Colors.blue[300]),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucune discussion en cours',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vous n’avez pas encore échangé avec nos pharmaciens.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showNewQuestionDialog(context),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Démarrer une consultation'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: provider.questions.length,
          itemBuilder: (context, index) {
            final q = provider.questions[index];
            return _buildQuestionCard(q);
          },
        );
      },
    );
  }

  Widget _buildQuestionCard(SupportQuestion q) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            TelegramPageRoute(child: ClientChatPage(question: q)),
          ),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(q.statusLabel, q.statusColor),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  q.messages.last.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 6),
                        Text(
                          'Activité: ${_formatDate(q.updatedAt)}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showNewQuestionDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nouvelle consultation',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Sujet / Motif de consultation',
                  prefixIcon: const Icon(Icons.subject_rounded),
                  border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Décrivez précisément votre demande',
                  prefixIcon: const Icon(Icons.chat_bubble_outline_rounded),
                  border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (subjectController.text.trim().isNotEmpty &&
                        contentController.text.trim().isNotEmpty) {
                      await context.read<SupportProvider>().createQuestion(
                        subjectController.text.trim(),
                        contentController.text.trim(),
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      AppScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Votre question a été transmise avec succès.'),
                          backgroundColor: kSuccessGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Envoyer au pharmacien', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= AVIS TAB =================

  Widget _buildReviewsList() {
    return Consumer<ReviewProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.myReviews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.myReviews.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star_outline_rounded, size: 64, color: Colors.amber[400]),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucun avis publié',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vous n’avez pas encore laissé d’évaluation sur vos commandes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final formatter = DateFormat('dd/MM/yyyy');

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: provider.myReviews.length,
          itemBuilder: (context, index) {
            final review = provider.myReviews[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
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
                              review.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatter.format(review.createdAt),
                            style: TextStyle(color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          5,
                          (idx) => Icon(
                            idx < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ),
                      if (review.comment.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          review.comment,
                          style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                        ),
                      ],
                      if (review.serviceComment.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Service: ',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                            ),
                            Expanded(
                              child: Text(
                                review.serviceComment,
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (review.isLightDissatisfaction) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
                              SizedBox(width: 6),
                              Text(
                                'Insatisfaction légère signalée',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (review.hasResponse) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.chat_bubble_rounded, size: 14, color: Colors.blue[600]),
                                  const SizedBox(width: 6),
                                  Text(
                                    review.response!.responderName.isNotEmpty
                                        ? review.response!.responderName
                                        : 'Réponse de la Pharmacie',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                review.response!.message,
                                style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= RECLAMATIONS TAB =================

  Widget _buildComplaintsList() {
    return Consumer<ComplaintProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.complaints.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: DropdownButtonFormField<String?>(
                value: _selectedComplaintStatus,
                decoration: InputDecoration(
                  labelText: 'Filtrer par statut',
                  prefixIcon: const Icon(Icons.filter_list_rounded),
                  border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Tous les statuts'),
                  ),
                  DropdownMenuItem(
                    value: 'en_attente',
                    child: Text('En attente'),
                  ),
                  DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
                  DropdownMenuItem(value: 'resolue', child: Text('Résolue')),
                  DropdownMenuItem(value: 'rejetee', child: Text('Rejetée')),
                ],
                onChanged: (value) {
                  setState(() => _selectedComplaintStatus = value);
                  context.read<ComplaintProvider>().loadComplaints(status: value);
                },
              ),
            ),
            Expanded(
              child: provider.complaints.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.report_problem_outlined, size: 64, color: Colors.red[300]),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Aucune réclamation',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Vous n’avez aucune réclamation enregistrée pour le moment.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: provider.complaints.length,
                      itemBuilder: (context, index) {
                        return _buildComplaintCard(provider.complaints[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildComplaintCard(dynamic complaint) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    Color color;
    switch (complaint.status) {
      case 'resolue':
        color = Colors.green;
        break;
      case 'rejetee':
        color = Colors.red;
        break;
      case 'en_cours':
        color = Colors.blue;
        break;
      default:
        color = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
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
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _buildStatusChip(complaint.statusLabel, color),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                complaint.subject,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                complaint.categoryLabel,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              if (complaint.orderNumber.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Commande: ${complaint.orderNumber}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatter.format(complaint.createdAt),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
              if (complaint.resolutionNote.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
                          SizedBox(width: 6),
                          Text(
                            'Note de résolution',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        complaint.resolutionNote,
                        style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateComplaintSheet() async {
    final provider = context.read<ComplaintProvider>();
    final orderProvider = context.read<OrderProvider>();
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    var category = 'mauvaise_commande';
    String? selectedOrderId = widget.initialOrderId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nouvelle réclamation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: InputDecoration(
                        labelText: 'Catégorie de réclamation',
                        prefixIcon: const Icon(Icons.category_rounded),
                        border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14)),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'produit_endommage',
                          child: Text('Produit endommagé'),
                        ),
                        DropdownMenuItem(
                          value: 'mauvaise_commande',
                          child: Text('Mauvaise commande'),
                        ),
                        DropdownMenuItem(
                          value: 'retard_livraison',
                          child: Text('Retard de livraison'),
                        ),
                        DropdownMenuItem(
                          value: 'produit_manquant',
                          child: Text('Produit manquant'),
                        ),
                        DropdownMenuItem(
                          value: 'erreur_facture',
                          child: Text('Erreur facture'),
                        ),
                        DropdownMenuItem(
                          value: 'probleme_utilisation',
                          child: Text('Problème d’utilisation'),
                        ),
                        DropdownMenuItem(value: 'autre', child: Text('Autre')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => category = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      value: selectedOrderId,
                      decoration: InputDecoration(
                        labelText: 'Commande concernée',
                        prefixIcon: const Icon(Icons.receipt_long_rounded),
                        border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14)),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Aucune commande spécifique'),
                        ),
                        ...orderProvider.orders.map(
                          (Order order) => DropdownMenuItem<String?>(
                            value: order.id,
                            child: Text(order.orderNumber),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() => selectedOrderId = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        labelText: 'Sujet succinct',
                        prefixIcon: const Icon(Icons.subject_rounded),
                        border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: 'Décrivez en détail le problème rencontré',
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (subjectController.text.trim().isEmpty ||
                              descriptionController.text.trim().isEmpty) {
                            return;
                          }
                          try {
                            await provider.createComplaint(
                              category: category,
                              subject: subjectController.text.trim(),
                              description: descriptionController.text.trim(),
                              orderId: selectedOrderId,
                            );
                            if (!mounted) return;
                            Navigator.pop(context);
                            AppScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Réclamation envoyée avec succès.'),
                                backgroundColor: kSuccessGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            AppScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: kErrorRed,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Envoyer la réclamation', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} à ${dt.hour}:$minute';
  }
}
