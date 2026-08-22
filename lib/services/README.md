# Services layer

Cross-cutting service **contracts** belong here (analytics, push notifications,
location, AI client, etc.).

- Do not put widgets in this folder.
- Register implementations in `lib/di/injection.dart` when a module is ready.
- Leave this folder empty of business code until a service is actually needed.
