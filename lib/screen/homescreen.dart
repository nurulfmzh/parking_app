import 'package:flutter/material.dart';
import 'package:parking_app/screen/dashboard.dart';
import 'package:parking_app/screen/parking_lot.dart';
import 'package:parking_app/screen/user_profile.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 1}); // default = Parking

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageStorageBucket _bucket = PageStorageBucket();
  late int _selectedIndex;

  // pages for each tab
  late final List<Widget> _pages = [
    const HomeDashboard(),
    _ParkingTab(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTap(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: _bucket, child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
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

////////////////////  Tab‑1  ////////////////////
class _ParkingTab extends StatefulWidget {
  @override
  State<_ParkingTab> createState() => _ParkingTabState();
}

class _ParkingTabState extends State<_ParkingTab> {
  final Map<String, List<String>> _mallMap = {
    'Off-street (Mall)': [
      'iOi City Mall',
      '1 Mont Kiara',
      'Berjaya Mall',
      'East Coast Mall',
    ],
  };

  final List<String> _categories = ['Off-street (Mall)', 'On-street'];
  String _selectedCategory = 'Off-street (Mall)';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered =
        _mallMap[_selectedCategory]!
            .where((m) => m.toLowerCase().contains(_search))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkSini'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: const Color(0xFFFDF6FF),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // search bar
            _SearchField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
            const SizedBox(height: 10),

            // category dropdown
            _CategoryDropdown(
              categories: _categories,
              value: _selectedCategory,
              onChanged:
                  (v) => setState(() {
                    _selectedCategory = v!;
                    _search = '';
                  }),
            ),
            const SizedBox(height: 10),

            // mall list
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder:
                    (_, i) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(filtered[i]),
                        tileColor: Colors.grey.shade300,
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ParkingLotInfoPage(
                                      mallName: filtered[i],
                                    ),
                              ),
                            ),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////  Widgets  ////////////////////
class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
    ),
    child: TextField(
      decoration: const InputDecoration(
        icon: Icon(Icons.search),
        hintText: 'Search',
        border: InputBorder.none,
      ),
      onChanged: onChanged,
    ),
  );
}

class _CategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final String value;
  final ValueChanged<String?> onChanged;
  const _CategoryDropdown({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        items:
            categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}
