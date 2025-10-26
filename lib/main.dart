import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firestore_service.dart';
import 'models.dart';
import 'inventory_spreadsheet.dart'; // Your inventory spreadsheet page.
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'ice_cream_cakes_inventory_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color appBarColor = Color.fromARGB(255, 162, 40, 93);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory App',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: appBarColor,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => IceCreamInventoryScreen(),
        '/cakes': (context) => IceCreamCakesInventoryScreen(),
        '/inventorySpreadsheet': (context) => InventorySpreadsheetScreen(),
      },
    );
  }
}

/// ---------------- Ice Cream Flavor Inventory Screen ----------------

class IceCreamInventoryScreen extends StatefulWidget {
  @override
  _IceCreamInventoryScreenState createState() =>
      _IceCreamInventoryScreenState();
}

class _IceCreamInventoryScreenState extends State<IceCreamInventoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<Flavor> yearRoundFlavors = [
    Flavor(name: "Chocolate Blackout"),
    Flavor(name: "Vanilla Bean"),
    Flavor(name: "Mint Chocolate Chip"),
    Flavor(name: "Cookies & Cream"),
    Flavor(name: "Butter Pecan"),
    Flavor(name: "Cookie Dough"),
    Flavor(name: "Mango Sorbet"),
    Flavor(name: "Chocolate"),
    Flavor(name: "Coffee Cookies"),
    Flavor(name: "Coffee Royale"),
    Flavor(name: "Chocolate Peanut Butter"),
    Flavor(name: "Coconut Joy"),
    Flavor(name: "Banana Peanut Butter Chunk"),
    Flavor(name: "Strawberry"),
    Flavor(name: "Ube"),
    Flavor(name: "Pound Cake"),
    Flavor(name: "Dulce De Leche"),
    Flavor(name: "Rum Raisin"),
    Flavor(name: "Bubble Gum"),
    Flavor(name: "Cherry Ice"),
  ];

  List<Flavor> springSummerFlavors = [
    Flavor(name: "Avocado"),
    Flavor(name: "Jackfruit"),
    Flavor(name: "Lychee"),
    Flavor(name: "Pineapple & Cream"),
    Flavor(name: "Blackberry"),
    Flavor(name: "Peach"),
    Flavor(name: "Soursop"),
    Flavor(name: "St. Cheesecake"),
  ];

  List<Flavor> specialtyFlavors = [
    Flavor(name: "Strawberry Hazelnut Crunch"),
    Flavor(name: "Irish Cream"),
  ];

  List<Flavor> fallWinterFlavors = [
    Flavor(name: "Java Mocha Donut"),
    Flavor(name: "Chocolate Cinnamon Brownie"),
    Flavor(name: "Chocolate Hazelnut"),
    Flavor(name: "Maple Walnut"),
    Flavor(name: "Blueberry Cheesecake"),
    Flavor(name: "Ginger Cookie"),
    Flavor(name: "Spicy Eggnog"),
    Flavor(name: "Peppermint Candy"),
    Flavor(name: "Red Velvet Cake"),
  ];

  // Pulls the most recent data from Firestore
  @override
  void initState() {
    super.initState();
    _firestoreService.streamFlavors().listen((fetchedFlavors) {
      setState(() {
        _updateFlavorLists(fetchedFlavors);
      });
    });
  }

  // if a flavor exists in firestore that flavor is updated
  void _updateFlavorLists(List<Flavor> fetchedFlavors) {
    void updateList(List<Flavor> list) {
      for (var fetched in fetchedFlavors) {
        int index = list.indexWhere((flavor) => flavor.name == fetched.name);
        if (index != -1) {
          list[index].updateCounts(
            fetched.king,
            fetched.under,
            fetched.holding,
          );
        }
      }
    }

    updateList(yearRoundFlavors);
    updateList(springSummerFlavors);
    updateList(specialtyFlavors);
    updateList(fallWinterFlavors);
  }

  Future<void> saveInventory(Flavor flavor) async {
    await _firestoreService.saveFlavor(flavor);
  }

  // ---------- Section added to Add a new Flavor in the UI ------------//

  void _showAddFlavorDialog(BuildContext context) {
    String flavorName = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Flavor"),
          content: TextField(
            onChanged: (value) {
              flavorName = value;
            },
            decoration: InputDecoration(hintText: "Enter flavor name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (flavorName.trim().isNotEmpty) {
                  // Create a new flavor with zero counts.
                  Flavor newFlavor = Flavor(
                    name: flavorName.trim(),
                    king: 0,
                    under: 0,
                    holding: 0,
                  );
                  // Save to Firestore.
                  saveInventory(newFlavor);
                  // Optionally, add to your UI list (for immediate feedback). // Check in Later
                  setState(() {
                    specialtyFlavors.add(
                      newFlavor,
                    ); // saves in the custom creations section
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Build a grid of flavor tiles with a top border decoration.
  Widget _buildFlavorSection(String title, List<Flavor> flavors) {
    flavors.sort((a, b) => a.name.compareTo(b.name));
    // Alternating colors for the top border.
    final List<Color> borderColors = [
      Color.fromARGB(255, 219, 166, 71),
      Color.fromARGB(255, 188, 150, 91),
      Color.fromARGB(255, 88, 38, 115),
      Color.fromARGB(255, 114, 119, 76),
      Color.fromARGB(255, 162, 40, 93),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
   // where shrinkwrap and scrollable physics was 
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          padding: const EdgeInsets.all(10),
          itemCount: flavors.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: borderColors[index % borderColors.length],
                    width: 4,
                  ),
                ),
              ),
              child: IceCreamCard(
                flavor: flavors[index],
                onCountChanged: (String section, int newCount) {
                  setState(() {
                    if (section == 'King') flavors[index].king = newCount;
                    if (section == 'Under') flavors[index].under = newCount;
                    if (section == 'Holding') flavors[index].holding = newCount;
                    saveInventory(flavors[index]);
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // -------------- App Bar/Scaffold --------------------------//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ice Cream Inventory',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              final fetchedFlavors =
                  await _firestoreService.streamFlavors().first;
              setState(() {
                _updateFlavorLists(fetchedFlavors);
              });
            },
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.add),
            tooltip:
                "Add New Flavor", // Icon button in the App bar to add a new flavor
            onPressed: () => _showAddFlavorDialog(context),
            color: Colors.white,
          ),
        ],
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
                color: Colors.white,
              ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(
                'Ice Cream Inventory',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 219, 166, 71),
              ),
            ),
            ListTile(
              title: Text('Ice Cream Cakes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/cakes');
              },
            ),
            ListTile(
              title: Text('IC Inventory Spreadsheet'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/inventorySpreadsheet');
              },
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          _buildFlavorSection("Year Round Flavors", yearRoundFlavors),
          _buildFlavorSection("Spring & Summer Flavors", springSummerFlavors),
          _buildFlavorSection("Specialty Flavors", specialtyFlavors),
          _buildFlavorSection("Fall & Winter Flavors", fallWinterFlavors),
        ],
      ),
    );
  }
}

/// ---------------- Ice Cream Card Widget ----------------

class IceCreamCard extends StatefulWidget {
  final Flavor flavor;
  final Function(String, int) onCountChanged;

  IceCreamCard({required this.flavor, required this.onCountChanged});

  @override
  _IceCreamCardState createState() => _IceCreamCardState();
}

class _IceCreamCardState extends State<IceCreamCard> {
  bool _isFlipped = false;

  void _increment(String section) {
    setState(() {
      if (section == 'King') widget.flavor.king++;
      if (section == 'Under') widget.flavor.under++;
      if (section == 'Holding') widget.flavor.holding++;
      widget.onCountChanged(section, _getCount(section));
    });
  }

  void _decrement(String section) {
    setState(() {
      if (section == 'King' && widget.flavor.king > 0) widget.flavor.king--;
      if (section == 'Under' && widget.flavor.under > 0) widget.flavor.under--;
      if (section == 'Holding' && widget.flavor.holding > 0)
        widget.flavor.holding--;
      widget.onCountChanged(section, _getCount(section));
    });
  }

  int _getCount(String section) {
    if (section == 'King') return widget.flavor.king;
    if (section == 'Under') return widget.flavor.under;
    if (section == 'Holding') return widget.flavor.holding;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlipped = !_isFlipped;
        });
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ice cream flavor name remains bold.
            Text(
              widget.flavor.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            if (!_isFlipped)
              Column(
                children: [
                  Text("King: ${widget.flavor.king}"),
                  Text("Under: ${widget.flavor.under}"),
                  Text("Holding: ${widget.flavor.holding}"),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _decrement('King'),
                      ),
                      Text('King'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _increment('King'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _decrement('Under'),
                      ),
                      Text('Under'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _increment('Under'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _decrement('Holding'),
                      ),
                      Text('Holding'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _increment('Holding'),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
