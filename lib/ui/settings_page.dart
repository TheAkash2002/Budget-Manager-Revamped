import 'package:budget_manager_revamped/controller/settings_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/utils.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          scrollDirection: Axis.vertical,
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
            const SizedBox(height: 10),
            if (!kIsWeb) ...[
              const Text(
                'App Permissions',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...Permissions.values
                  .map((perm) => PermissionWidget(permission: perm)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: _.initializeReader,
                  child: Text("Start Notification Tracking"),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class PermissionWidget extends StatelessWidget {
  final Permissions permission;

  PermissionWidget({super.key, required this.permission});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      builder: (_) => Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  _.status[permission]!.icon(),
                  Text(permission.text()),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _.refreshPermission(permission),
                      child: Text("Refresh"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _.requestPermission(permission),
                      child: Text("Request"),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
