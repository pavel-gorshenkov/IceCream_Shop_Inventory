import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Ice Cream Flavors ----------------

  Future<void> saveFlavor(Flavor flavor) async {
    try {
      await _db.collection('flavors').doc(flavor.name).set(flavor.toMap());
      print('Flavor saved successfully!');
    } catch (e) {
      print('Error saving flavor: $e');
    }
  }

  Future<void> deleteFlavor(String flavorName) async {
    try {
      await _db.collection('flavors').doc(flavorName).delete();
      print('Flavor deleted successfully!');
    } catch (e) {
      print('Error deleting flavor: $e');
    }
  }

  Stream<List<Flavor>> streamFlavors() {
    return _db.collection('flavors').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Flavor.fromMap(doc.data())).toList();
    });
  }

  // ---------------- Ice Cream Cakes ----------------

  Future<void> saveCake(Cake cake) async {
    try {
      await _db.collection('ice_cream_cakes').doc(cake.name).set(cake.toMap());
      print('Cake saved successfully!');
    } catch (e) {
      print('Error saving cake: $e');
    }
  }

  Future<void> removeCake(Cake cake) async {
    try {
      await _db.collection('ice_cream_cakes').doc(cake.name).delete();
      print('Cake removed successfully!');
    } catch (e) {
      print('Error removing cake: $e');
    }
  }

  Stream<List<Cake>> streamCakes() {
    return _db.collection('ice_cream_cakes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Cake.fromMap(doc.data())).toList();
    });
  }

  // ---------------- Pies ----------------

  Future<void> savePie(CakeSimple pie) async {
    try {
      await _db.collection('pies').doc(pie.name).set(pie.toMap());
      print('Pie saved successfully!');
    } catch (e) {
      print('Error saving pie: $e');
    }
  }

  Future<void> removePie(CakeSimple pie) async {
    try {
      await _db.collection('pies').doc(pie.name).delete();
      print('Pie removed successfully!');
    } catch (e) {
      print('Error removing pie: $e');
    }
  }

  Stream<List<CakeSimple>> streamPies() {
    return _db.collection('pies').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CakeSimple.fromMap(doc.data()))
          .toList();
    });
  }
  // ---------------- Cake Slices ----------------

  Future<void> saveCakeSlice(CakeSimple slice) async {
    try {
      await _db.collection('cake_slices').doc(slice.name).set(slice.toMap());
      print('Cake slice saved successfully!');
    } catch (e) {
      print('Error saving cake slice: $e');
    }
  }

  Future<void> removeCakeSlice(CakeSimple slice) async {
    try {
      await _db.collection('cake_slices').doc(slice.name).delete();
      print('Cake slice removed successfully!');
    } catch (e) {
      print('Error removing cake slice: $e');
    }
  }

  Stream<List<CakeSimple>> streamCakeSlices() {
    return _db.collection('cake_slices').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CakeSimple.fromMap(doc.data()))
          .toList();
    });
  }
}
