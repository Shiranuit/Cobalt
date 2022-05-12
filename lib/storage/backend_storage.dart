import 'dart:async';

import 'package:cobalt/backend.dart';
import 'package:cobalt/storage/models/mapping.dart';

enum StorageScope { public, private }

abstract class IBackendStorageService {
  String getIndexFromScope(StorageScope scope, String index) {
    switch (scope) {
      case StorageScope.public:
        return 'public_$index';
      case StorageScope.private:
        return 'private_$index';
    }
  }

  FutureOr<void> init(Backend backend);

  FutureOr<void> createIndex(StorageScope scope, String index, Mapping mapping);
  FutureOr<void> deleteIndex(StorageScope scope, String index);

  FutureOr<void> updateMapping(StorageScope scope, Mapping mapping);

  FutureOr<void> createDocument(
    StorageScope scope,
  );
  FutureOr<void> deleteDocument(StorageScope scope, String id);
  FutureOr<void> updateDocument(StorageScope scope, String id);
  FutureOr<void> replaceDocument(StorageScope scope, String id);

  FutureOr<void> getDocument(StorageScope scope, String id);
  FutureOr<void> searchDocument(StorageScope scope, String index);
}
