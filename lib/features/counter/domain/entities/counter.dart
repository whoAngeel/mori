/// Pure business object. No JSON, no Drift, no Flutter imports — ever.
class Counter {
  const Counter({required this.value});

  final int value;

  Counter copyWith({int? value}) => Counter(value: value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Counter && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Counter(value: $value)';
}
