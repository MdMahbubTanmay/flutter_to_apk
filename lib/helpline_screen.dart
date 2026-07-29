import 'package:flutter/material.dart';

class HelplineScreen extends StatelessWidget {
  const HelplineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Helplines')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          HelplineCard(title: 'National Emergency Service', number: '999', subtitle: 'Police, Fire, Ambulance'),
          HelplineCard(title: 'National Legal Aid Services', number: '16430', subtitle: 'Free Government Legal Assistance'),
          HelplineCard(title: 'Cyber Crime Helpline', number: '01769691509', subtitle: 'Police Cyber Support for Women'),
          HelplineCard(title: 'App Admin Emergency Support', number: '+880 1700-000000', subtitle: 'Direct Support Desk'),
        ],
      ),
    );
  }
}

class HelplineCard extends StatelessWidget {
  final String title;
  final String number;
  final String subtitle;

  const HelplineCard({super.key, required this.title, required this.number, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.phone, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(
          number,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
        ),
      ),
    );
  }
}
