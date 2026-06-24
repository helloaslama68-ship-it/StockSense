/// Central enum definitions for all domain constant values.
/// Use these instead of raw strings for payment modes, channels, and statuses.

// ---------------------------------------------------------------------------
// Sale
// ---------------------------------------------------------------------------

enum SalePaymentMode { paid, credit, partial }

enum SaleChannel { inStore, online }

extension SaleChannelX on SaleChannel {
  /// Serialised value stored in Hive / sent over API.
  String get value {
    switch (this) {
      case SaleChannel.inStore: return 'in-store';
      case SaleChannel.online:  return 'online';
    }
  }

  /// Human-readable label for UI.
  String get label {
    switch (this) {
      case SaleChannel.inStore: return 'In-Store';
      case SaleChannel.online:  return 'Online';
    }
  }

  static SaleChannel fromValue(String v) {
    switch (v) {
      case 'online':   return SaleChannel.online;
      default:         return SaleChannel.inStore;
    }
  }
}

enum SaleStatus { completed, credit, pending }

extension SaleStatusX on SaleStatus {
  String get value {
    switch (this) {
      case SaleStatus.completed: return 'completed';
      case SaleStatus.credit:    return 'credit';
      case SaleStatus.pending:   return 'pending';
    }
  }

  static SaleStatus fromValue(String v) {
    switch (v) {
      case 'credit':  return SaleStatus.credit;
      case 'pending': return SaleStatus.pending;
      default:        return SaleStatus.completed;
    }
  }
}