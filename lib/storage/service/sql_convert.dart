import 'package:cobalt/storage/models/fields.dart';

class SqlConverter {
  static _getFieldType(Field field) {
    switch (field.type) {
      case 'String':
        return 'TEXT';
      case 'int':
        return 'INT';
      case 'double':
        return 'NUMBER';
      case 'bool':
        return 'BOOLEAN';
      case 'date':
        return 'TIMESTAMP';
      default:
        throw UnsupportedError('Unsupported type: ${field.type}');
    }
  }

  static String convertField(Field field) {
    final List<String> parts = [];

    parts.add(field.name.replaceAll('.', '_'));
    parts.add(_getFieldType(field));

    Map<String, dynamic>? metadata = field.metadata?['postgres'];
    if (metadata != null) {
      if (metadata['not_null'] != null) {
        parts.add('NOT NULL');
      }
      if (metadata['unique'] != null) {
        parts.add('UNIQUE');
      }
    }

    return parts.join(' ');
  }
}
