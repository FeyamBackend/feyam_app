/// UI-facing order status. The backend exposes the raw financial status; the client maps it
/// to one of these display states. `shipping`/`delivered` are only reachable once logistics is
/// implemented server-side.
enum OrderDisplayStatus { review, payment, shipping, delivered }

/// Maps a raw `FinancialStatus` name (from the API) to an [OrderDisplayStatus].
OrderDisplayStatus orderDisplayStatusFromFinancial(String financialStatus) {
  switch (financialStatus) {
    case 'PendingPayment':
      return OrderDisplayStatus.payment;
    case 'LogisticsConciliated':
      return OrderDisplayStatus.shipping;
    case 'Closed':
      return OrderDisplayStatus.delivered;
    // Paid, FundsReserved, PurchaseExecuted, PurchaseConciliated, PartialRefund, FullRefund.
    default:
      return OrderDisplayStatus.review;
  }
}

/// Stable key understood by `OrderDetailScreen` (review/payment/shipping/delivered).
String orderDisplayStatusKey(OrderDisplayStatus status) => status.name;
