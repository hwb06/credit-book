# Credit Book

A simple web app for shopkeepers to record customers, credit given and payments received. It shows each customer's balance, an overdue list, and a one-tap WhatsApp reminder.

Built with **Flutter Web**, **Firebase** and the **BLoC** pattern.

## Features

- Shopkeeper login (Firebase Authentication)
- Customers: add, edit, delete, search by name or phone
- Add credit and payment entries (with note and date)
- Automatic balance per customer (credit minus payments)
- Overdue list (no payment for 7+ days)
- WhatsApp reminder link with a pre-filled message
- Daily summary: given today, received today, total outstanding
- Responsive design for mobile and desktop
- Firestore security rules (each shopkeeper sees only their own data)

## Tech Stack

| Technology | Use |
|---|---|
| Flutter (Web) | UI |
| Firebase Auth | Login |
| Cloud Firestore | Database |
| flutter_bloc, equatable | State management |
| url_launcher | WhatsApp link |
| intl | Date and currency formatting |

## Business Logic

- **Balance** = total credit - total payments
- **Overdue** = balance > 0 and no payment for 7+ days (or 7+ days since first credit if never paid). Change `overdueDays` in `lib/core/constants/strings.dart`.
- **WhatsApp**: `03001234567` becomes `https://wa.me/923001234567?text=...`

## Build and Deploy

```bash
flutter build web
firebase init hosting
firebase deploy
```

## Author
[Hussnain Waheed](https://github.com/hwb06)