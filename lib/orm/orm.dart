library orm;

mixin Node {
  String evaluate() => "";

  And and<T>(T node) {
    return And<Node, T>(this, node);
  }

  Or or<T>(T node) {
    return Or<Node, T>(this, node);
  }

  Equal equal<T>(T node) {
    return Equal<Node, T>(this, node);
  }

  GreaterOrEqual greaterOrEqual<T>(T node) {
    return GreaterOrEqual<Node, T>(this, node);
  }

  GreaterThan greaterThan<T>(T node) {
    return GreaterThan<Node, T>(this, node);
  }

  LessOrEqual lessOrEqual<T>(T node) {
    return LessOrEqual<Node, T>(this, node);
  }

  LessThan lessThan<T>(T node) {
    return LessThan<Node, T>(this, node);
  }

  operator >(Node node) {
    return GreaterThan(this, node);
  }

  operator <(Node node) {
    return LessThan(this, node);
  }

  operator >=(Node node) {
    return GreaterOrEqual(this, node);
  }

  operator <=(Node node) {
    return LessOrEqual(this, node);
  }

  operator &(Node node) {
    return And(this, node);
  }

  operator |(Node node) {
    return Or(this, node);
  }
}

abstract class Operator with Node {}

class And<T, U> with Node implements Operator {
  final Node left;
  final Node right;

  And(T left, U right)
      : left = Value.from(left),
        right = Value.from(right);

  @override
  String evaluate() {
    return '(${left.evaluate()} AND ${right.evaluate()})';
  }
}

class Or<T, U> with Node implements Operator {
  final Node left;
  final Node right;

  Or(T left, U right)
      : left = Value.from(left),
        right = Value.from(right);

  @override
  String evaluate() {
    return '(${left.evaluate()} OR ${right.evaluate()})';
  }
}

class Not<T> with Node implements Operator {
  final Node left;

  Not(T left) : left = Value.from(left);

  @override
  String evaluate() {
    return '(NOT ${left.evaluate()})';
  }
}

class Equal<T, U> with Node implements Operator {
  final Node left;
  final Node right;

  Equal(T left, U right)
      : left = Value.from(left),
        right = Value.from(right);

  @override
  String evaluate() {
    return '(${left.evaluate()}=${right.evaluate()})';
  }
}

class GreaterThan<T, U> with Node implements Operator {
  final Node left;
  final Node right;

  GreaterThan(T left, U right)
      : left = Value.from(left),
        right = Value.from(right);

  @override
  String evaluate() {
    return '(${left.evaluate()}>${right.evaluate()})';
  }
}

class LessThan<T, U> with Node implements Operator {
  final Node left;
  final Node right;

  LessThan(T left, U right)
      : left = Value.from(left),
        right = Value.from(right);

  @override
  String evaluate() {
    return '(${left.evaluate()}<${right.evaluate()})';
  }
}

class GreaterOrEqual<T, U> with Node implements Operator {
  final Node left;
  final Node right;

  GreaterOrEqual(T left, U right)
      : left = Value.from(left),
        right = Value.from(right);

  @override
  String evaluate() {
    return '(${left.evaluate()}>=${right.evaluate()})';
  }
}

class LessOrEqual<T, U> with Node implements Operator {
  final Node left;
  final Node right;

  LessOrEqual(T left, U right)
      : left = Value.from(left),
        right = Value.from(right);

  @override
  String evaluate() {
    return '(${left.evaluate()}<=${right.evaluate()})';
  }
}

class Where<T> with Node implements Operator {
  final Node left;

  Where(T left) : left = Value.from(left);

  @override
  String evaluate() {
    return 'WHERE ${left.evaluate()}';
  }
}

class Field with Node implements Operator {
  final String name;

  Field(this.name);

  @override
  String evaluate() {
    return name;
  }
}

class Value<T> with Node {
  final T value;

  Value(this.value);

  static Node from<T>(T value) {
    if (T is Node) {
      return value as Node;
    } else if (value is Node) {
      return value;
    }
    return Value(value);
  }

  @override
  String evaluate() {
    if (value == null) {
      return 'NULL';
    }

    switch (T) {
      case String:
        return "'$value'";
      case int:
        return (value as int).toString();
      case double:
        return (value as double).toString();
      case bool:
        return value == true ? 'TRUE' : 'FALSE';
      case DateTime:
        return (value as DateTime).toUtc().millisecondsSinceEpoch.toString();
      case Node:
        return (value as Node).evaluate();
      case Operator:
        return (value as Operator).evaluate();
      default:
        throw UnsupportedError('Unsupported type: $T');
    }
  }
}

enum SortOrder { ascend, descend }

class Sort with Node {
  String field;
  SortOrder sortOrder;
  Sort(this.field, this.sortOrder);

  @override
  String evaluate() {
    final String sort = sortOrder == SortOrder.ascend ? 'ASC' : 'DESC';
    return "$field $sort";
  }
}

class Order with Node {
  final List<Sort> sort;
  Order(this.sort);

  @override
  String evaluate() {
    final sortFields = sort.map((e) => e.evaluate()).join(',');
    return "ORDER BY $sortFields";
  }
}

class Selected with Node {
  late final List<String> _fields;
  late final String? _table;
  Where? _where;
  Order? _order;

  Selected._(List<String> fields, String table) {
    _fields = fields;
    _table = table;
  }

  Selected where<T>(T node) {
    _where = Where<T>(node);
    return this;
  }

  Selected sort(List<Sort> node) {
    _order = Order(node);
    return this;
  }

  @override
  String evaluate() {
    List<Node> commands = [];
    if (_where != null) {
      commands.add(_where as Node);
    }
    if (_order != null) {
      commands.add(_order as Node);
    }

    final properties = commands.map((e) => e.evaluate()).join(' ');
    return "SELECT ${_fields.join(',')} FROM $_table $properties";
  }
}

class Select with Node {
  final List<String> fields;

  Select(this.fields);

  Selected from(String table) {
    return Selected._(fields, table);
  }
}

class Insert with Node {}
