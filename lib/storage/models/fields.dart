enum FieldType {
  primitive,
  nested,
}

abstract class IField {
  String name;
  FieldType fieldType;
  Map<String, Map<String, dynamic>>? metadata;

  IField(
    this.name,
    this.fieldType, {
    this.metadata,
  });

  Map<String, dynamic> toJSON();
  void flatten(String name, List<IField> fields);
}

class Field<T> extends IField {
  String type = T.toString();
  Field(
    String name, {
    Map<String, Map<String, dynamic>>? metadata,
  }) : super(name, FieldType.primitive, metadata: metadata) {
    if (T == dynamic) {
      throw 'T must not be dynamic';
    }
  }

  Field._(String name, this.type, {Map<String, Map<String, dynamic>>? metadata})
      : super(name, FieldType.primitive, metadata: metadata);

  @override
  Map<String, dynamic> toJSON() {
    return {
      'type': type.toString(),
      'metadata': metadata,
    };
  }

  static Field fromJSON(String name, Map<dynamic, dynamic> json) {
    return Field._(
      name,
      json['type'] as String,
      metadata: json['metadata'] as Map<String, Map<String, dynamic>>?,
    );
  }

  @override
  void flatten(String name, List<IField> fields) {
    if (name.isEmpty) {
      fields.add(Field._(
        this.name,
        type,
        metadata: metadata,
      ));
    } else {
      fields.add(Field._(
        '$name.${this.name}',
        type,
        metadata: metadata,
      ));
    }
  }
}

class Fields extends IField {
  List<IField> fields;

  Fields(
    String name,
    this.fields, {
    Map<String, Map<String, dynamic>>? metadata,
  }) : super(name, FieldType.nested, metadata: metadata) {
    Set<String> duplicates = {};

    for (IField field in fields) {
      if (duplicates.contains(field.name)) {
        throw 'Duplicate field name: $name.${field.name}';
      }
      duplicates.add(field.name);
    }
  }

  @override
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {};

    for (IField field in fields) {
      json[field.name] = field.toJSON();
    }

    return {
      'fields': json,
      'metadata': metadata,
    };
  }

  static Fields fromJSON(String name, Map<String, dynamic> json) {
    List<IField> fields = [];

    if (json['fields'] == null) {
      throw 'Missing fields property';
    }

    if (json['fields'] is! Map<String, dynamic>) {
      throw 'Invalid type "fields", exepected Map<String, dynamic>, got ${json['fields'].runtimeType.toString()}';
    }

    Map<String, dynamic> fieldsMap = json['fields'] as Map<String, dynamic>;

    for (String field in fieldsMap.keys) {
      if (fieldsMap[field] is! Map<String, dynamic>) {
        throw 'Invalid field type: $name.${fieldsMap[field]}';
      }

      Map<String, dynamic> fieldMap = fieldsMap[field] as Map<String, dynamic>;
      if (fieldMap['fields'] != null) {
        fields.add(Fields.fromJSON(field, fieldMap));
      } else {
        fields.add(Field.fromJSON(field, fieldMap));
      }
    }

    return Fields(name, fields);
  }

  @override
  void flatten(String name, List<IField> fields) {
    for (IField field in this.fields) {
      if (name.isEmpty) {
        field.flatten(this.name, fields);
      } else {
        field.flatten('$name.${this.name}', fields);
      }
    }
  }
}
