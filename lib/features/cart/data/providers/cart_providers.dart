// Feature providers for the cart module.
// Wires datasource, repository and use cases together using Riverpod.
//
// Author: edgar.muhamyangabo
// Date: 2026-11-26
// Project: flutter_tutorial
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_cart_item_use_case.dart';
import '../../domain/usecases/checkout_use_case.dart';
import '../../domain/usecases/clear_cart_use_case.dart';
import '../../domain/usecases/get_cart_use_case.dart';
import '../../domain/usecases/remove_cart_item_use_case.dart';
import '../../domain/usecases/update_cart_item_use_case.dart';
import '../datasources/cart_remote_datasource.dart';
import '../repositories/cart_repository_impl.dart';

part 'cart_providers.g.dart';

@riverpod
CartRemoteDatasource cartRemoteDatasource(Ref ref) =>
    CartRemoteDatasourceImpl(ref.watch(dioProvider));

@riverpod
CartRepository cartRepository(Ref ref) =>
    CartRepositoryImpl(ref.watch(cartRemoteDatasourceProvider));

@riverpod
GetCartUseCase getCartUseCase(Ref ref) =>
    GetCartUseCase(ref.watch(cartRepositoryProvider));

@riverpod
AddCartItemUseCase addCartItemUseCase(Ref ref) =>
    AddCartItemUseCase(ref.watch(cartRepositoryProvider));

@riverpod
UpdateCartItemUseCase updateCartItemUseCase(Ref ref) =>
    UpdateCartItemUseCase(ref.watch(cartRepositoryProvider));

@riverpod
RemoveCartItemUseCase removeCartItemUseCase(Ref ref) =>
    RemoveCartItemUseCase(ref.watch(cartRepositoryProvider));

@riverpod
ClearCartUseCase clearCartUseCase(Ref ref) =>
    ClearCartUseCase(ref.watch(cartRepositoryProvider));

@riverpod
CheckoutUseCase checkoutUseCase(Ref ref) =>
    CheckoutUseCase(ref.watch(cartRemoteDatasourceProvider));
