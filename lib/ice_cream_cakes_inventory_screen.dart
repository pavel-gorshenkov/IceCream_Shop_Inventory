import 'dart:async';
import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'models.dart';

// Generic deletion dialog functions (you can place these at the top or in a helper file).
void showInitialDeleteDialogGeneric({
  required BuildContext context,
  required dynamic item,
  required String category,
  required VoidCallback onConfirmed,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Remove Flavor",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        content: Icon(Icons.delete, color: Colors.red, size: 50),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop(); // Close initial dialog
              showConfirmDeleteDialogGeneric(
                context: context,
                item: item,
                category: category,
                onConfirmed: onConfirmed,
              );
            },
            child: Text("Remove Flavor"),
          ),
        ],
      );
    },
  );
}

void showConfirmDeleteDialogGeneric({
  required BuildContext context,
  required dynamic item,
  required String category,
  required VoidCallback onConfirmed,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.red[50],
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text(
              "Confirm Removal",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          "Removing \"${item.name}\" from the Inventory Screen will " +
              (category == "Cake"
                  ? "delete it PERMANENTLY. Pavel is WATCHING YOU."
                  : "NOT remove it from the Inventory Spreadsheet.") +
              "\nAre you sure?",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirmed();
            },
            child: Text("Remove from Inventory Screen"),
          ),
        ],
      );
    },
  );
}

/// ---------------- Inventory Screen for Cakes, Pies, and Cake Slices ----------------

class IceCreamCakesInventoryScreen extends StatefulWidget {
  @override
  _IceCreamCakesInventoryScreenState createState() =>
      _IceCreamCakesInventoryScreenState();
}

class _IceCreamCakesInventoryScreenState
    extends State<IceCreamCakesInventoryScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();

  Timer? _deleteTimer;

  void _startDeleteTimer({
    required dynamic item,
    required String category,
    required int index,
  }) {
    _deleteTimer?.cancel();
    _deleteTimer = Timer(Duration(seconds: 10), () {
      // 5‑second “long press” expired → show your existing dialogs:
      showInitialDeleteDialogGeneric(
        context: context,
        item: item,
        category: category,
        onConfirmed: () {
          setState(() {
            // remove locally
            if (category == "Cake")
              cakes.removeAt(index);
            else if (category == "Pie")
              pies.removeAt(index);
            else if (category == "Cake Slice")
              cakeSlices.removeAt(index);
          });
          // remove from Firestore
          if (category == "Cake")
            _firestoreService.removeCake(item as Cake);
          else if (category == "Pie")
            _firestoreService.removePie(item as CakeSimple);
          else if (category == "Cake Slice")
            _firestoreService.removeCakeSlice(item as CakeSimple);
        },
      );
    });
  }

  void _cancelDeleteTimer() {
    _deleteTimer?.cancel();
    _deleteTimer = null;
  }

  List<Cake> hardCodedCakes = [
    Cake(name: "Classic Birthday Cake"),
    Cake(name: "Choc. Chip Cookie Dough"),
    Cake(name: "Brownie"),
    Cake(name: "Peanut Butter"),
    Cake(name: "Cho. Mocha"),
    Cake(name: "Pecan Caramel"),
    Cake(name: "Raspberry Ruffle"),
    Cake(name: "Celebration"),
    Cake(name: "Nutty Coconut"),
    Cake(name: "Yellow Drip Cone"),
    Cake(name: "Balloon"),
    Cake(name: "COTM"),
  ];
  List<Cake> cakes = [];

  List<CakeSimple> hardCodedPies = [
    CakeSimple(name: "Cookielicious"),
    CakeSimple(name: "Pete's Chocolate"),
    CakeSimple(name: "Mrs B's Pecan"),
    CakeSimple(name: "Pumpkin"),
    CakeSimple(name: "Strawberry Fields"),
  ];
  List<CakeSimple> pies = [];

  List<CakeSimple> hardCodedCakeSlices = [
    CakeSimple(name: "Cookielicious"),
    CakeSimple(name: "Sprinkle Crunch"),
  ];
  List<CakeSimple> cakeSlices = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    cakes = List.from(hardCodedCakes);
    pies = List.from(hardCodedPies);
    cakeSlices = List.from(hardCodedCakeSlices);

    _tabController = TabController(length: 3, vsync: this);

    _firestoreService.streamCakes().listen((fetchedCakes) {
      setState(() {
        for (var fetched in fetchedCakes) {
          int index = cakes.indexWhere((cake) => cake.name == fetched.name);
          if (index != -1) {
            cakes[index] = fetched;
          } else {
            cakes.add(fetched);
          }
        }
        cakes.sort((a, b) => a.name.compareTo(b.name));
      });
    });

    _firestoreService.streamPies().listen((fetchedPies) {
      setState(() {
        for (var fetched in fetchedPies) {
          int index = pies.indexWhere((pie) => pie.name == fetched.name);
          if (index != -1) {
            pies[index] = fetched;
          } else {
            pies.add(fetched);
          }
        }
        pies.sort((a, b) => a.name.compareTo(b.name));
      });
    });

    _firestoreService.streamCakeSlices().listen((fetchedSlices) {
      setState(() {
        for (var fetched in fetchedSlices) {
          int index = cakeSlices.indexWhere(
            (slice) => slice.name == fetched.name,
          );
          if (index != -1) {
            cakeSlices[index] = fetched;
          } else {
            cakeSlices.add(fetched);
          }
        }
        cakeSlices.sort((a, b) => a.name.compareTo(b.name));
      });
    });
  }

  Future<void> saveCake(Cake cake) async {
    await _firestoreService.saveCake(cake);
  }

  Future<void> savePie(CakeSimple pie) async {
    await _firestoreService.savePie(pie);
  }

  Future<void> saveCakeSlice(CakeSimple slice) async {
    await _firestoreService.saveCakeSlice(slice);
  }

  /// Generic helper that builds a grid section for inventory items.
  Widget _buildInventorySection<T>({
    required List<T> items,
    required String category,
    required Widget Function(T item, int index) itemBuilder,
  }) {
    final List<Color> borderColors = [
      Color.fromARGB(255, 219, 166, 71),
      Color.fromARGB(255, 188, 150, 91),
      Color.fromARGB(255, 88, 38, 115),
      Color.fromARGB(255, 114, 119, 76),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,

      // where shrinkwrap true and scrollable physics was
      itemBuilder: (context, index) {
        return GestureDetector(
          /*onLongPress: () {
            // Invoke generic deletion dialogs.
            showInitialDeleteDialogGeneric(
              context: context,
              item: items[index],
              category: category,
              onConfirmed: () async {
                if (category == "Cake") {
                  await _firestoreService.removeCake(items[index] as Cake);
                } else if (category == "Pie") {
                  await _firestoreService.removePie(items[index] as CakeSimple);
                } else if (category == "Cake Slice") {
                  await _firestoreService.removeCakeSlice(
                    items[index] as CakeSimple,
                  );
                }
                setState(() {
                  items.removeAt(index);
                });
              },
            );
          },
          */
          // user starts pressing
          onTapDown:
              (_) => _startDeleteTimer(
                item: items[index],
                category: category,
                index: index,
              ),
          // user lifts finger before timer fires
          onTapUp: (_) => _cancelDeleteTimer(),
          onTapCancel: () => _cancelDeleteTimer(),

          child: Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: borderColors[index % borderColors.length],
                  width: 4,
                ),
              ),
            ),
            child: itemBuilder(items[index], index),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ice Cream Cakes Inventory",
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Cakes"),
            Tab(text: "Pies"),
            Tab(text: "Cake Slices"),
          ],
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: "Add New Flavor",
            onPressed: () => _showAddFlavorDialog(context),
            color: Colors.white,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Cakes tab using CakeCard.
          Expanded(
            child: _buildInventorySection<Cake>(
              items: cakes,
              category: "Cake",
              itemBuilder: (cake, index) {
                return CakeCard(
                  cake: cake,
                  onCountsChanged: (mini, small, medium, large, quarterSheet) {
                    setState(() {
                      cakes[index] = Cake(
                        name: cake.name,
                        mini: mini,
                        small: small,
                        medium: medium,
                        large: large,
                        quarterSheet: quarterSheet,
                      );
                    });
                    saveCake(cakes[index]);
                  },
                );
              },
            ),
          ),

          // Pies tab using SimpleCard.
          Column(
            children: [
              Expanded(
                child: _buildInventorySection<CakeSimple>(
                  items: pies,
                  category: "Pie",
                  itemBuilder:
                      (pie, index) => SimpleCard(
                        item: pie,
                        onCountChanged: (newCount) {
                          setState(() {
                            pies[index].count = newCount;
                          });
                          savePie(pies[index]);
                        },
                      ),
                ),
              ),
            ],
          ),

          // Cake Slices tab using SimpleCard.
          Column(
            children: [
              Expanded(
                child: _buildInventorySection<CakeSimple>(
                  items: cakeSlices,
                  category: "Cake Slice",
                  itemBuilder:
                      (slice, index) => SimpleCard(
                        item: slice,
                        onCountChanged: (newCount) {
                          setState(() {
                            cakeSlices[index].count = newCount;
                          });
                          saveCakeSlice(cakeSlices[index]);
                        },
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Add New Flavor Dialog (existing code) ----------
  void _showAddFlavorDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String flavorName = "";
    String category = "Cake"; // default option

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Flavor"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "Flavor Name"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a flavor name";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    flavorName = value!.trim();
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: category,
                  items:
                      <String>["Cake", "Pie", "Cake Slice"]
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                  onChanged: (newVal) {
                    if (newVal != null) {
                      setState(() {
                        category = newVal;
                      });
                    }
                  },
                  decoration: InputDecoration(labelText: "Category"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (category == "Cake") {
                    Cake newCake = Cake(name: flavorName);
                    setState(() {
                      cakes.add(newCake);
                      cakes.sort((a, b) => a.name.compareTo(b.name));
                    });
                    await saveCake(newCake);
                  } else if (category == "Pie") {
                    CakeSimple newPie = CakeSimple(name: flavorName);
                    setState(() {
                      pies.add(newPie);
                      pies.sort((a, b) => a.name.compareTo(b.name));
                    });
                    await savePie(newPie);
                  } else if (category == "Cake Slice") {
                    CakeSimple newSlice = CakeSimple(name: flavorName);
                    setState(() {
                      cakeSlices.add(newSlice);
                      cakeSlices.sort((a, b) => a.name.compareTo(b.name));
                    });
                    await saveCakeSlice(newSlice);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

/// ---------------- Simple Card Widget (for Pies and Cake Slices) ----------------
class SimpleCard extends StatefulWidget {
  final CakeSimple item;
  final Function(int) onCountChanged;
  SimpleCard({required this.item, required this.onCountChanged});
  @override
  _SimpleCardState createState() => _SimpleCardState();
}

class _SimpleCardState extends State<SimpleCard> {
  bool _isFlipped = false;
  void _increment() {
    setState(() {
      widget.item.count++;
      widget.onCountChanged(widget.item.count);
    });
  }

  void _decrement() {
    setState(() {
      if (widget.item.count > 0) {
        widget.item.count--;
        widget.onCountChanged(widget.item.count);
      }
    });
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
            Text(
              widget.item.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            if (!_isFlipped)
              Text(
                "Count: ${widget.item.count}",
                style: TextStyle(fontSize: 16, color: Colors.black),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: Icon(Icons.remove), onPressed: _decrement),
                  Text(
                    "Count: ${widget.item.count}",
                    style: TextStyle(color: Colors.black),
                  ),
                  IconButton(icon: Icon(Icons.add), onPressed: _increment),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- CakeCard Widget (for Full Cakes with Size Restrictions) ----------------
class CakeCard extends StatefulWidget {
  final Cake cake;
  final Function(int, int, int, int, int) onCountsChanged;
  CakeCard({required this.cake, required this.onCountsChanged});
  @override
  _CakeCardState createState() => _CakeCardState();
}

class _CakeCardState extends State<CakeCard> {
  bool _isFlipped = false;
  final Map<String, List<String>> allowedSizes = {
    "Classic Birthday Cake": ["Mini", "Small", "Medium", "Large"],
    "Choc. Chip Cookie Dough": ["Mini", "Small", "Medium"],
    "Brownie": ["Mini", "Small", "Medium"],
    "Peanut Butter": ["Mini", "Small", "Medium"],
    "Cho. Mocha": ["Mini", "Small", "Medium"],
    "Pecan Caramel": ["Mini", "Small"],
    "Raspberry Ruffle": ["Mini", "Small"],
    "Celebration": ["Mini", "Small"],
    "Nutty Coconut": ["Mini", "Small"],
    "Yellow Drip Cone": ["Mini", "Small", "Medium", "Large"],
    "Balloon": ["Mini", "Small", "Medium", "Large", "1/4 Sheet"],
    "COTM": ["Mini", "Small", "Medium"],
  };
  int _getCount(String size) {
    switch (size) {
      case "Mini":
        return widget.cake.mini;
      case "Small":
        return widget.cake.small;
      case "Medium":
        return widget.cake.medium;
      case "Large":
        return widget.cake.large;
      case "1/4 Sheet":
        return widget.cake.quarterSheet;
      default:
        return 0;
    }
  }

  void _increment(String size) {
    setState(() {
      switch (size) {
        case "Mini":
          widget.cake.mini++;
          break;
        case "Small":
          widget.cake.small++;
          break;
        case "Medium":
          widget.cake.medium++;
          break;
        case "Large":
          widget.cake.large++;
          break;
        case "1/4 Sheet":
          widget.cake.quarterSheet++;
          break;
      }
      widget.onCountsChanged(
        widget.cake.mini,
        widget.cake.small,
        widget.cake.medium,
        widget.cake.large,
        widget.cake.quarterSheet,
      );
    });
  }

  void _decrement(String size) {
    setState(() {
      switch (size) {
        case "Mini":
          if (widget.cake.mini > 0) widget.cake.mini--;
          break;
        case "Small":
          if (widget.cake.small > 0) widget.cake.small--;
          break;
        case "Medium":
          if (widget.cake.medium > 0) widget.cake.medium--;
          break;
        case "Large":
          if (widget.cake.large > 0) widget.cake.large--;
          break;
        case "1/4 Sheet":
          if (widget.cake.quarterSheet > 0) widget.cake.quarterSheet--;
          break;
      }
      widget.onCountsChanged(
        widget.cake.mini,
        widget.cake.small,
        widget.cake.medium,
        widget.cake.large,
        widget.cake.quarterSheet,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> sizes =
        allowedSizes[widget.cake.name] ?? ["Mini", "Small", "Medium"];
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlipped = !_isFlipped;
        });
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(5),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                widget.cake.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(),
              if (!_isFlipped)
                Column(
                  children:
                      sizes
                          .map((size) => Text("$size: ${_getCount(size)}"))
                          .toList(),
                )
              else
                Column(
                  children:
                      sizes
                          .map(
                            (size) => _buildSizeRow(
                              size,
                              _getCount(size),
                              () => _decrement(size),
                              () => _increment(size),
                            ),
                          )
                          .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeRow(
    String label,
    int count,
    VoidCallback onRemove,
    VoidCallback onAdd,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: Icon(Icons.remove), onPressed: onRemove),
        Text("$label: $count"),
        IconButton(icon: Icon(Icons.add), onPressed: onAdd),
      ],
    );
  }
}
