import 'package:flutter/material.dart';

import '../utils/utils.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text(
            'App Color',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: themeBaseColors
                .map((color) => InkWell(
                      onTap: () => changeTheme(color),
                      child: Container(
                        color: color,
                        height: 70,
                        width: 70,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
