import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/settings.dart';
import '../../models/models.dart';
import '../../utils/notification.dart';
import '../../utils/theme.dart';

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
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount:
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? 5
                      : 10,
              shrinkWrap: true,
              children: themeBaseColors
                  .map((color) => InkWell(
                        onTap: () => changeTheme(color),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            constraints: const BoxConstraints.expand(),
                            color: color,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            if (isNotifReadingSupported()) ...[
              const Text(
                'App Permissions',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...AppPermissions.values
                  .map((perm) => PermissionWidget(permission: perm)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: _.initializeReader,
                  child: const Text('Start Notification Tracking'),
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
  final AppPermissions permission;

  const PermissionWidget({super.key, required this.permission});

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
                  Expanded(child: Text(permission.text())),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _.refreshPermission(permission),
                      child: const Text('Refresh'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _.requestPermission(permission),
                      child: const Text('Request'),
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
