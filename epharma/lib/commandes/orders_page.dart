import 'dart:async';
import 'package:flutter/material.dart';
import 'package:epharma/widgets/app_notification.dart';
import '../widgets/common/app_ui.dart';
import '../widgets/page_stat_cards.dart';
import '../widgets/bp_theme.dart';
import '../widgets/animated_components.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import 'order_details_page.dart';

// ignore_for_file: dead_code

class PharmacyOrdersPage extends StatefulWidget {
  const PharmacyOrdersPage({super.key});

  @override
  State<PharmacyOrdersPage> createState() => _PharmacyOrdersPageState();
}

class _PharmacyOrdersPageState extends State<PharmacyOrdersPage> {
  static const Duration _autoRefreshInterval = Duration(seconds: 45);
  static const Duration _searchDebounceDuration = Duration(milliseconds: 400);

  String _searchQuery = '';
  String? _selectedStatus;
  Timer? _refreshTimer;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
    _refreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      if (mounted) {
        _loadOrders(page: context.read<OrderProvider>().currentPage);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _loadOrders({int page = 1, bool forceRefresh = false}) {
    final authProvider = context.read<AuthProvider>();
    context.read<OrderProvider>().fetchOrders(
      authProvider: authProvider,
      page: page,
      status: _selectedStatus,
      search: _searchQuery,
      forceRefresh: forceRefresh,
    );
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (mounted) {
        _loadOrders(page: 1, forceRefresh: true);
      }
    });
  }

  Future<void> _applyStatusChange(OrderModel order, OrderStatus status) async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<OrderProvider>();
    final success = await provider.updateOrderStatus(
      order.id,
      status.apiValue,
      null,
      auth.token!,
    );

    if (!mounted) {
      return;
    }

    AppScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Commande ${order.orderNumber} mise à jour.'
              : (provider.errorMessage ?? 'Échec de la mise à jour.'),
        ),
      ),
    );

    if (success) {
      _loadOrders(
        page: context.read<OrderProvider>().currentPage,
        forceRefresh: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppResponsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildDashboard(orderProvider),
              const SizedBox(height: 24),
              const SizedBox(height: 16),
              SizedBox(
                height:
                    500, // Fixed height for table container or use ConstrainedBox
                child: orderProvider.isLoading && orderProvider.orders.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildOrdersList(orderProvider),
              ),
              _buildPagination(orderProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return _buildResponsiveHeader();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Left: Title
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Gestion des commandes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: BpColors.textPrimary,
                  ),
                ),
                Text(
                  'Suivi en temps réel du cycle de commande.',
                  style: TextStyle(fontSize: 14, color: BpColors.textSecondary),
                ),
              ],
            ),
          ),

          // Middle: Search and Filter
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    style: const TextStyle(color: BpColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Rechercher par numéro ou client...',
                      hintStyle: const TextStyle(color: BpColors.textHint),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: BpColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: BpColors.cardBg,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: BpColors.borderStrong,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: BpColors.border),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: BpColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BpColors.borderStrong),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      dropdownColor: BpColors.surface,
                      hint: const Text(
                        'Filtrer par statut',
                        style: TextStyle(
                          fontSize: 14,
                          color: BpColors.textSecondary,
                        ),
                      ),
                      value: _selectedStatus,
                      style: const TextStyle(
                        color: BpColors.textPrimary,
                        fontSize: 14,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Tous les statuts'),
                        ),
                        ...OrderStatus.values.map(
                          (status) => DropdownMenuItem<String?>(
                            value: status.apiValue,
                            child: Text(status.label),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedStatus = value);
                        _loadOrders(page: 1, forceRefresh: true);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right: Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: FilledButton.icon(
                    onPressed: () => _loadOrders(page: 1, forceRefresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Rafraîchir'),
                    style: FilledButton.styleFrom(
                      backgroundColor: BpColors.surfaceMuted,
                      foregroundColor: BpColors.textPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: BpColors.border),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(OrderProvider provider) {
    return _buildResponsiveDashboard(provider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 5;
        if (width < 600) {
          crossAxisCount = 2;
        } else if (width < 1000) {
          crossAxisCount = 3;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: width < 600 ? 1.5 : 2.0,
          children: [
            _buildStatCard(
              'En attente',
              '${provider.stats['en_attente'] ?? 0}',
              Colors.orange,
              Icons.timer_outlined,
            ),
            _buildStatCard(
              'Préparation',
              '${provider.stats['en_preparation'] ?? 0}',
              Colors.blue,
              Icons.inventory_2_outlined,
            ),
            _buildStatCard(
              'Prêtes',
              '${provider.stats['pret_pour_recuperation'] ?? 0}',
              Colors.purple,
              Icons.shopping_bag_outlined,
            ),
            _buildStatCard(
              'Validées',
              '${provider.stats['validee'] ?? 0}',
              Colors.green,
              Icons.check_circle_outline,
            ),
            _buildStatCard(
              'Annulées',
              '${provider.stats['annulee'] ?? 0}',
              Colors.red,
              Icons.cancel_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BpColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showIcon = constraints.maxWidth > 80;
          return Row(
            children: [
              if (showIcon) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: BpColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BpColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: isMobile ? double.infinity : 350,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher par numéro ou client...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: BpColors.surfaceMuted,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: BpColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: BpColors.border),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Container(
              width: isMobile ? double.infinity : 220,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: BpColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: BpColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  hint: const Text('Filtrer par statut'),
                  value: _selectedStatus,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tous les statuts'),
                    ),
                    ...OrderStatus.values.map(
                      (status) => DropdownMenuItem<String?>(
                        value: status.apiValue,
                        child: Text(status.label),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                    _loadOrders(page: 1, forceRefresh: true);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrdersList(OrderProvider provider) {
    if (provider.orders.isEmpty) {
      return Center(
        child: Text(provider.errorMessage ?? 'Aucune commande trouvée.'),
      );
    }

    return AnimatedCardContainer(
      delayMs: 0,
      child: Container(
        decoration: BoxDecoration(
          color: BpColors.surfaceStrong,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BpColors.borderStrong),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(BpColors.surface),
                    columnSpacing: 24,
                    horizontalMargin: 24,
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 64,
                    headingRowHeight: 56,
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: BpColors.textPrimary,
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'N° Commande',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Client',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Date',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Total',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Statut',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Actions',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                      ),
                    ],
                    rows: provider.orders.map(_buildOrderRow).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  DataRow _buildOrderRow(OrderModel order) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            order.orderNumber,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: BpColors.textPrimary,
            ),
          ),
        ),
        DataCell(
          Text(
            order.clientName,
            style: const TextStyle(color: BpColors.textSecondary),
          ),
        ),
        DataCell(
          Text(
            order.formattedDate,
            style: const TextStyle(color: BpColors.textSecondary),
          ),
        ),
        DataCell(
          Text(
            '${order.totalPrice.toStringAsFixed(0)} FCFA',
            style: const TextStyle(color: BpColors.textSecondary),
          ),
        ),
        DataCell(_buildStatusBadge(order.status)),

        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedIconButton(
                icon: Icons.visibility_outlined,
                tooltip: 'Détails',
                color: BpColors.textPrimary,
                onPressed: () => _viewDetails(order),
              ),
              const SizedBox(width: 4),
              ...order.availableNextStatuses
                  .where(
                    (s) =>
                        !(order.status == OrderStatus.validee &&
                            s == OrderStatus.annulee),
                  )
                  .map(
                    (status) => AnimatedIconButton(
                      icon: _actionIcon(status),
                      tooltip: status.label,
                      color: status.color,
                      onPressed: () => _applyStatusChange(order, status),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _actionIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.enPreparation:
        return Icons.inventory_2_outlined;
      case OrderStatus.pretPourRecuperation:
        return Icons.shopping_bag_outlined;
      case OrderStatus.validee:
        return Icons.check_circle_outline;
      case OrderStatus.annulee:
        return Icons.cancel_outlined;
      case OrderStatus.enAttente:
        return Icons.timer_outlined;
    }
  }

  Widget _buildStatusBadge(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPagination(OrderProvider provider) {
    return _buildResponsivePagination(provider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: BpColors.textPrimary),
            onPressed: provider.currentPage > 1
                ? () => _loadOrders(page: provider.currentPage - 1)
                : null,
          ),
          Text(
            'Page ${provider.currentPage} sur ${provider.totalPages}',
            style: const TextStyle(
              color: BpColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: BpColors.textPrimary),
            onPressed: provider.currentPage < provider.totalPages
                ? () => _loadOrders(page: provider.currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppResponsive.tabletBreakpoint;

        Widget searchField({bool fullWidth = false}) {
          final field = SizedBox(
            height: 54,
            child: TextField(
              style: const TextStyle(color: BpColors.textPrimary),
              onChanged: _onSearchChanged,
              decoration: BpInputTheme.light(
                label: 'Recherche',
                hint: 'Rechercher par numéro ou client...',
                prefixIcon: Icons.search,
                showLabel: false,
              ),
            ),
          );

          return fullWidth ? SizedBox(width: double.infinity, child: field) : field;
        }

        Widget statusFilter({bool fullWidth = false}) {
          final field = SizedBox(
            height: 54,
            child: DropdownButtonFormField<String?>(
              value: _selectedStatus,
              isExpanded: true,
              dropdownColor: BpColors.surface,
              decoration: BpInputTheme.light(
                label: 'Statut',
                hint: 'Tous les statuts',
                showLabel: false,
              ),
              style: const TextStyle(
                color: BpColors.textPrimary,
                fontSize: 14,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tous les statuts'),
                ),
                ...OrderStatus.values.map(
                  (status) => DropdownMenuItem<String?>(
                    value: status.apiValue,
                    child: Text(status.label),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _loadOrders(page: 1, forceRefresh: true);
              },
            ),
          );

          return fullWidth ? SizedBox(width: double.infinity, child: field) : field;
        }

        Widget refreshButton({bool fullWidth = false}) {
          final button = SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: () => _loadOrders(page: 1, forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Rafraîchir'),
              style: FilledButton.styleFrom(
                backgroundColor: BpColors.surfaceMuted,
                foregroundColor: BpColors.textPrimary,
                elevation: 0,
                minimumSize: const Size.fromHeight(54),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: BpColors.border),
                ),
              ),
            ),
          );

          return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestion des commandes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: BpColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Suivi en temps reel du cycle de commande.',
                      style: TextStyle(
                        fontSize: 14,
                        color: BpColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    searchField(fullWidth: true),
                    const SizedBox(height: 12),
                    statusFilter(fullWidth: true),
                    const SizedBox(height: 12),
                    refreshButton(fullWidth: true),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Gestion des commandes',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: BpColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Suivi en temps reel du cycle de commande.',
                            style: TextStyle(
                              fontSize: 14,
                              color: BpColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: searchField()),
                          const SizedBox(width: 12),
                          SizedBox(width: 260, child: statusFilter()),
                          const SizedBox(width: 12),
                          SizedBox(width: 180, child: refreshButton()),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildResponsiveDashboard(OrderProvider provider) {
    return PageStatCards(
      items: [
        PageStatCardData(
          label: 'En attente',
          value: '${provider.stats['en_attente'] ?? 0}',
          color: Colors.orange,
          icon: Icons.timer_outlined,
        ),
        PageStatCardData(
          label: 'Preparation',
          value: '${provider.stats['en_preparation'] ?? 0}',
          color: Colors.blue,
          icon: Icons.inventory_2_outlined,
        ),
        PageStatCardData(
          label: 'Pretes',
          value: '${provider.stats['pret_pour_recuperation'] ?? 0}',
          color: Colors.purple,
          icon: Icons.shopping_bag_outlined,
        ),
        PageStatCardData(
          label: 'Validees',
          value: '${provider.stats['validee'] ?? 0}',
          color: Colors.green,
          icon: Icons.check_circle_outline,
        ),
        PageStatCardData(
          label: 'Annulees',
          value: '${provider.stats['annulee'] ?? 0}',
          color: Colors.red,
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }

  Widget _buildResponsivePagination(OrderProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < AppResponsive.tabletBreakpoint;
          final pager = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: BpColors.textPrimary),
                onPressed: provider.currentPage > 1
                    ? () => _loadOrders(page: provider.currentPage - 1)
                    : null,
              ),
              Text(
                'Page ${provider.currentPage} sur ${provider.totalPages}',
                style: const TextStyle(
                  color: BpColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: BpColors.textPrimary),
                onPressed: provider.currentPage < provider.totalPages
                    ? () => _loadOrders(page: provider.currentPage + 1)
                    : null,
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Page ${provider.currentPage} sur ${provider.totalPages}',
                  style: const TextStyle(
                    color: BpColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: pager,
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [pager],
          );
        },
      ),
    );
  }

  void _viewDetails(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OrderDetailsPage(orderId: order.id)),
    );
  }
}
