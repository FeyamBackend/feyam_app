import 'package:feyam/core/payments/payment_method_gateway.dart';
import 'package:feyam/core/payments/payment_method_gateway_registry.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:feyam/features/payments/domain/usecases/create_payment_method_setup.dart';
import 'package:feyam/features/payments/domain/usecases/delete_payment_method.dart';
import 'package:feyam/features/payments/domain/usecases/get_payment_methods.dart';
import 'package:feyam/features/payments/domain/usecases/set_default_payment_method.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_methods_event.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_methods_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentMethodsBloc
    extends Bloc<PaymentMethodsEvent, PaymentMethodsState> {
  PaymentMethodsBloc({
    required GetPaymentMethodsUseCase getPaymentMethodsUseCase,
    required CreatePaymentMethodSetupUseCase createPaymentMethodSetupUseCase,
    required DeletePaymentMethodUseCase deletePaymentMethodUseCase,
    required SetDefaultPaymentMethodUseCase setDefaultPaymentMethodUseCase,
    required PaymentMethodGatewayRegistry gatewayRegistry,
  }) : _getPaymentMethods = getPaymentMethodsUseCase,
       _createSetup = createPaymentMethodSetupUseCase,
       _deletePaymentMethod = deletePaymentMethodUseCase,
       _setDefaultPaymentMethod = setDefaultPaymentMethodUseCase,
       _gatewayRegistry = gatewayRegistry,
       super(const PaymentMethodsState()) {
    on<PaymentMethodsLoadRequested>(_onLoadRequested);
    on<PaymentMethodAddRequested>(_onAddRequested);
    on<PaymentMethodDeleteRequested>(_onDeleteRequested);
    on<PaymentMethodSetDefaultRequested>(_onSetDefaultRequested);
  }

  final GetPaymentMethodsUseCase _getPaymentMethods;
  final CreatePaymentMethodSetupUseCase _createSetup;
  final DeletePaymentMethodUseCase _deletePaymentMethod;
  final SetDefaultPaymentMethodUseCase _setDefaultPaymentMethod;
  final PaymentMethodGatewayRegistry _gatewayRegistry;

  Future<void> _onLoadRequested(
    PaymentMethodsLoadRequested event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    emit(state.copyWith(status: PaymentMethodsStatus.loading));
    await _reload(emit);
  }

  /// Pide el setup al backend (asegura el customer en la pasarela) y delega
  /// la captura al gateway resuelto por `setup.provider` — ni el bloc ni la
  /// pantalla necesitan saber qué pasarela es.
  Future<void> _onAddRequested(
    PaymentMethodAddRequested event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: PaymentMethodActionStatus.inProgress,
        actionKind: PaymentMethodActionKind.add,
        actionFailure: null,
      ),
    );

    try {
      final setup = await _createSetup();
      final gateway = _gatewayRegistry.resolve(setup.provider);
      await gateway.collectAndSave(setup);
    } on PaymentFailure catch (failure) {
      emit(
        state.copyWith(
          actionStatus: PaymentMethodActionStatus.failure,
          actionFailure: failure,
        ),
      );
      return;
    } on PaymentMethodCollectionCancelled {
      emit(state.copyWith(actionStatus: PaymentMethodActionStatus.cancelled));
      return;
    } on PaymentMethodCollectionException {
      emit(
        state.copyWith(
          actionStatus: PaymentMethodActionStatus.failure,
          actionFailure: const PaymentFailure(PaymentFailureCode.unknown),
        ),
      );
      return;
    }

    await _reload(emit);
    emit(state.copyWith(actionStatus: PaymentMethodActionStatus.success));
  }

  Future<void> _onDeleteRequested(
    PaymentMethodDeleteRequested event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    await _mutate(
      emit,
      PaymentMethodActionKind.delete,
      () => _deletePaymentMethod(event.id),
    );
  }

  Future<void> _onSetDefaultRequested(
    PaymentMethodSetDefaultRequested event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    await _mutate(
      emit,
      PaymentMethodActionKind.setDefault,
      () => _setDefaultPaymentMethod(event.id),
    );
  }

  /// Ejecuta una mutación y, si tiene éxito, recarga el listado desde el
  /// backend (fuente de verdad). Reporta el resultado vía [PaymentMethodActionStatus].
  Future<void> _mutate(
    Emitter<PaymentMethodsState> emit,
    PaymentMethodActionKind kind,
    Future<void> Function() action,
  ) async {
    emit(
      state.copyWith(
        actionStatus: PaymentMethodActionStatus.inProgress,
        actionKind: kind,
        actionFailure: null,
      ),
    );
    try {
      await action();
      await _reload(emit);
      emit(state.copyWith(actionStatus: PaymentMethodActionStatus.success));
    } on PaymentFailure catch (failure) {
      emit(
        state.copyWith(
          actionStatus: PaymentMethodActionStatus.failure,
          actionFailure: failure,
        ),
      );
    }
  }

  /// Recarga el listado. Actualiza solo el estado de la lista, no el de acción.
  Future<void> _reload(Emitter<PaymentMethodsState> emit) async {
    try {
      final paymentMethods = await _getPaymentMethods();
      emit(
        state.copyWith(
          status: paymentMethods.isEmpty
              ? PaymentMethodsStatus.empty
              : PaymentMethodsStatus.loaded,
          paymentMethods: paymentMethods,
          failure: null,
        ),
      );
    } on PaymentFailure catch (failure) {
      emit(state.copyWith(status: PaymentMethodsStatus.failure, failure: failure));
    }
  }
}
