# KittyParty 🎉

[![Flutter](https://img.shields.io/badge/Flutter-3.24-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5-blue?logo=dart)](https://dart.dev)

A social live streaming platform where users can host, join, and interact in real-time audio rooms. Inspired by platforms like MoliParty, KittyParty focuses on community, entertainment, and interactive livestream engagement.

Features ✨
🎙 Live Audio Rooms

Host or join real-time audio spaces powered by ZEGOCLOUD.

Multi-user seats with profile avatars and mic control.

💬 Real-Time Interaction

Smooth user join/leave animations.

Room name editing for hosts.

Live event updates through sockets.

🎁 Virtual Gifts System (New & Improved!)

Choose from a wide collection of PNG & SVGA animated gifts.

Auto-detect asset paths using baseName → .png and .svga.

Full logging for easier debugging:

[GIFT PNG] and [GIFT SVGA] logs for asset resolution.

Gift sending UI:

Gift categories (General / Lucky)

Quantity combos: x1 x5 x10 x20 x50

User selector modal to choose who receives the gift.

SVGA animations queue and play globally.

💎 Wallet, Coins & Diamonds

Recharge coins.

Convert coins → diamonds.

Diamond balance updates via real-time sockets.

👥 Social Features

Follow system.

Post feed with images & media.

Profile picture caching for efficiency.

🌐 Cross-Platform

Built fully with Flutter, supports:

Android

iOS

Getting Started 🚀
Prerequisites

Flutter SDK ≥ 3.24

Dart ≥ 3.5

Android Studio or Xcode

Node-based backend API (KittyParty API)

Project Structure
lib/
├── core/                     # Global utilities, constants, sockets
├── features/
│   ├── livestream/           # Audio rooms, gifts, SVGAs, seat system
│   ├── wallet/               # Recharge & diamond handling
│   ├── landing/              # Feed, posts, home
│   └── auth/                 # Login, registration
├── viewmodel/                # Provider-based MVVM
└── widgets/                  # Reusable UI elements

Installation
git clone https://github.com/ArthanKyle/kittyparty.git
cd kittyparty
flutter pub get
flutter run

Gift System Documentation 🎁
Folder Structure
assets/image/gift/
Example.png
Example.svga

Naming Rules

Each gift must have matching names:

Red Rose Bookstore.png  
Red Rose Bookstore.svga

Auto Path Detection

GiftAssets automatically resolves file paths:

String get png => "assets/image/gift/$baseName.png";
String get svga => "assets/image/gift/$baseName.svga";

Logging

Every lookup prints:

[GIFT PNG] Request: 'Donut' → assets/image/gift/Donut.png  
[GIFT SVGA] Request: 'Donut' → assets/image/gift/Donut.svga


These logs help verify naming mismatches instantly.

Roadmap 🛠
Core System Enhancements

Realtime diamond deduction + income routes

Room-level ranking effects

Animated gift barrage system

Admin monitoring tools

Performance Improvements

Reduce rebuilds inside gift modal & selector

Asset preloading for SVGA animations

Lazy load post feeds

Future Features

Global leaderboards

In-app rewards shop

Badge and medal system

Daily missions & achievements

Gamification of rooms

Resources 📚

Flutter Documentation

SVGA Animation Format

ZEGOCLOUD Live Audio Room

License 📄

This project is licensed under the MIT License.

Happy streaming with KittyParty! 🎉