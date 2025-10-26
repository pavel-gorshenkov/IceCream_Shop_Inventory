// models.dart

/// Model for Ice Cream Flavor inventory (with freezers)
class Flavor {
  final String name;
  int king;
  int under;
  int holding;

  Flavor({required this.name, this.king = 0, this.under = 0, this.holding = 0});

  factory Flavor.fromMap(Map<String, dynamic> data) {
    return Flavor(
      name: data['name'],
      king: data['king'] ?? 0,
      under: data['under'] ?? 0,
      holding: data['holding'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'king': king, 'under': under, 'holding': holding};
  }

  void updateCounts(int newKing, int newUnder, int newHolding) {
    king = newKing;
    under = newUnder;
    holding = newHolding;
  }
}

/// Model for Ice Cream Cake inventory (with multiple sizes)
class Cake {
  final String name;
  int mini;
  int small;
  int medium;
  int large;
  int quarterSheet;

  Cake({
    required this.name,
    this.mini = 0,
    this.small = 0,
    this.medium = 0,
    this.large = 0,
    this.quarterSheet = 0,
  });

  factory Cake.fromMap(Map<String, dynamic> data) {
    return Cake(
      name: data['name'],
      mini: data['mini'] ?? 0,
      small: data['small'] ?? 0,
      medium: data['medium'] ?? 0,
      large: data['large'] ?? 0,
      quarterSheet: data['quarterSheet'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mini': mini,
      'small': small,
      'medium': medium,
      'large': large,
      'quarterSheet': quarterSheet,
    };
  }

  void updateCounts(
    int newMini,
    int newSmall,
    int newMedium,
    int newLarge,
    int newQuarterSheet,
  ) {
    mini = newMini;
    small = newSmall;
    medium = newMedium;
    large = newLarge;
    quarterSheet = newQuarterSheet;
  }
}

/// Model for Pie and Cake Slice inventory (single count)
class CakeSimple {
  final String name;
  int count;

  CakeSimple({required this.name, this.count = 0});

  factory CakeSimple.fromMap(Map<String, dynamic> data) {
    return CakeSimple(name: data['name'], count: data['count'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'count': count};
  }

  void updateCount(int newCount) {
    count = newCount;
  }
}
