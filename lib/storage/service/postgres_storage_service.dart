import 'dart:async';

import 'package:cobalt/storage/backend_storage.dart';
import 'package:cobalt/storage/models/mapping.dart';
import 'package:cobalt/storage/service/sql_convert.dart';
import 'package:postgres/postgres.dart';

import '../../backend.dart';
import '../models/fields.dart';

class PostgresStorageService extends IBackendStorageService {
  final String host;
  final int port;
  final String database;
  final String username;
  final String password;
  late final PostgreSQLConnection connection;

  PostgresStorageService({
    this.host = 'localhost',
    this.port = 5432,
    this.database = 'cobalt',
    this.username = 'cobalt',
    this.password = 'cobalt',
  }) {
    connection = PostgreSQLConnection(
      host,
      port,
      database,
      username: username,
      password: password,
    );
  }

  @override
  FutureOr<void> init(Backend backend) async {
    await connection.open();
  }

  @override
  FutureOr<void> createDocument(StorageScope scope) {
    // TODO: implement createDocument
    throw UnimplementedError();
  }

  @override
  FutureOr<void> createIndex(
    StorageScope scope,
    String index,
    Mapping mapping,
  ) {
    String _index = getIndexFromScope(scope, index);

    List<String> fields = mapping.flatFields
        .map((field) => SqlConverter.convertField(field as Field))
        .toList();
    connection.query('CREATE TABLE $_index (${fields.join(',')})');
  }

  @override
  FutureOr<void> deleteDocument(StorageScope scope, String id) {
    // TODO: implement deleteDocument
    throw UnimplementedError();
  }

  @override
  FutureOr<void> deleteIndex(StorageScope scope, String index) {
    // TODO: implement deleteIndex
    throw UnimplementedError();
  }

  @override
  FutureOr<void> getDocument(StorageScope scope, String id) {
    // TODO: implement getDocument
    throw UnimplementedError();
  }

  @override
  FutureOr<void> replaceDocument(StorageScope scope, String id) {
    // TODO: implement replaceDocument
    throw UnimplementedError();
  }

  @override
  FutureOr<void> searchDocument(StorageScope scope, String index) {
    // TODO: implement searchDocument
    throw UnimplementedError();
  }

  @override
  FutureOr<void> updateDocument(StorageScope scope, String id) {
    // TODO: implement updateDocument
    throw UnimplementedError();
  }

  @override
  FutureOr<void> updateMapping(StorageScope scope, Mapping mapping) {
    // TODO: implement updateMapping
    throw UnimplementedError();
  }
}
