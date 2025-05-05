import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_app/screen/booking_history.dart';
import 'package:parking_app/screen/parking_home.dart';
import 'package:parking_app/screen/user_profile.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  String _formatTime(Timestamp ts) => DateFormat('hh:mm a').format(ts.toDate());

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user logged in')));
    }

    final userDoc = FirebaseFirestore.instance
        .collection('userData')
        .doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkSini'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        automaticallyImplyLeading: false, // ← no back arrow
      ),

      // -------- stream user info --------
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userDoc.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!.data() ?? {};
          final name =
              (data['name'] as String?) ?? (user.displayName ?? 'User');

          // Active parking sub‑doc (if any) e.g. userData/{uid}/activeParking/doc
          final active = data['activeParking'] as Map<String, dynamic>?;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $name !',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back to ParkSini. Ready to park?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // ---------- ACTIVE PARKING CARD ----------
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child:
                        active == null
                            ? const Text(
                              'You are not currently parked.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Currently parked at',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${active['mall']}  •  ${active['level']}  •  ${active['zone']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Since ${_formatTime(active['startTime'])}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: Navigate to stop‑parking / extend session
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                  ),
                                  icon: const Icon(Icons.stop),
                                  label: const Text('End Parking'),
                                ),
                              ],
                            ),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                // ---------- GRID BUTTONS ----------
                Expanded(
                  child: GridView(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 4 / 3,
                        ),
                    children: [
                      _ActionCard(
                        icon: Icons.local_parking,
                        label: 'Find Parking',
                        onTap: () {
                          // Navigator.push to parking tab (index 1)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParkingHome(),
                            ),
                          );
                        },
                      ),
                      _ActionCard(
                        icon: Icons.bookmark,
                        label: 'My Bookings',
                        onTap: () {
                          // TODO: push bookings page
                        },
                      ),
                      _ActionCard(
                        icon: Icons.history,
                        label: 'History',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingHistory(),
                            ),
                          );
                        },
                      ),
                      _ActionCard(
                        icon: Icons.account_circle,
                        label: 'Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------- reusable action card ----------
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.deepPurple.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
