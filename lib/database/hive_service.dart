import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../adapter/event_type_adapter.dart';
import '../adapter/general_ticket_settings_adapter.dart';
import '../adapter/perforated_ticket_settings_adapter.dart';
import '../adapter/ticket_style_adapter.dart';
import '../model/event_hive_model.dart';
import '../model/qr_code_model.dart';

class HiveService {
  static const String eventBoxName = 'eventsBox';

  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    Hive.registerAdapter(EventHiveModelAdapter());
    Hive.registerAdapter(QRCodeAdapter());
    Hive.registerAdapter(EventTypeAdapter());
    Hive.registerAdapter(TicketStyleAdapter());
    Hive.registerAdapter(GeneralTicketSettingsAdapter());
    Hive.registerAdapter(PerforatedTicketSettingsAdapter());

    await Hive.openBox<EventHiveModel>(eventBoxName);
  }

  Box<EventHiveModel> get eventBox => Hive.box<EventHiveModel>(eventBoxName);

  Future<void> saveEvent(EventHiveModel event) async {
    await eventBox.put(event.id, event);
  }

  Future<void> deleteEvent(String id) async {
    await eventBox.delete(id);
  }

  List getAllEvents() {
    return eventBox.values.toList();
  }

  Future<void> clearAll() async {
    await eventBox.clear();
  }
}
