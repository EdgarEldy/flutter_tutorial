import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:flutter_tutorial/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_tutorial/features/cart/data/models/cart_model.dart';
import 'package:flutter_tutorial/features/cart/data/repositories/cart_repository_impl.dart';

class MockCartRemoteDatasource extends Mock implements CartRemoteDatasource {}

DioException makeDioException() => DioException(
      requestOptions: RequestOptions(path: '/test'),
      message: 'Network error',
    );

void main() {
  late MockCartRemoteDatasource mockRemote;
  late CartRepositoryImpl repo;

  const testCartItemModel = CartItemModel(
    id: 1,
    productId: 10,
    productName: 'Test Product',
    unitPrice: 29.99,
    quantity: 2,
    subtotal: 59.98,
  );

  const testCartModel = CartModel(
    id: 1,
    items: [testCartItemModel],
    totalAmount: 59.98,
  );

  setUp(() {
    mockRemote = MockCartRemoteDatasource();
    repo = CartRepositoryImpl(mockRemote);
  });

  test('_01_ShouldReturnCart_WhenGetCartSucceeds', () async {
    when(() => mockRemote.getCart()).thenAnswer((_) async => testCartModel);

    final result = await repo.getCart();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (cart) {
        expect(cart.id, equals(1));
        expect(cart.items, hasLength(1));
        expect(cart.totalAmount, equals(59.98));
      },
    );
  });

  test('_02_ShouldReturnNetworkFailure_WhenGetCartThrowsDioException', () async {
    when(() => mockRemote.getCart()).thenThrow(makeDioException());

    final result = await repo.getCart();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });

  test('_03_ShouldReturnCart_WhenAddItemSucceeds', () async {
    when(() => mockRemote.addItem(10, 2))
        .thenAnswer((_) async => testCartModel);

    final result = await repo.addItem(10, 2);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (cart) => expect(cart.id, equals(1)),
    );
  });

  test('_04_ShouldReturnNetworkFailure_WhenAddItemThrowsDioException', () async {
    when(() => mockRemote.addItem(10, 2)).thenThrow(makeDioException());

    final result = await repo.addItem(10, 2);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });

  test('_05_ShouldReturnCart_WhenUpdateItemSucceeds', () async {
    when(() => mockRemote.updateItem(1, 3))
        .thenAnswer((_) async => testCartModel);

    final result = await repo.updateItem(1, 3);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (cart) => expect(cart.id, equals(1)),
    );
  });

  test('_06_ShouldReturnCart_WhenRemoveItemSucceeds', () async {
    when(() => mockRemote.removeItem(1))
        .thenAnswer((_) async => testCartModel);

    final result = await repo.removeItem(1);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (cart) => expect(cart.id, equals(1)),
    );
  });

  test('_07_ShouldReturnUnit_WhenClearCartSucceeds', () async {
    when(() => mockRemote.clearCart()).thenAnswer((_) async => testCartModel);

    final result = await repo.clearCart();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (value) => expect(value, equals(unit)),
    );
  });

  test('_08_ShouldReturnNetworkFailure_WhenClearCartThrowsDioException',
      () async {
    when(() => mockRemote.clearCart()).thenThrow(makeDioException());

    final result = await repo.clearCart();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
