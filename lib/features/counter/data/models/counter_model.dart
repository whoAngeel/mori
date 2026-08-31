import '../../../../core/database/app_database.dart';
import '../../domain/entities/counter.dart';

/// Data-layer representation. Knows how to translate between the Drift row
/// (`CounterEntry`, generated) and the Domain [Counter] entity.
///
/// Extending the entity keeps mapping cheap while still isolating persistence
/// concerns (JSON, DB columns) in this layer.
class CounterModel extends Counter {
  const CounterModel({required super.value});

  factory CounterModel.fromRow(CounterEntry row) =>
      CounterModel(value: row.value);

  factory CounterModel.fromEntity(Counter entity) =>
      CounterModel(value: entity.value);

  Counter toEntity() => Counter(value: value);
}
