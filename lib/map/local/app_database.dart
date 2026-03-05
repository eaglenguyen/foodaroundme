import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../model/place.dart' as q;

part 'app_database.g.dart';

// run if making changes -> flutter pub run build_runner build --delete-conflicting-outputs.
// also add to onUpgrade
class PlacesDetailTable extends Table {
  TextColumn get id => text()(); // place_id
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get categories => text()();  // JSON Strings
  TextColumn get website => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get openingHours => text().nullable()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  IntColumn get lastFetched =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

}

@DriftDatabase(tables: [PlacesDetailTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(placesDetailTable);
      }

      if (from < 4) {
        await m.addColumn(placesDetailTable, placesDetailTable.openingHours);
      }

    },
  );


  Future<void> upsertPlaceDetails(q.Place place) async {
    await into(placesDetailTable).insertOnConflictUpdate(
      PlacesDetailTableCompanion(
        id: Value(place.id),
        name: Value(place.name),
        address: Value(place.address),
        categories: Value(jsonEncode(place.categories)), // jsonEncode = TypeConverter
        website: Value(place.website),
        phone: Value(place.phone),
        openingHours: Value(place.openingHours),
        lat: Value(place.location.latitude),
        lng: Value(place.location.longitude),
        lastFetched: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }


  Future<q.Place?> getCachedDetails(String placeId) async {
    final row = await (select(placesDetailTable)
    ..where((tbl) => tbl.id.equals(placeId)))
        .getSingleOrNull();

    if (row == null) return null;

    return q.Place(
      id: row.id,
      name: row.name,
      address: row.address,
      categories: (jsonDecode(row.categories) as List).cast<String>(),
      website: row.website,
      phone: row.phone,
      openingHours: row.openingHours,
      location: LatLng(row.lat, row.lng),
    );
  }


}



LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'places.db'));
    return NativeDatabase(file);
  });
}

