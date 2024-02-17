import 'package:flutter/material.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/auth/auth_service.dart';

class CoachaAdditionalInfo extends StatefulWidget {
  final String fullName;

  const CoachaAdditionalInfo({super.key, required this.fullName});

  @override
  State<CoachaAdditionalInfo> createState() => _CoachaAdditionalInfoState();
}

class _CoachaAdditionalInfoState extends State<CoachaAdditionalInfo> {
  // ignore: unused_field
  String _experience = '';
  String? _selectedDomain;
  String? _selectedAvailability;

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final String fullName = args['fullName'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Additional Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hi Coach  $fullName',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  _experience = value;
                });
              },
              decoration:
                  const InputDecoration(labelText: 'Years of Experience'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedDomain,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDomain = newValue;
                });
              },
              items: ['Football', 'Basketball', 'Tennis', 'Swimming']
                  .map<DropdownMenuItem<String>>((String domain) {
                return DropdownMenuItem<String>(
                  value: domain,
                  child: Text(domain),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Domaine (Sport)'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedAvailability,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAvailability = newValue;
                });
              },
              items: ['Full Time', 'Part Time', 'Flexible']
                  .map<DropdownMenuItem<String>>((String availability) {
                return DropdownMenuItem<String>(
                  value: availability,
                  child: Text(availability),
                );
              }).toList(),
              decoration: const InputDecoration(
                  labelText: 'Disponibilité (Availability)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AuthService.firebase().sendEmailVerfication();
                Navigator.of(context).pushNamed(verifyemailRoute);
              },
              child: const Text('Let\'s go!'),
            ),
          ],
        ),
      ),
    );
  }
}
