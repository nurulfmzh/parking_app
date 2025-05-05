import 'package:flutter/material.dart';
import 'package:parking_app/screen/level_booking.dart';

class ParkingLotInfoPage extends StatefulWidget {
  final String mallName;
  const ParkingLotInfoPage({super.key, required this.mallName});

  @override
  State<ParkingLotInfoPage> createState() => _ParkingLotInfoPageState();
}

class _ParkingLotInfoPageState extends State<ParkingLotInfoPage> {
  // This page belongs to the Parking tab, so we start at index 1
  static const int _myTabIndex = 1;

  void _onNavTap(int idx) {
    if (idx == _myTabIndex) return; // already here
    // Pop back to previous screen and return the tab index we want
    Navigator.pop(context, idx);
  }

  @override
  Widget build(BuildContext context) {
    // ---------- mock data (level → zone → available) ----------
    final Map<String, Map<String, int>> _levels = {
      'L1': {'Zone A': 42, 'Zone B': 18},
      'L2': {'Zone A': 28, 'Zone B': 32},
      'B1': {'Zone A': 15},
    };

    // compute totals
    int _totalForZone(String zone) =>
        _levels.values.map((z) => z[zone] ?? 0).fold(0, (a, b) => a + b);

    final int _zoneATotal = _totalForZone('Zone A');
    final int _zoneBTotal = _totalForZone('Zone B');
    final int _grandTotal = _zoneATotal + _zoneBTotal;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mallName),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ---------------- body ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/berjayap.jpg'),
            const SizedBox(height: 12),

            // description header
            Text(
              '${widget.mallName} – RM3 first hour',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Available bays  •  Zone A: $_zoneATotal  •  '
              'Zone B: $_zoneBTotal  •  Total: $_grandTotal',
              style: const TextStyle(fontSize: 14),
            ),
            const Divider(height: 24),

            // list levels → zones
            ..._levels.entries.map((levelEntry) {
              final level = levelEntry.key;
              final zones = levelEntry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text('Level $level'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        zones.entries
                            .map(
                              (e) => Text('• ${e.key}: ${e.value} available'),
                            )
                            .toList(),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => LevelBookingPage(
                                mallName: widget.mallName,
                                level: level,
                                zones: zones,
                              ),
                        ),
                      ),
                ),
              );
            }),
          ],
        ),
      ),

      // -------------- bottom nav --------------
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _myTabIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_parking),
            label: 'Parking',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
