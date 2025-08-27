import '../models/islamic_event.dart';

class EventsService {
  // Sample events data - in production this would come from an API
  static final List<IslamicEvent> _sampleEvents = [
    const IslamicEvent(
      title: 'Shahadat Imam Hasan SA',
      description: 'Martyrdom of Imam Hasan ibn Ali (AS)',
      location: 'Medina, Saudi Arabia',
      category: 'Shahadat',
      isImportant: true,
    ),
    const IslamicEvent(
      title: 'Eid al-Fitr',
      description: 'Festival of Breaking the Fast',
      location: 'Worldwide',
      category: 'Eid',
      isImportant: true,
    ),
    const IslamicEvent(
      title: 'Eid al-Adha',
      description: 'Festival of Sacrifice',
      location: 'Worldwide',
      category: 'Eid',
      isImportant: true,
    ),
    const IslamicEvent(
      title: 'Laylat al-Qadr',
      description: 'Night of Power',
      location: 'Worldwide',
      category: 'Ramadan',
      isImportant: true,
    ),
    const IslamicEvent(
      title: 'Ashura',
      description: 'Day of Ashura - Martyrdom of Imam Husayn (AS)',
      location: 'Karbala, Iraq',
      category: 'Shahadat',
      isImportant: true,
    ),
  ];

  // Get events for a specific Hijri date
  static List<IslamicEvent> getEventsForDate(int hijriDay, int hijriMonth) {
    // This is a simplified implementation
    // In production, you would query a database or API
    List<IslamicEvent> events = [];
    
    // Add sample events based on date (simplified logic)
    if (hijriMonth == 1 && hijriDay == 10) {
      events.add(_sampleEvents[4]); // Ashura
    } else if (hijriMonth == 3 && hijriDay == 15) {
      events.add(_sampleEvents[0]); // Shahadat Imam Hasan
    }
    
    return events;
  }

  // Get all events for a month
  static List<IslamicEvent> getEventsForMonth(int hijriMonth) {
    List<IslamicEvent> monthEvents = [];
    
    for (int day = 1; day <= 30; day++) {
      final dayEvents = getEventsForDate(day, hijriMonth);
      monthEvents.addAll(dayEvents);
    }
    
    return monthEvents;
  }

  // Get important events
  static List<IslamicEvent> getImportantEvents() {
    return _sampleEvents.where((event) => event.isImportant).toList();
  }

  // Search events by title or description
  static List<IslamicEvent> searchEvents(String query) {
    if (query.isEmpty) return [];
    
    return _sampleEvents.where((event) {
      return event.title.toLowerCase().contains(query.toLowerCase()) ||
             event.description.toLowerCase().contains(query.toLowerCase()) ||
             event.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
