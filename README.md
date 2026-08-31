# CONNECT — Flutter App

CONNECT is a Flutter-based help-discovery prototype designed to turn a user’s problem into a guided path toward the right resource, service, or organization.

## What this app does

- Helps a user describe a real-world problem in plain language
- Understands the likely problem type, urgency, and missing information
- Produces a structured solution plan
- Highlights the best, cheapest, and most reliable next steps
- Tracks recent requests and profile preferences

## Core flow

1. User tells CONNECT what is happening
2. AI identifies the likely need, urgency, and location context
3. CONNECT asks for missing details when needed
4. The app surfaces solution options and next actions
5. The user can revisit past requests and saved preferences

## Run locally

```bash
flutter pub get
flutter run
```

## Recommended next steps

- Connect the app to a real backend or AI service
- Add Supabase authentication and history persistence
- Add location-aware resource results and phone/route actions
- Expand the problem classification model for more categories

## App concept

The product is intentionally built as a problem-to-solution engine rather than a generic chatbot. Instead of asking users to search multiple apps manually, CONNECT tries to understand the issue and route them to the best available path to help.
