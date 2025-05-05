import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/auth/booking.dart';
import 'package:parking_app/screen/dashboard.dart';
import 'package:uuid/uuid.dart';

class LevelBookingPage extends StatefulWidget {
  final String mallName;
  final String level;
  final Map<String, int> zones;
  const LevelBookingPage({
    super.key,
    required this.mallName,
    required this.level,
    required this.zones,
  });

  @override
  State<LevelBookingPage> createState() => _LevelBookingPageState();
}

class _LevelBookingPageState extends State<LevelBookingPage> {
  static const int _myTabIndex = 1; // Parking tab

  void _onNavTap(int idx) {
    if (idx == _myTabIndex) return;
    Navigator.pop(context, idx); // pop back to root with tab index
  }

  Future<void> _bookParkingSlot(String zone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please log in to book a slot')));
      return;
    }

    final now = DateTime.now();
    final booking = Booking(
      slotId: '${widget.mallName} - ${widget.level} - Zone $zone',
      startTime: now,
      endTime: now.add(Duration(hours: 1)), // example duration
      createdAt: now,
    );

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'slotId': booking.slotId,
        'userId': user.uid,
        'startTime': booking.startTime.toIso8601String(),
        'endTime': booking.endTime.toIso8601String(),
        'createdAt': booking.createdAt.toIso8601String(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Booking confirmed for $zone')));

      // Go to dashboard or home after successful booking
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeDashboard()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Parking'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        automaticallyImplyLeading: true, // keep a back arrow to previous page
      ),

      // -------------- body --------------
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // mall + level line
            Text(
              '${widget.mallName}  •  Level ${widget.level}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              'Select a zone to book',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            ...widget.zones.entries.map(
              (e) => Card(
                child: ListTile(
                  title: Text('${e.key}  -  ${e.value} bays available'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _bookParkingSlot(e.key),
                ),
              ),
            ),
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
