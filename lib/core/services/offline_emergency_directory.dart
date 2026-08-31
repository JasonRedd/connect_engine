class EmergencyContact {
  final String title;
  final String number;
  final String category;
  final String description;

  const EmergencyContact({
    required this.title,
    required this.number,
    required this.category,
    required this.description,
  });
}

class OfflineEmergencyDirectory {
  static const List<EmergencyContact> nationalHelplines = [
    EmergencyContact(
      title: 'National Emergency Number',
      number: '112',
      category: 'General Safety',
      description: 'Unified emergency response for Police, Fire, and Ambulance.',
    ),
    EmergencyContact(
      title: 'Medical Emergency / Ambulance',
      number: '108',
      category: 'Medical',
      description: 'Free emergency ambulance dispatch and trauma care.',
    ),
    EmergencyContact(
      title: 'Fire & Rescue',
      number: '101',
      category: 'Fire',
      description: 'Immediate fire brigade and rescue operation dispatch.',
    ),
    EmergencyContact(
      title: 'Women Emergency Helpline',
      number: '181',
      category: 'Protection',
      description: '24/7 support for women in distress, domestic safety, and crisis shelter.',
    ),
    EmergencyContact(
      title: 'Poison Information Center',
      number: '1066',
      category: 'Medical / Poison',
      description: 'Emergency toxicological and antidote guidance.',
    ),
    EmergencyContact(
      title: 'Tele-MANAS Mental Health Helpline',
      number: '14416',
      category: 'Mental Health',
      description: '24/7 mental health counseling and psychiatric crisis support.',
    ),
  ];

  static List<EmergencyContact> search(String query) {
    final lower = query.toLowerCase();
    return nationalHelplines.where((contact) {
      return contact.title.toLowerCase().contains(lower) ||
          contact.category.toLowerCase().contains(lower) ||
          contact.description.toLowerCase().contains(lower);
    }).toList();
  }
}