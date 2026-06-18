import 'package:equatable/equatable.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

final class CartLoadRequested extends CartEvent {
  const CartLoadRequested();
}

final class CartItemRemoveRequested extends CartEvent {
  const CartItemRemoveRequested(this.itemId);

  final String itemId;

  @override
  List<Object> get props => [itemId];
}

final class CartItemQuantityUpdateRequested extends CartEvent {
  const CartItemQuantityUpdateRequested(this.itemId, this.newQuantity);

  final String itemId;
  final int newQuantity;

  @override
  List<Object> get props => [itemId, newQuantity];
}
