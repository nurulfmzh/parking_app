import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String selectedLevel = 'Level 3A';
  final List<String> levels = ['Level 3A', 'Level 3B', 'Rooftop R'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0DEFF),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Book Parking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Select Your Preferred Parking Level",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Smart level selector
            Column(
              children:
                  levels.map((level) {
                    bool isSelected = level == selectedLevel;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLevel = level;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.deepPurple),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              level,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 30),
            const Text(
              "The listed levels are only available upon booking through this application. Other levels are general parking.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),

            const Spacer(),

            // Book Button
            ElevatedButton(
              onPressed: () {
                // Navigate to confirmation page or show modal
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text("Booking Confirmed"),
                        content: Text(
                          "Your slot at $selectedLevel has been reserved.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Book", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
