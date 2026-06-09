import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/support_provider.dart';
import '../services/review_provider.dart';
import '../services/complaint_provider.dart';
import '../services/order_provider.dart';

import 'relation_client/questions_tab.dart';
import 'relation_client/reviews_tab.dart';
import 'relation_client/complaints_tab.dart';

import '../widgets/modals/new_question_modal.dart';
import '../widgets/modals/new_complaint_modal.dart';

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
        return const QuestionsTab();
      case 1:
        return const ReviewsTab();
      case 2:
        return ComplaintsTab(
          initialStatus: _selectedComplaintStatus,
          onStatusChanged: (status) {
            setState(() {
              _selectedComplaintStatus = status;
            });
            context.read<ComplaintProvider>().loadComplaints(status: status);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget? _buildFloatingActionButton() {
    if (_currentTabIndex == 0) {
      return FloatingActionButton.extended(
        heroTag: 'fab_support',
        onPressed: () => showNewQuestionDialog(context),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Poser une question'),
      );
    } else if (_currentTabIndex == 2) {
      return FloatingActionButton.extended(
        heroTag: 'fab_complaints',
        onPressed: () => showCreateComplaintSheet(context, initialOrderId: widget.initialOrderId),
        icon: const Icon(Icons.report_problem_outlined),
        label: const Text('Nouvelle réclamation'),
      );
    }
    return null;
  }
}
