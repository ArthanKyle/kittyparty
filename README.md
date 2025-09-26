# KittyParty 🎉

[![Flutter](https://img.shields.io/badge/Flutter-3.24-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5-blue?logo=dart)](https://dart.dev)

A **social live streaming platform** where users can join live rooms, interact in real time, and connect through engaging content. Inspired by platforms like **MoliParty**, KittyParty brings people together through fun, interactive, and community-driven experiences.

---

## Features ✨

- 🎙 **Live Audio & Video Rooms** – Host or join real-time conversations.
- 💬 **Interactive Chat** – Connect instantly with streamers and the audience.
- 🎁 **Virtual Gifts** – Send fun gifts to show support during streams.
- 💎 **Coins & Diamonds** – Recharge coins, convert to diamonds, and unlock premium features.
- 👥 **Community Building** – Follow, connect, and grow your network.
- 🌐 **Global Reach** – Discover streams from around the world.

---

## Getting Started 🚀

This project is built with **Flutter**, enabling cross-platform support for **Android** and **iOS**.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.24 or later)
- [Dart](https://dart.dev/get-dart) (v3.5 or later)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) for emulators or physical devices

### Project Structure

```plaintext
lib/
├── core/       # Constants, utilities, and shared widgets
├── features/   # Modules for live streaming, wallet, chat, etc.
├── viewmodel/  # State management (MVVM + Provider)
└── widgets/    # Reusable UI components
```

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/ArthanKyle/kittyparty.git
   cd kittyparty
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

---

## Roadmap 🛠

### Core Features
- Authentication & registration flow
- Wallet system with coin recharge
- Coin-to-diamond conversion
- Stripe integration for payments
- Live streaming & real-time chat

### Improvements in Progress
- Multi-host live audio/video rooms
- Auto-dismiss dialogs for seamless payments
- Proper `.env` and secrets handling in Git/GitHub
- Backend deployment optimizations (Railway/Cloud)
- Error handling for R8/Gradle build issues

### Upcoming Features
- Leaderboards & reward system
- Stream moderation tools (mute, ban, reporting)
- In-app purchases for gifts & premium content
- UI/UX polish (animations, gradient backgrounds, custom dialogs)

---

## Resources 📖

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language](https://dart.dev/)

---

## Contributing 🤝

Contributions are welcome! To get started:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Make your changes and commit (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

Please ensure your code follows the project's coding standards and includes relevant tests.

---

## License 📄

This project is licensed under the [MIT License](LICENSE).

---

Happy streaming with KittyParty! 🎉