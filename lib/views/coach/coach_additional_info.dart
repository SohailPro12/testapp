import 'package:flutter/material.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/services/crud2/firestore.dart';

class CoachaAdditionalInfo extends StatefulWidget {
  final String fullName;

  const CoachaAdditionalInfo({super.key, required this.fullName});

  @override
  State<CoachaAdditionalInfo> createState() => _CoachaAdditionalInfoState();
}

class _CoachaAdditionalInfoState extends State<CoachaAdditionalInfo> {
  String _experience = '';
  String _selectedDomain = 'Yoga';
  String _selectedAvailability = 'Full Time';
  String _website = ''; // Added website field
  String _bio = ''; // Added bio field
  final FireStoreService myDB = FireStoreService();

  int getAlphabetCount(String text) {
    if (text.isEmpty) {
      return 0;
    } else {
      return text.replaceAll(RegExp(r'[^a-zA-Z]'), '').length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String username = arguments['username'];
    final String fullName = arguments['fullName'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Additional Information'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hi Coach  $fullName',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    _selectedDomain = newValue!;
                  });
                },
                items: [
                  'Calisthenics',
                  'Body Building',
                  'CrossFit',
                  'Weightlifting',
                  'Powerlifting',
                  'Yoga',
                  'Pilates',
                  'Aerobics',
                  'Zumba',
                  'Cycling',
                  'Running',
                  'Hiking',
                  'Boxing',
                  'Martial Arts',
                  'Kickboxing',
                  'Gymnastics',
                  'Parkour',
                  'Rock Climbing',
                  'Surfing',
                  'Skateboarding',
                ].map<DropdownMenuItem<String>>((String domain) {
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
                    _selectedAvailability = newValue!;
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
              TextField(
                onChanged: (value) {
                  setState(() {
                    _website = value;
                  });
                },
                decoration:
                    const InputDecoration(labelText: 'Website (Optional)'),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _bio = value.trim(); // Trim excess whitespace
                  });
                },
                maxLength: 300, // Limit maximum characters
                maxLines: null, // Allow multiline input
                decoration: const InputDecoration(
                  labelText: 'Bio or Description (Optional)',
                  counterText: '', // Hide character counter
                ),
              ),
              Text(
                '${getAlphabetCount(_bio)}/300',
                style: TextStyle(
                  color:
                      getAlphabetCount(_bio) > 300 ? Colors.red : Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await myDB.coachAdditionalInfoUser(
                    username,
                    "$_experience years",
                    _selectedDomain,
                    _selectedAvailability,
                    _website, // Pass website parameter
                    _bio, // Pass bio parameter
                  );
                  AuthService.firebase().sendEmailVerfication();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamed(verifyemailRoute);
                },
                child: const Text('Let\'s go!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
