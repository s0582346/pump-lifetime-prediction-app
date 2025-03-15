import 'package:sqflite/sqflite.dart';

class PumpRepository {
  final Database db;

  PumpRepository({required this.db});

  Future<List<Map<String, dynamic>>> getPumps() async {
    final List<Map<String, dynamic>> pumps = await db.rawQuery(
      'SELECT * FROM pumps',
    );
    return pumps;
  }

  Future<void> deletePump(String id) async {
    await db.delete('pumps', where: 'id = ?', whereArgs: [id]);
  }
}