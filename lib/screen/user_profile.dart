// ignore_for_file: use_build_context_synchronously, avoid_print
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parking_app/screen/login_screen.dart';
import 'package:parking_app/widgets/button.dart';
import 'package:parking_app/widgets/snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _loading = true;
  Map<String, dynamic>? _userData;
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // ---------- Firebase ----------
  Future<void> _fetchUserData() async {
    if (_user == null) return;
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('userData')
              .doc(_user.uid)
              .get();

      if (snap.exists) {
        _userData = snap.data();
        if (_userData?['photoBase64'] != null) {
          _avatarBytes = base64Decode(_userData!['photoBase64']);
        }
      }
    } catch (e) {
      showSnackBar(context, 'Error fetching user data: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _updateAvatar(Uint8List bytes) async {
    if (_user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('userData')
          .doc(_user.uid)
          .set({'photoBase64': base64Encode(bytes)}, SetOptions(merge: true));
      setState(() => _avatarBytes = bytes);
      showSnackBar(context, 'Profile image updated');
    } catch (e) {
      showSnackBar(context, 'Failed to update image: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;
    final bytes = await img.readAsBytes();
    if (!mounted) return;
    await _updateAvatar(bytes);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userData == null) {
      return const Scaffold(body: Center(child: Text('No user data found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickFromGallery,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue[100],
                backgroundImage:
                    _avatarBytes != null
                        ? MemoryImage(_avatarBytes!)
                        : const NetworkImage(
                              'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                            )
                            as ImageProvider,
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.black,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _userData?['name'] ?? 'Unnamed',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: CustomButton(label: 'Sign Out', onPressed: _signOut),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
