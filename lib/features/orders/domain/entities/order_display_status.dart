/// UI-facing order status. The backend exposes the raw financial status; the client maps it
/// to one of these display states. `shipping`/`delivered` are only reachable once logistics is
/// implemented server-side.
///
/// `pendingReview` and `awaitingPayment` are new, pre-payment states: an order now exists (and
/// is visible here) from the moment the customer submits their cart — long before any charge —
/// while a price_confirmator reviews it (`pendingReview`) and once they've confirmed a price the
/// customer must pay (`awaitingPayment`). `review`/`payment`/`shipping`/`delivered` keep their
/// original, post-payment meaning, driven by `RecentOrderEntity.financialStatus`.
enum OrderDisplayStatus {
  pendingReview,
  awaitingPayment,
  review,
  payment,
  shipping,
  delivered,
  cancelled,
}

/// Maps a raw `FinancialStatus` name (from the API) to an [OrderDisplayStatus]. Only meaningful
/// once a wallet exists for the order (i.e. once it's paid) — see [orderDisplayStatus] for the
/// full mapping that also covers the pre-payment states.
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

/// Maps an order's own raw lifecycle `status` (always present) and, once paid, its
/// `financialStatus` (null before then) to a single [OrderDisplayStatus] for the order list/detail
/// UI. Pre-payment states are read straight off `status`; once the order is `Paid` or beyond,
/// `financialStatus` (when present) drives the finer-grained post-payment mapping.
OrderDisplayStatus orderDisplayStatus({
  required String status,
  String? financialStatus,
}) {
  switch (status) {
    case 'PendingPriceReview':
      return OrderDisplayStatus.pendingReview;
    case 'PriceConfirmed':
    case 'AwaitingPayment':
      return OrderDisplayStatus.awaitingPayment;
    case 'Cancelled':
      return OrderDisplayStatus.cancelled;
    default:
      if (financialStatus != null) {
        return orderDisplayStatusFromFinancial(financialStatus);
      }
      // Paid but the wallet hasn't been created yet (a brief race right after
      // payment succeeds) — treat as "in review" rather than crashing on a
      // missing financial status.
      return OrderDisplayStatus.review;
  }
}

/// Stable key understood by `OrderDetailScreen` (pendingReview/awaitingPayment/review/payment/shipping/delivered/cancelled).
String orderDisplayStatusKey(OrderDisplayStatus status) => status.name;
