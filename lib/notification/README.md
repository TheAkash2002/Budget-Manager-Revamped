# Notifications

Notifications are interacted with in two ways:

- Reading notifications from a hardcoded list of packages, and adding expenses from them in the
  background
- Showing a notification when an expense is added in the background

## Reading Notifications

1. SplashController Requests for SMS permission and "Show Notifications" permission locally using
   permission_handler.
2. SplashController calls hasNotifReadingPermission i.e. "checkNotifReadingPermission" method call
   is made on platform through mainMethodChannel.
3. A "princeAkash/main" MethodChannel is created and a function "initializeService" is called which
   takes a rawHandle as input.
4. Android MainActivity has set up a handler for "princeAkash/main", where
    - "initializeService": If notifReadingPermissionGranted() returns true, it calls internal
      initializeService() which starts NotificationListener service
    - "checkNotifReadingPermission": Returns with a boolean stating whether the app is allowed to
      listen to notifications or not.
    - "requestNotifReadingPermission": Opens the Settings screen to allow the app to listen to
      notifications.
5. On receiving a Notification, NotificationListener.onNotificationPosted is fired. This sends out
   an intent aimed at NotificationBroadcastListener.
6. On receiving an SMS, NotificationBroadcastReceiver gets fired due to AndroidManifest
   configuration.
7. NotificationBroadcastReceiver sends the received intent (from NotificationListener or
   SMS-generated) to NotificationPropagationService, which is a Job processor.
8. NotificationPropagationService calls startPropagationService, which sets up a FlutterEngine and
   stores it in static variable.
9. FlutterEngine setup involves finding a setupBackgroundChannelForDbEntry callback, executing it,
   receiving a "initialized" MethodCall from it, dequeing all queued payloads, and marking
   sBackgroundEngineInitiated as true.
10. NotificationPropagationService.onHandleWork is called when the works fired by
    NotificationBroadcastReceiver can be dequeued.
11. If any work is executed i.e. onHandleWork is called before sBackgroundEngineInitiated is set to
    true, the payload is queued, because Dart hasn't responded with the "
    NotificationPropagationService.initialized" event hence we cannot immediately execute the Dart
    DbEntryHandler. Otherwise, the Dart code is immediately executed.

## Showing Notifications

1. Permission for showing notifications is requested in SplashController()
2. SplashController() calls initializeNotificationSenderService().
3. A handler for the background channel is written, for the callback to be executed when a
   notification is captured and relayed by NotificationPropagationService. The callback prepares
   firebase for expense creation / deletion.
4. Whenever a useful notification is captured, a new notification is generated with details of the
   captured expense as well as a button to delete it.