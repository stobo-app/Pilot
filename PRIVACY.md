# Privacy Policy

## Overview

Pilot design is **privacy-first**. This document explains exactly what data is transmitted, stored, and processed when you use Pilot and Stobo Control to bring remote control features to your app.

## What Gets Transmitted Over the Network

Pilot transmits **only the following data** over your local network:

### 1. Spell Metadata (One-time, at connection)
When a Stobo Control connects to your app, Pilot shares a list of `SpellDescriptor` objects containing:
- **Spell ID** (UUID)
- **Name** (String) - Display name for the remote control
- **Description** (String) - Brief description of what the spell does
- **UI Text** (Strings) - Button labels for paused/playing states
- **SF Symbol Names** (Strings) - Icon identifiers for UI display

**What's NOT included:** Your spell closures, function implementations, or any business logic.

### 2. Spell Invocation Commands (Real-time)
When a spell is triggered from the remote control:
- **Spell ID** (UUID) - Identifier of which spell to execute
- **Spell Type** (Enum: `.play` or `.pause`) - Which action to trigger

**That's it.** No parameters, no data payloads, no function arguments.

### 3. Connection Management
Standard networking messages for:
- Connection establishment
- Disconnection requests
- Spell book refresh requests

## What NEVER Gets Transmitted

The following data **never leaves your device**:

✅ **Spell closures** - Your `play()` and `pause()` function implementations  
✅ **Business logic** - Any code inside your spell closures  
✅ **Application data** - Variables, state, user data captured by closures  
✅ **Function parameters** - Pilot spells don't use parameters by design  
✅ **App structure** - Your SwiftUI views, view models, or architecture  
✅ **User credentials** - Authentication tokens, passwords, or personal data  

## How Privacy is Enforced by Design

### Architecture Guarantees

1. **Spell Lookup Pattern**
   ```swift
   // Remote control sends only:
   Message.spell(spellId: UUID, type: .play)
   
   // Your app looks up and executes locally:
   SpellBook.shared.cast(spellId: spellId, type: type)
   ```
   The closure is stored locally and executed locally. The remote control only sends a trigger signal.

2. **No Codable Payloads**
   Unlike many RPC (Remote Procedure Call) systems, Pilot spells don't accept parameters:
   ```swift
   // Pilot spell signature
   let play: () -> Void
   let pause: (() -> Void)?
   ```
   To ensure no one is tempted to add this a future feature, Pilot architecture includes **no mechanism** to pass data from Stobo Control to your app.

3. **Local-Only Storage**
   ```swift
   // SpellBook stores spells in memory, never serialized
   private(set) var spells: [UUID: Spell] = [:]
   ```
   Your `Spell` implementations exist only in your app's memory space. Only `SpellDescriptors` are sent over the network.

## Network Architecture

### Local Network Only
- Pilot uses **Bonjour/mDNS** for device discovery
- Connections are established via **TCP over local Wi-Fi**
- No internet connectivity required
- No data leaves your local network

### Connection Flow
```
┌─────────────────┐         ┌──────────────────┐
│  Your App       │         │  Stobo Control   │
│  (Vision Pro)   │◄───────►│  (iPhone/iPad)   │
└─────────────────┘   WiFi  └──────────────────┘
                      Local
                      Network

Data transmitted:
• SpellDescriptor[] (metadata only, once)
• UUID + SpellType (triggers only, real-time)
```

### No Cloud Services
- Pilot does **not** use any cloud services
- No analytics or telemetry
- No data collection from Stobo or the Pilot SDK
- Completely offline-capable

## Data Storage

### On Your Controlled App (Vision Pro)
- **Spells:** Stored in memory for the lifetime of the app session
- **Connection state:** Temporary, cleared on disconnect
- **Device ID:** A random 3-digit number stored in `UserDefaults` for device identification on the network

### On Remote Control (Stobo Control App)
- **Discovered apps:** Temporary list of available apps on the network (name + device ID)
- **Spell metadata:** Cached during active connection, cleared on disconnect
- **No persistent storage** of your app's spells or data

## Security Considerations

### What Pilot Protects
✅ Your application logic and implementation details  
✅ User data and application state  
✅ Proprietary algorithms and business rules  

### What You Should Protect
⚠️ **Network Security:** Pilot uses TCP over local WiFi without encryption. If your app handles sensitive operations:
- Use Pilot only on trusted networks
- Consider our future plans for encryption (see Roadmap)

⚠️ **Spell Naming:** Be mindful that spell names/descriptions are visible on the remote control. Avoid including sensitive information in spell metadata.

## Use Cases & Compliance

### Perfect For:
- **Demo applications** at conferences and trade shows
- **Prototype presentations** to stakeholders
- **Development and testing** of VR/AR experiences
- **Public installations** with controlled environments
- **Enterprise internal tools** on private networks

### Enterprise & Proprietary Software
Pilot is specifically designed for apps with proprietary implementations:
- No source code exposure
- No business logic transmission
- No data exfiltration

## Future Roadmap

We're planning to enhance privacy and security:

- **Bluetooth LE support** - For even more isolated device-to-device communication
- **Apple Multipeer Connectivity** (Maybe) - Platform-native peer-to-peer with encryption
- **Optional encryption layer** - End-to-end encryption for sensitive deployments
- **Authentication mechanisms** - Optional pairing/passcode protection

## Questions or Concerns?

We're committed to transparency about our privacy practices.

- **Technical questions:** Check our [source code](https://github.com/stobo-app/Pilot) and the README.md -> one of the reason we made it open source ;)
- **Privacy concerns:** Email our CTO directly **[jonathan@stobo.app](mailto:jonathan@stobo.app)**
- **Security issues:** Please report responsibly to **[jonathan@stobo.app](mailto:jonathan@stobo.app)** he will handled it in a timely fashion

---

**Last Updated:** October 9, 2025  
**Pilot SDK Version:** 0.0.2 


