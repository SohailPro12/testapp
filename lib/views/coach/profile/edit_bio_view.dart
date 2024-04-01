// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:testapp/services/crud2/firestore.dart';

final FireStoreService _fireStoreService = FireStoreService();

class EditBioScreen extends StatefulWidget {
  final String initialBio;

  const EditBioScreen({super.key, required this.initialBio});

  @override
  _EditBioScreenState createState() => _EditBioScreenState();
}

class _EditBioScreenState extends State<EditBioScreen> {
  late TextEditingController _bioController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bio'),
        actions: [
          IconButton(
            onPressed: _saveBio,
            icon: _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextFormField(
                controller: _bioController,
                maxLines: null,
                maxLength: 300, // Adjusted to character limit
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Enter your bio (300 characters max)',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _saveBio,
              child: Text(
                _isLoading ? 'Saving...' : 'Save Bio',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Suggestions for a good bio for fitness coaches:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '- Certified fitness coach with 5+ years of experience helping clients achieve their health goals.',
            ),
            const Text(
              '- Passionate about promoting a balanced lifestyle through customized workout plans and nutrition guidance.',
            ),
            const Text(
              '- Specialized in HIIT, strength training, and functional fitness to improve overall health and athletic performance.',
            ),
            const Text(
              '- Committed to ongoing education and staying up-to-date with the latest trends in the fitness industry.',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBio() async {
    setState(() {
      _isLoading = true;
    });
    final username = await _fireStoreService.getUserField('username');
    try {
      await _fireStoreService.updateUserField(
          username, 'Bio', _bioController.text);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bio updated successfully')));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update bio: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }
}
