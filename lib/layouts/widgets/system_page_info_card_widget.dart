  import 'package:flutter/material.dart';

Card systemInfoCard(BuildContext context,
      {required String title,
      required String image,
      required List<Widget> children}) {
    return Card(
      //  color: Theme.of(context).colorScheme.secondary.withAlpha(50),
      child: ListTile(
        leading: Image.asset(
          image,
          height: 40,
          fit: BoxFit.contain,
        ),
        title: sectionTitle(title),
        subtitle: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runAlignment: WrapAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value?.toString() ?? '—'),
        ],
      ),
    );
  }

  Widget optionalNote(String? note) {
    if (note == null || note.trim().isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('📌 ${note.trim()}'),
      ),
    );
  }
