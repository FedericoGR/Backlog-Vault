import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Sin cuenta obligatoria'),
            subtitle: Text('Backlog Vault funciona localmente en este equipo.'),
          ),
          ListTile(
            leading: Icon(Icons.wifi_off_outlined),
            title: Text('Offline-first'),
            subtitle: Text('Este entregable no usa internet ni metadata externa.'),
          ),
          ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('Base local'),
            subtitle: Text('Los datos se guardan en SQLite mediante Drift.'),
          ),
        ],
      ),
    );
  }
}
