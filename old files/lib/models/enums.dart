// Defines enums matching the database.sql types

// ignore_for_file: constant_identifier_names

enum UserRole { owner, manager, accountant, sales, installer, staff, inventory_manager }

enum CompanyTier { wholesaler, intermediary, retailer }

enum InverterType { hybrid, on_grid, off_grid, vfd }

enum SystemStatus { pending_verification, verified, rejected }

enum ProductStatus { active, archived, out_of_stock }

enum OrderType { pos_sale, online_order, b2b_supply }

enum OrderStatus { pending, processing, completed, cancelled, returned, waiting, in_progress, done }

enum PaymentStatus { paid, unpaid, partial, refunded }

// Helper extension to handle String conversion if needed
extension UserRoleExtension on UserRole {
  String toSql() => toString().split('.').last;
  static UserRole fromSql(String val) => UserRole.values.firstWhere((e) => e.toSql() == val, orElse: () => UserRole.staff);
}

extension CompanyTierExtension on CompanyTier {
  String toSql() => toString().split('.').last;
  static CompanyTier fromSql(String val) => CompanyTier.values.firstWhere((e) => e.toSql() == val, orElse: () => CompanyTier.intermediary);
}

// ... similar extensions can be added for others if strict string matching is needed
