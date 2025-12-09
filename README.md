# KittyParty 🎉

[![Flutter](https://img.shields.io/badge/Flutter-3.24-blue?logo=flutter)](https://flutter.dev)  
[![Dart](https://img.shields.io/badge/Dart-3.5-blue?logo=dart)](https://dart.dev)

A social live-streaming platform where users can host, join, and interact in real-time audio rooms. Inspired by platforms like MoliParty, KittyParty focuses on community, entertainment, and interactive livestream engagement.

---

## Features ✨

### 🎙 Live Audio Rooms
- Host or join real-time audio spaces powered by **ZEGOCLOUD**
- Multi-user seating with profile avatars and microphone control

### 💬 Real-Time Interaction
- Smooth join/leave animations
- Editable room names for hosts
- Live event updates through socket connections

### 🎁 Virtual Gifts System
- Wide library of **PNG** and **SVGA** animated gifts
- Auto-detect assets from `baseName → .png` / `.svga`
- Detailed logging via `[GIFT PNG]` and `[GIFT SVGA]`
- Gift-sending UI:
    - Categories: **General**, **Lucky**
    - Quantity presets: **x1, x5, x10, x20, x50**
    - User selector modal
- Global SVGA animation queue for smooth playback

### 💎 Wallet, Coins & Diamonds
- Recharge coins
- Convert coins → diamonds
- Diamond balance updates through sockets

### 👥 Social Features
- Follow system
- Post feed with photos and media
- Cached profile pictures for improved performance

### 🌐 Cross-Platform
Built with Flutter for:
- **Android**
- **iOS**

---

## Getting Started 🚀

### Prerequisites
- Flutter SDK **≥ 3.24**
- Dart **≥ 3.5**
- Android Studio or Xcode
- KittyParty Node-based backend API

### Installation
```bash
git clone https://github.com/ArthanKyle/kittyparty.git
cd kittyparty
flutter pub get
flutter run
