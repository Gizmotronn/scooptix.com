import 'package:flutter_test/flutter_test.dart';
import 'package:ticketapp/model/event.dart';

void main() {

  group('Counter', () {
    String name = "Test Event";
    String description = "Test Description";
    String summary = "Test Summary";
    String coverimage = "someurl";
    String address = "123 Fake Street";
    DateTime date = DateTime(2022, 6, 9, 17);

    test('Load event from empty map', () {
      expect(() => Event.fromMap('test', {}), throwsA(isA<Exception>()));
    });

    test('Load event from incomplete map', () {

      // Missing event date
      expect(() => Event.fromMap('test', {
        "name": name,
        "description": description,
        "summary": summary,
        "coverimage": coverimage,
        "address": address,
      }), throwsA(isA<Exception>()));
    });

    test('Load event from valid map', () {
      Event event = Event.fromMap('test', {
        "name": name,
        "description": description,
        "summary": summary,
        "coverimage": coverimage,
        "address": address,
        "date": date
      });

      expect(event.name, name);
      expect(event.description, description);
      expect(event.summary, summary);
      expect(event.coverImageURL, coverimage);
      expect(event.address, address);
      expect(event.date, date);
    });
  });


}