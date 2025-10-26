import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // For RenderRepaintBoundary
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'firestore_service.dart';
import 'models.dart';

class InventorySpreadsheetScreen extends StatefulWidget {
  @override
  _InventorySpreadsheetScreenState createState() =>
      _InventorySpreadsheetScreenState();
}

class _InventorySpreadsheetScreenState
    extends State<InventorySpreadsheetScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Custom ordering for each season.
  final List<String> yearRoundOrder = [
    "Vanilla Bean",
    "Cookies & Cream",
    "Coffee Cookies",
    "Coffee Royale",
    "Chocolate",
    "Chocolate Blackout",
    "Chocolate Peanut Butter",
    "Mint Chocolate Chip",
    "Butter Pecan",
    "Coconut Joy",
    "Banana Peanut Butter Chunk",
    "Strawberry",
    "Ube",
    "Cookie Dough",
    "Pound Cake",
    "Dulce De Leche",
    "Rum Raisin",
    "Bubble Gum",
    "Cherry Ice",
    "Mango Sorbet",
  ];

  final List<String> springSummerOrder = [
    "Avocado",
    "Jackfruit",
    "Lychee",
    "Pineapple & Cream",
    "Pineapple & Coconut",
    "Blackberry",
    "Peach",
    "Soursop",
    "St. Cheesecake",
  ];

  final List<String> fallWinterOrder = [
    "Java Mocha Do'",
    "Choc. Cinn Brownie",
    "Chocolate Hazelnut",
    "Maple Walnut",
    "Blueberry Cheesecake",
    "Ginger Cookie",
    "Spicy Eggnog",
    "Peppermint Candy",
    "Red Velvet Cake",
  ];

  // Hardcoded flavor lists with example counts.
  List<Flavor> yearRoundFlavors = [
    Flavor(name: "Chocolate Blackout", king: 2, under: 1, holding: 0),
    Flavor(name: "Vanilla Bean", king: 2, under: 3, holding: 1),
    Flavor(name: "Mint Chocolate Chip", king: 1, under: 1, holding: 0),
    Flavor(name: "Cookies & Cream", king: 0, under: 2, holding: 1),
    Flavor(name: "Butter Pecan", king: 1, under: 2, holding: 0),
    Flavor(name: "Cookie Dough", king: 2, under: 1, holding: 1),
    Flavor(name: "Mango Sorbet", king: 0, under: 1, holding: 0),
    Flavor(name: "Chocolate", king: 3, under: 2, holding: 1),
    Flavor(name: "Coffee Cookies", king: 1, under: 1, holding: 0),
    Flavor(name: "Coffee Royale", king: 2, under: 1, holding: 1),
    Flavor(name: "Chocolate Peanut Butter", king: 3, under: 0, holding: 2),
    Flavor(name: "Coconut Joy", king: 1, under: 2, holding: 1),
    Flavor(name: "Banana Peanut Butter Chunk", king: 2, under: 2, holding: 0),
    Flavor(name: "Strawberry", king: 2, under: 2, holding: 1),
    Flavor(name: "Ube", king: 1, under: 1, holding: 1),
    Flavor(name: "Pound Cake", king: 1, under: 1, holding: 1),
    Flavor(name: "Dulce De Leche", king: 1, under: 1, holding: 1),
    Flavor(name: "Rum Raisin", king: 1, under: 1, holding: 1),
    Flavor(name: "Bubble Gum", king: 1, under: 1, holding: 1),
    Flavor(name: "Cherry Ice", king: 1, under: 1, holding: 1),
  ];

  List<Flavor> springSummerFlavors = [
    Flavor(name: "Avocado", king: 1, under: 1, holding: 0),
    Flavor(name: "Jackfruit", king: 0, under: 2, holding: 1),
    Flavor(name: "Lychee", king: 1, under: 1, holding: 0),
    Flavor(name: "Pineapple & Cream", king: 2, under: 1, holding: 1),
    Flavor(name: "Pineapple & Coconut", king: 1, under: 1, holding: 0),
    Flavor(name: "Blackberry", king: 0, under: 1, holding: 0),
    Flavor(name: "Peach", king: 1, under: 1, holding: 1),
    Flavor(name: "Soursop", king: 0, under: 1, holding: 0),
    Flavor(name: "St. Cheesecake", king: 1, under: 0, holding: 1),
  ];

  List<Flavor> fallWinterFlavors = [
    Flavor(name: "Java Mocha Do'", king: 2, under: 1, holding: 1),
    Flavor(name: "Choc. Cinn Brownie", king: 1, under: 2, holding: 0),
    Flavor(name: "Chocolate Hazelnut", king: 2, under: 2, holding: 1),
    Flavor(name: "Maple Walnut", king: 1, under: 1, holding: 0),
    Flavor(name: "Blueberry Cheesecake", king: 2, under: 1, holding: 1),
    Flavor(name: "Ginger Cookie", king: 0, under: 1, holding: 0),
    Flavor(name: "Spicy Eggnog", king: 1, under: 0, holding: 1),
    Flavor(name: "Peppermint Candy", king: 0, under: 1, holding: 1),
    Flavor(name: "Red Velvet Cake", king: 2, under: 2, holding: 0),
  ];

  List<Flavor> customCreations =
      []; // FIXME need to find a way to pull ice cream flavors from main.dart file

  // Set of flavor names to highlight in grapefruit pink.
  final Set<String> highlightFlavors = {
    "Vanilla Bean",
    "Cookies & Cream",
    "Coffee Cookies",
    "Chocolate",
    "Chocolate Peanut Butter",
    "Mint Chocolate Chip",
    "Butter Pecan",
    "Cookie Dough",
    "Pound Cake",
    "Cherry Ice",
    "Mango Sorbet",
    "Strawberry",
  };

  // Helper method to sort a list of Flavor according to a specific order.
  List<Flavor> sortFlavors(List<Flavor> flavors, List<String> order) {
    return order
        .map((name) {
          try {
            return flavors.firstWhere((flavor) => flavor.name == name);
          } catch (_) {
            return null;
          }
        })
        .whereType<Flavor>()
        .toList();
  }

  final GlobalKey _globalKey = GlobalKey();

  DateTime? _lastSyncTime;
  bool _syncSuccessful = false;

  @override
  void initState() {
    super.initState();
    _firestoreService.streamFlavors().listen((fetchedFlavors) {
      setState(() {
        _updateFlavorLists(fetchedFlavors, yearRoundFlavors);
        _updateFlavorLists(fetchedFlavors, springSummerFlavors);
        _updateFlavorLists(fetchedFlavors, fallWinterFlavors);
        customCreations =
            fetchedFlavors
                .where(
                  (flavor) =>
                      !yearRoundOrder.contains(flavor.name) &&
                      !springSummerOrder.contains(flavor.name) &&
                      !fallWinterOrder.contains(flavor.name),
                )
                .toList();

        _lastSyncTime = DateTime.now();
        _syncSuccessful = true;
      });
    });
  }

  void _updateFlavorLists(List<Flavor> fetchedFlavors, List<Flavor> list) {
    for (var fetched in fetchedFlavors) {
      int index = list.indexWhere((flavor) => flavor.name == fetched.name);
      if (index != -1) {
        list[index].updateCounts(fetched.king, fetched.under, fetched.holding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedYearRound = sortFlavors(yearRoundFlavors, yearRoundOrder);
    final sortedSpringSummer = sortFlavors(
      springSummerFlavors,
      springSummerOrder,
    );
    final sortedFallWinter = sortFlavors(fallWinterFlavors, fallWinterOrder);
    final sortedCustom =
        customCreations; // custom creations will reflect any flavor not in the orders

    // FIXME maybe^^

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ice Cream Inventory: 1041 Garfield Ave",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "Reload Counts",
            onPressed: () async {
              final fetchedFlavors =
                  await _firestoreService.streamFlavors().first;
              setState(() {
                _updateFlavorLists(fetchedFlavors, yearRoundFlavors);
                _updateFlavorLists(fetchedFlavors, springSummerFlavors);
                _updateFlavorLists(fetchedFlavors, fallWinterFlavors);
                customCreations =
                    fetchedFlavors
                        .where(
                          (flavor) =>
                              !yearRoundOrder.contains(flavor.name) &&
                              !springSummerOrder.contains(flavor.name) &&
                              !fallWinterOrder.contains(flavor.name),
                        )
                        .toList();
              });
            },
            color: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                "${_formattedDate()}   CH",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.save),
            tooltip: "Save as Image & Send to Discord",
            onPressed: _saveAsImage,
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSyncStatus(),
          Expanded(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: _globalKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Pillar: Year Round only.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSeasonLabel("Year Round Flavors"),
                            _buildTableSection(
                              sortedYearRound,
                              showHeader: true,
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, color: Colors.black),
                      // Right Pillar: Spring/Summer, Fall/Winter, Custom Creations.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSeasonLabel("Spring/Summer Flavors"),
                            _buildTableSection(
                              sortedSpringSummer,
                              showHeader: true,
                            ),
                            _buildSeasonLabel("Fall/Winter Flavors"),
                            _buildTableSection(
                              sortedFallWinter,
                              showHeader: true,
                            ),
                            _buildSeasonLabel("Custom Creations"),
                            _buildTableSection(sortedCustom, showHeader: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus() {
    String statusText;
    Color statusColor;
    if (_syncSuccessful) {
      statusText =
          "Data Sync Successful: Last sync at ${_formattedTime(_lastSyncTime)}";
      statusColor = Colors.green;
    } else {
      statusText = "Syncing data...";
      statusColor = Colors.red;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        statusText,
        style: TextStyle(fontSize: 14, color: statusColor),
      ),
    );
  }

  Widget _buildSeasonLabel(String label) {
    return Container(
      color: Colors.pink[200],
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTableSection(List<Flavor> flavors, {required bool showHeader}) {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: {
        0: FixedColumnWidth(100),
        1: FixedColumnWidth(35),
        2: FixedColumnWidth(35),
        3: FixedColumnWidth(35),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        if (showHeader)
          TableRow(
            decoration: BoxDecoration(color: Colors.pink[200]),
            children: [
              _buildHeaderCell("Flavor"),
              _buildHeaderCell("K"),
              _buildHeaderCell("U"),
              _buildHeaderCell("H"),
            ],
          ),
        ...flavors.map((flavor) {
          Color rowColor =
              highlightFlavors.contains(flavor.name)
                  ? Color(0xFFFFA07A)
                  : Colors.yellow[200]!;
          return TableRow(
            decoration: BoxDecoration(color: rowColor),
            children: [
              _buildEditableNameCell(flavor),
              _buildCountCell(flavor.king),
              _buildCountCell(flavor.under),
              _buildCountCell(flavor.holding),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEditableNameCell(Flavor flavor) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: TextFormField(
        initialValue: flavor.name,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        ),
        onFieldSubmitted: (val) {
          setState(() {
            flavor = Flavor(
              name: val,
              king: flavor.king,
              under: flavor.under,
              holding: flavor.holding,
            );
            _updateFlavor(flavor);
          });
        },
      ),
    );
  }

  Widget _buildCountCell(int count) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text(
        count.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Future<void> _updateFlavor(Flavor flavor) async {
    await _firestoreService.saveFlavor(flavor);
  }

  String _formattedDate() {
    final now = DateTime.now();
    return "${now.month}/${now.day}/${now.year}";
  }

  String _formattedTime(DateTime? time) {
    if (time == null) return "";
    return "${time.hour}:${time.minute}:${time.second}";
  }

  Future<void> _saveAsImage() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      await _sendImageToDiscord(pngBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image captured and sent to Discord!")),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error capturing image")));
    }
  }

  Future<void> _sendImageToDiscord(Uint8List imageBytes) async {
    final url =
        "https://discord.com/api/webhooks/1355396647768821881/eFAaraj5KzO6z_Mhx2zXKESTyQCfBJM_gMBRRt5-TZRtcWbSzRlfa5LRFxxQQhwS9-rb";
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['username'] = "captain hook";
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: "inventory.png",
        contentType: MediaType('image', 'png'),
      ),
    );
    var response = await request.send();
    print("Discord response: ${response.statusCode}");
  }
}
