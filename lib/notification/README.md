# Notifications

Notifications are interacted with in two ways:

- Reading notifications from a hardcoded list of packages, and adding expenses from them in the
  background
- Showing a notification when an expense is added in the background

## Reading Notifications

1. main() calls initializeNotificationService()
2. Request for SMS permission and "Show Notifications" permission
3. A "princeAkash/main" MethodChannel is created and a function "initializeService" is called which
   takes a rawHandle as input.
4. Android MainActivity has set up a handler for "princeAkash/main", where
    - "initializeService" checks if Notification Reading permission is granted.
    - If not granted, permission is requested
    - if granted, initializeService() is called which starts NotificationListener service.
5. On receiving a Notification, NotificationListener.onNotificationPosted is fired. This sends out
   an intent aimed at NotificationBroadcastListener.
6. On receiving an SMS, NotificationBroadcastReceiver gets fired due to AndroidManifest
   configuration.
7. NotificationBroadcastReceiver sends the received intent (from NotificationListener or
   SMS-generated) to NotificationPropagationService, which is a Job processor.
8. NotificationPropagationService calls startPropagationService, which sets up a FlutterEngine and
   stores it in static variable.
9. FlutterEngine setup involves finding a setupBackgroundChannelForDbEntry callback, executing it,
   receiving a "NotificationPropagationService.initialized" MethodCall from it, dequeing all queued
   payloads, and marking
   sBackgroundEngineInitiated as true.
10. NotificationPropagationService.onHandleWork is called when the works fired by
    NotificationBroadcastReceiver can be dequeued.
11. If any work is executed i.e. onHandleWork is called before sBackgroundEngineInitiated is set to
    true, the payload is queued, because Dart hasn't responded with the "
    NotificationPropagationService.initialized" event hence we cannot immediately execute the Dart
    DbEntryHandler. Otherwise, the Dart code is immediately executed.

## Showing Notifications

TBD