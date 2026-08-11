import 'package:equatable/equatable.dart';
import 'package:feyam/features/payments/domain/entities/payment_method_entity.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';

/// Estado de la lista de métodos de pago.
enum PaymentMethodsStatus { initial, loading, loaded, empty, failure }

/// Estado de la mutación en curso (alta/borrado/marcar default) —
/// desacoplado del estado de la lista para que la UI pueda reaccionar a la
/// mutación sin perder el listado ya cargado.
enum PaymentMethodActionStatus { idle, inProgress, success, failure, cancelled }

/// Qué mutación está en curso — la UI lo necesita para mostrar el toast
/// correcto, ya que [PaymentMethodActionStatus.success] es compartido por
/// las tres.
enum PaymentMethodActionKind { none, add, delete, setDefault }

class PaymentMethodsState extends Equatable {
  const PaymentMethodsState({
    this.status = PaymentMethodsStatus.initial,
    this.paymentMethods = const <PaymentMethodEntity>[],
    this.failure,
    this.actionStatus = PaymentMethodActionStatus.idle,
    this.actionKind = PaymentMethodActionKind.none,
    this.actionFailure,
  });

  final PaymentMethodsStatus status;
  final List<PaymentMethodEntity> paymentMethods;
  final PaymentFailure? failure;
  final PaymentMethodActionStatus actionStatus;
  final PaymentMethodActionKind actionKind;
  final PaymentFailure? actionFailure;

  PaymentMethodsState copyWith({
    PaymentMethodsStatus? status,
    List<PaymentMethodEntity>? paymentMethods,
    PaymentFailure? failure,
    PaymentMethodActionStatus? actionStatus,
    PaymentMethodActionKind? actionKind,
    PaymentFailure? actionFailure,
  }) {
    return PaymentMethodsState(
      status: status ?? this.status,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      failure: failure ?? this.failure,
      actionStatus: actionStatus ?? this.actionStatus,
      actionKind: actionKind ?? this.actionKind,
      actionFailure: actionFailure ?? this.actionFailure,
    );
  }

  @override
  List<Object?> get props =>
      [status, paymentMethods, failure, actionStatus, actionKind, actionFailure];
}
