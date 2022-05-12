import 'dart:convert';

import 'fields.dart';

class Mapping {
  List<IField> fields;
  List<IField> flatFields = [];

  Mapping(this.fields) {
    Set<String> duplicates = {};

    for (IField field in fields) {
      if (duplicates.contains(field.name)) {
        throw "Duplicate field name: ${field.name}";
      }
      duplicates.add(field.name);
    }

    for (IField field in fields) {
      field.flatten("", flatFields);
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {};

    for (IField field in fields) {
      json[field.name] = field.toJSON();
    }

    return json;
  }

  static Mapping fromJSON(Map<String, dynamic> json) {
    List<IField> fields = [];

    for (String fieldName in json.keys) {
      if (json[fieldName] is! Map<String, dynamic>) {
        throw "Invalid field type: ${json[fieldName]}";
      }

      Map<String, dynamic> fieldMap = json[fieldName] as Map<String, dynamic>;
      if (fieldMap['fields'] != null) {
        fields.add(Fields.fromJSON(fieldName, fieldMap));
      } else {
        fields.add(Field.fromJSON(fieldName, fieldMap));
      }
    }

    return Mapping(fields);
  }
}
