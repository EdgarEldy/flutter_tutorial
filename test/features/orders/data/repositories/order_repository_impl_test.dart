import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/orders/data/datasources/order_local_datasource.dart';
import 'package:flutter_tutorial/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:flutter_tutorial/features/orders/data/models/order_item_model.dart';
import 'package:flutter_tutorial/features/orders/data/models/order_model.dart';
import 'package:flutter_tutorial/features/orders/data/repositories/order_repository_impl.dart';
import 'package:flutter_tutorial/features/orders/domain/entities/order.dart';

class MockOrderRemoteDatasource extends Mock implements OrderRemoteDatasource {}

class MockOrderLocalDatasource extends Mock implements OrderLocalDatasource {}

DioException makeDioException() => DioException(
  requestOptions: RequestOptions(path: '/test'),
  message: 'Network error',
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const OrderModel(
        id: 0,
        orderNumber: '',
        status: 'PENDING',
        totalAmount: 0,
        items: [],
      ),
    );
  });

  late MockOrderRemoteDatasource mockRemote;
  late MockOrderLocalDatasource mockLocal;
  late OrderRepositoryImpl repo;

  const testOrderItemModel = OrderItemModel(
    id: 1,
    productId: 10,
    productName: 'Test',
    unitPrice: 29.99,
    quantity: 2,
    subtotal: 59.98,
  );

  const testOrderModel = OrderModel(
    id: 1,
    orderNumber: 'ORD-001',
    status: 'PENDING',
    totalAmount: 59.98,
    items: [testOrderItemModel],
  );

  final orderRow = {
    'id': 1,
    'order_number': 'ORD-001',
    'status': 'PENDING',
    'total_amount': 59.98,
    'cached_at': 1700000000000,
  };

  final itemRow = {
    'id': 1,
    'order_id': 1,
    'product_id': 10,
    'product_name': 'Test',
    'unit_price': 29.99,
    'quantity': 2,
    'subtotal': 59.98,
  };

  setUp(() {
    mockRemote = MockOrderRemoteDatasource();
    mockLocal = MockOrderLocalDatasource();
    repo = OrderRepositoryImpl(remote: mockRemote, local: mockLocal);
  });

  group('getOrders()', () {
    test('_01_ShouldReturnCachedOrders_WhenCacheIsNonEmpty', () async {
      when(() => mockLocal.getOrders()).thenAnswer((_) async => [orderRow]);
      when(() => mockLocal.getOrderItems(1)).thenAnswer((_) async => [itemRow]);
      // Stub remote so the background refresh does not throw MissingStubError
      when(() => mockRemote.getOrders())
          .thenAnswer((_) async => [testOrderModel]);
      when(() => mockLocal.upsertOrders(any())).thenAnswer((_) async {});

      final result = await repo.getOrders();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (orders) {
        expect(orders, hasLength(1));
        expect(orders.first.id, equals(1));
        expect(orders.first.orderNumber, equals('ORD-001'));
        expect(orders.first.status, equals(OrderStatus.pending));
      });
      // Remote is called by the background refresh (fire-and-forget); we only
      // verify the returned data came from the local cache.
    });

    test('_02_ShouldFetchFromNetworkAndSave_WhenCacheIsEmpty', () async {
      when(() => mockLocal.getOrders()).thenAnswer((_) async => []);
      when(() => mockRemote.getOrders())
          .thenAnswer((_) async => [testOrderModel]);
      when(() => mockLocal.upsertOrders(any())).thenAnswer((_) async {});

      final result = await repo.getOrders();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (orders) {
        expect(orders, hasLength(1));
        expect(orders.first.id, equals(1));
        expect(orders.first.status, equals(OrderStatus.pending));
      });
      verify(() => mockRemote.getOrders()).called(1);
      verify(() => mockLocal.upsertOrders(any())).called(1);
    });

    test('_03_ShouldReturnLeft_WhenNetworkFailsAndCacheEmpty', () async {
      when(() => mockLocal.getOrders()).thenAnswer((_) async => []);
      when(() => mockRemote.getOrders()).thenThrow(makeDioException());

      final result = await repo.getOrders();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('getOrderById()', () {
    test('_04_ShouldReturnCachedOrder_WhenOrderIsInCache', () async {
      when(() => mockLocal.getOrderById(1)).thenAnswer((_) async => orderRow);
      when(() => mockLocal.getOrderItems(1)).thenAnswer((_) async => [itemRow]);

      final result = await repo.getOrderById(1);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (order) {
        expect(order.id, equals(1));
        expect(order.orderNumber, equals('ORD-001'));
        expect(order.items, hasLength(1));
      });
      verifyNever(() => mockRemote.getOrderById(any()));
    });

    test('_05_ShouldFetchFromRemote_WhenOrderNotInCache', () async {
      when(() => mockLocal.getOrderById(1)).thenAnswer((_) async => null);
      when(() => mockRemote.getOrderById(1))
          .thenAnswer((_) async => testOrderModel);
      when(() => mockLocal.upsertOrder(any())).thenAnswer((_) async {});

      final result = await repo.getOrderById(1);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (order) {
        expect(order.id, equals(1));
        expect(order.status, equals(OrderStatus.pending));
      });
      verify(() => mockRemote.getOrderById(1)).called(1);
      verify(() => mockLocal.upsertOrder(testOrderModel)).called(1);
    });

    test('_06_ShouldReturnLeft_WhenRemoteFailsAndCacheEmpty', () async {
      when(() => mockLocal.getOrderById(1)).thenAnswer((_) async => null);
      when(() => mockRemote.getOrderById(1)).thenThrow(makeDioException());

      final result = await repo.getOrderById(1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('refreshOrders()', () {
    test(
      '_07_ShouldFetchFromNetworkAndReplaceCacheWhenRefreshCalled',
      () async {
        when(() => mockRemote.getOrders())
            .thenAnswer((_) async => [testOrderModel]);
        when(() => mockLocal.upsertOrders(any())).thenAnswer((_) async {});

        final result = await repo.refreshOrders();

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('expected Right'), (orders) {
          expect(orders, hasLength(1));
          expect(orders.first.id, equals(1));
          expect(orders.first.status, equals(OrderStatus.pending));
        });
        verifyNever(() => mockLocal.deleteAllOrders());
        verify(() => mockRemote.getOrders()).called(1);
        verify(() => mockLocal.upsertOrders(any())).called(1);
      },
    );

    test('_08_ShouldReturnLeft_WhenNetworkFailsDuringRefresh', () async {
      when(() => mockLocal.deleteAllOrders()).thenAnswer((_) async {});
      when(() => mockRemote.getOrders()).thenThrow(makeDioException());

      final result = await repo.refreshOrders();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
