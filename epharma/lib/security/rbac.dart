import 'package:flutter/material.dart';

class AppPermission {
  static const viewDashboard = 'view_dashboard';
  static const viewProducts = 'view_products';
  static const addProduct = 'add_product';
  static const editProduct = 'edit_product';
  static const deleteProduct = 'delete_product';
  static const viewStock = 'view_stock';
  static const editStock = 'edit_stock';
  static const viewStockAlerts = 'view_stock_alerts';
  static const viewStockReports = 'view_stock_reports';
  static const viewSuppliers = 'view_suppliers';
  static const makeSale = 'make_sale';
  static const cancelSale = 'cancel_sale';
  static const viewSalesHistory = 'view_sales_history';
  static const viewClients = 'view_clients';
  static const addClient = 'add_client';
  static const editClient = 'edit_client';
  static const deleteClient = 'delete_client';
  static const viewOrders = 'view_orders';
  static const updateOrderStatus = 'update_order_status';
  static const viewFinancialReports = 'view_financial_reports';
  static const addFinanceEntry = 'add_finance_entry';
  static const manageUsers = 'manage_users';
  static const managePermissions = 'manage_permissions';
  static const manageSettings = 'manage_settings';
  static const viewSystemLogs = 'view_system_logs';
  static const viewSupport = 'view_support';
  static const respondSupport = 'respond_support';
  static const viewNotifications = 'view_notifications';
}

const List<String> kAllPermissions = [
  AppPermission.viewDashboard,
  AppPermission.viewProducts,
  AppPermission.addProduct,
  AppPermission.editProduct,
  AppPermission.deleteProduct,
  AppPermission.viewStock,
  AppPermission.editStock,
  AppPermission.viewStockAlerts,
  AppPermission.viewStockReports,
  AppPermission.viewSuppliers,
  AppPermission.makeSale,
  AppPermission.cancelSale,
  AppPermission.viewSalesHistory,
  AppPermission.viewClients,
  AppPermission.addClient,
  AppPermission.editClient,
  AppPermission.deleteClient,
  AppPermission.viewOrders,
  AppPermission.updateOrderStatus,
  AppPermission.viewFinancialReports,
  AppPermission.addFinanceEntry,
  AppPermission.manageUsers,
  AppPermission.managePermissions,
  AppPermission.manageSettings,
  AppPermission.viewSystemLogs,
  AppPermission.viewSupport,
  AppPermission.respondSupport,
  AppPermission.viewNotifications,
];

const Map<String, List<String>> kLegacyPermissionAliases = {
  'manage_products': [
    AppPermission.addProduct,
    AppPermission.editProduct,
    AppPermission.deleteProduct,
  ],
  'manage_stock': [AppPermission.editStock],
  'process_sales': [AppPermission.makeSale],
  'cancel_sales': [AppPermission.cancelSale],
  'manage_clients': [
    AppPermission.addClient,
    AppPermission.editClient,
    AppPermission.deleteClient,
  ],
  'products': [
    AppPermission.viewProducts,
    AppPermission.addProduct,
    AppPermission.editProduct,
    AppPermission.deleteProduct,
  ],
  'sales': [
    AppPermission.makeSale,
    AppPermission.cancelSale,
    AppPermission.viewSalesHistory,
  ],
  'clients': [
    AppPermission.viewClients,
    AppPermission.addClient,
    AppPermission.editClient,
    AppPermission.deleteClient,
  ],
  'finance': [
    AppPermission.viewFinancialReports,
    AppPermission.addFinanceEntry,
  ],
  'users': [
    AppPermission.manageUsers,
    AppPermission.managePermissions,
  ],
  'settings': [AppPermission.manageSettings],
};

Map<String, bool> permissionMap(List<String> enabledPermissions) {
  return {
    for (final permission in kAllPermissions)
      permission: enabledPermissions.contains(permission),
  };
}

final Map<String, Map<String, bool>> kRoleDefaults = {
  'administrateur': permissionMap(kAllPermissions),
  'pharmacien': permissionMap([
    AppPermission.viewProducts,
    AppPermission.addProduct,
    AppPermission.editProduct,
    AppPermission.viewStock,
    AppPermission.viewStockAlerts,
    AppPermission.viewClients,
    AppPermission.addClient,
    AppPermission.editClient,
    AppPermission.viewSalesHistory,
    AppPermission.viewSupport,
    AppPermission.respondSupport,
    AppPermission.viewOrders,
    AppPermission.updateOrderStatus,
    AppPermission.viewNotifications,
  ]),
  'caissier': permissionMap([
    AppPermission.viewProducts,
    AppPermission.makeSale,
    AppPermission.viewSalesHistory,
    AppPermission.viewClients,
    AppPermission.addClient,
    AppPermission.viewOrders,
    AppPermission.viewNotifications,
  ]),
  'gestionnaire de stock': permissionMap([
    AppPermission.viewProducts,
    AppPermission.addProduct,
    AppPermission.editProduct,
    AppPermission.viewStock,
    AppPermission.editStock,
    AppPermission.viewStockAlerts,
    AppPermission.viewStockReports,
    AppPermission.viewSuppliers,
    AppPermission.viewNotifications,
  ]),
  'assistante de gestion': permissionMap([
    AppPermission.viewProducts,
    AppPermission.viewStock,
    AppPermission.viewSalesHistory,
    AppPermission.viewClients,
    AppPermission.viewOrders,
    AppPermission.viewNotifications,
  ]),
  'client': permissionMap(const []),
};

const Map<String, String> kPermissionLabels = {
  AppPermission.viewDashboard: 'Tableau de bord',
  AppPermission.viewProducts: 'Voir les produits',
  AppPermission.addProduct: 'Ajouter un produit',
  AppPermission.editProduct: 'Modifier un produit',
  AppPermission.deleteProduct: 'Supprimer un produit',
  AppPermission.viewStock: 'Voir le stock',
  AppPermission.editStock: 'Modifier le stock',
  AppPermission.viewStockAlerts: 'Voir les alertes stock',
  AppPermission.viewStockReports: 'Voir les rapports stock',
  AppPermission.viewSuppliers: 'Voir les fournisseurs',
  AppPermission.makeSale: 'Encaisser une vente',
  AppPermission.cancelSale: 'Annuler une vente',
  AppPermission.viewSalesHistory: 'Voir l\'historique des ventes',
  AppPermission.viewClients: 'Voir les clients',
  AppPermission.addClient: 'Ajouter un client',
  AppPermission.editClient: 'Modifier un client',
  AppPermission.deleteClient: 'Supprimer un client',
  AppPermission.viewOrders: 'Voir les commandes',
  AppPermission.updateOrderStatus: 'Mettre a jour les commandes',
  AppPermission.viewFinancialReports: 'Voir les rapports financiers',
  AppPermission.addFinanceEntry: 'Ajouter une transaction financiere',
  AppPermission.manageUsers: 'Gerer les utilisateurs',
  AppPermission.managePermissions: 'Gerer les roles et permissions',
  AppPermission.manageSettings: 'Gerer les parametres systeme',
  AppPermission.viewSystemLogs: 'Voir les logs systeme',
  AppPermission.viewSupport: 'Voir les consultations',
  AppPermission.respondSupport: 'Repondre aux consultations',
  AppPermission.viewNotifications: 'Voir les notifications',
};

const Map<String, List<String>> kPermissionCategories = {
  'NAVIGATION & PILOTAGE': [
    AppPermission.viewDashboard,
    AppPermission.viewFinancialReports,
    AppPermission.viewSystemLogs,
  ],
  'PRODUITS & STOCK': [
    AppPermission.viewProducts,
    AppPermission.addProduct,
    AppPermission.editProduct,
    AppPermission.deleteProduct,
    AppPermission.viewStock,
    AppPermission.editStock,
    AppPermission.viewStockAlerts,
    AppPermission.viewStockReports,
  ],
  'VENTES & CLIENTS': [
    AppPermission.makeSale,
    AppPermission.cancelSale,
    AppPermission.viewSalesHistory,
    AppPermission.viewClients,
    AppPermission.addClient,
    AppPermission.editClient,
    AppPermission.deleteClient,
  ],
  'ADMINISTRATION': [
    AppPermission.manageUsers,
    AppPermission.managePermissions,
    AppPermission.manageSettings,
  ],
};

const Map<String, List<String>> kSystemLocked = {
  'administrateur': [
    AppPermission.manageUsers,
    AppPermission.managePermissions,
    AppPermission.manageSettings,
    AppPermission.viewFinancialReports,
    AppPermission.viewSystemLogs,
  ],
  'assistante de gestion': [
    AppPermission.addProduct,
    AppPermission.editProduct,
    AppPermission.deleteProduct,
    AppPermission.editStock,
    AppPermission.makeSale,
    AppPermission.cancelSale,
    AppPermission.addFinanceEntry,
    AppPermission.manageUsers,
    AppPermission.managePermissions,
    AppPermission.manageSettings,
  ],
};

Map<String, bool> normalizePermissions(String role, Map<String, bool> rawPermissions) {
  final normalized = Map<String, bool>.from(
    kRoleDefaults[role] ?? permissionMap(const []),
  );

  for (final entry in rawPermissions.entries) {
    final targets = kLegacyPermissionAliases[entry.key] ?? [entry.key];
    for (final target in targets) {
      if (kAllPermissions.contains(target)) {
        normalized[target] = entry.value;
      }
    }
  }

  return normalized;
}

class SidebarEntry {
  final String key;
  final String label;
  final IconData icon;
  final List<String> permissions;

  const SidebarEntry({
    required this.key,
    required this.label,
    required this.icon,
    required this.permissions,
  });
}

const List<SidebarEntry> kSidebarEntries = [
  SidebarEntry(
    key: 'Dashboard',
    label: 'Tableau de bord',
    icon: Icons.grid_view_rounded,
    permissions: [AppPermission.viewDashboard],
  ),
  SidebarEntry(
    key: 'Products',
    label: 'Produits',
    icon: Icons.medication_outlined,
    permissions: [
      AppPermission.viewProducts,
      AppPermission.addProduct,
      AppPermission.editProduct,
      AppPermission.deleteProduct,
    ],
  ),
  SidebarEntry(
    key: 'Stock',
    label: 'Stock',
    icon: Icons.inventory_2_outlined,
    permissions: [
      AppPermission.viewStock,
      AppPermission.editStock,
      AppPermission.viewStockAlerts,
      AppPermission.viewStockReports,
    ],
  ),
  SidebarEntry(
    key: 'POS',
    label: 'Nouvelle vente',
    icon: Icons.point_of_sale_rounded,
    permissions: [AppPermission.makeSale],
  ),
  SidebarEntry(
    key: 'Sales',
    label: 'Historique ventes',
    icon: Icons.receipt_long_outlined,
    permissions: [AppPermission.viewSalesHistory],
  ),
  SidebarEntry(
    key: 'Clients',
    label: 'Clients',
    icon: Icons.people_outline_rounded,
    permissions: [AppPermission.viewClients],
  ),
  SidebarEntry(
    key: 'Orders',
    label: 'Commandes',
    icon: Icons.shopping_cart_outlined,
    permissions: [AppPermission.viewOrders],
  ),
  SidebarEntry(
    key: 'Support',
    label: 'Consultations',
    icon: Icons.chat_bubble_outline_rounded,
    permissions: [AppPermission.viewSupport, AppPermission.respondSupport],
  ),
  SidebarEntry(
    key: 'Finances',
    label: 'Finances',
    icon: Icons.account_balance_wallet_outlined,
    permissions: [AppPermission.viewFinancialReports],
  ),
  SidebarEntry(
    key: 'Rights',
    label: 'Roles & permissions',
    icon: Icons.admin_panel_settings_outlined,
    permissions: [AppPermission.managePermissions],
  ),
  SidebarEntry(
    key: 'Users',
    label: 'Gestion utilisateurs',
    icon: Icons.manage_accounts_outlined,
    permissions: [AppPermission.manageUsers],
  ),
  SidebarEntry(
    key: 'Activity',
    label: 'Logs systeme',
    icon: Icons.history_rounded,
    permissions: [AppPermission.viewSystemLogs],
  ),
];
