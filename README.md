# Taco Trader 🌮

A private iOS trading dashboard for monitoring a Raspberry Pi crypto trading backend.

## Features
- Live dashboard: capital, free cash, open value, win rate, regime, streak
- Engine status: BTC / ETH / SOL / XRP / Coinbase (live vs dry, pid)
- Transaction feed
- Redeem history with cha-ching push notifications
- Pi system health (CPU temp, memory, disk, uptime)

## Tech
- Swift + SwiftUI
- MVVM + async/await
- Codable models with snake_case decoding
- Centralized APIClient with Bearer token auth
- UNUserNotificationCenter with custom `.caf` sound

## Setup
1. Open `TacoTrader.xcodeproj` in Xcode 15+
2. Go to **Settings** tab in the app and enter your Pi's base URL and auth token
3. For remote access: use Tailscale — no port forwarding needed
4. For push notifications: add your `.p8` APNs key to your Pi backend and bundle `cha-ching.caf` in the Xcode target

## Backend endpoints
```
GET /api/system
GET /api/report
GET /api/engines/status
GET /api/dashboard/summary
GET /api/transactions
GET /api/redeems
```
All endpoints require `Authorization: Bearer <token>`.

## Notification payload schema
```json
{
  "aps": {
    "alert": { "title": "Redeem: Weekend Fun", "body": "$250.00 redeemed" },
    "sound": "cha-ching.caf",
    "badge": 1
  },
  "event_type": "redeem_success",
  "amount": 250.00,
  "title": "Weekend Fun",
  "timestamp": "2025-09-14T18:32:00Z"
}
```
