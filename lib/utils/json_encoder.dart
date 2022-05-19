import 'dart:convert';

abstract class JsonSerializer<T> {
  Object? toJson(T value);
  bool test(Object? key, Object? value);
  T fromJson(Object? key, Object? value);
}

mixin JsonEncoderMixin {
  void addSerializer<T>(JsonSerializer<T> serializer);

  void removeSerializer<T>();

  String encode(Object? object);

  dynamic decode(String source);
}

class JsonEncoder with JsonEncoderMixin {
  final Map<Type, JsonSerializer> _serializers = {};

  @override
  void addSerializer<T>(JsonSerializer<T> serializer) {
    _serializers[T] = serializer;
  }

  @override
  void removeSerializer<T>() {
    _serializers.remove(T);
  }

  @override
  String encode(Object? object) {
    return jsonEncode(object, toEncodable: _encodeType);
  }

  @override
  dynamic decode(String source) {
    return jsonDecode(source, reviver: _decodeType);
  }

  Object? _encodeType(Object? value) {
    if (_serializers.containsKey(value.runtimeType)) {
      return _serializers[value.runtimeType]!.toJson(value);
    }
    return value.toString();
  }

  Object? _decodeType(Object? key, Object? value) {
    for (JsonSerializer serializer in _serializers.values) {
      if (serializer.test(key, value)) {
        return serializer.fromJson(key, value);
      }
    }
    return value;
  }
}
