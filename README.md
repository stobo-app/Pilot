![Pilot Banner](./images/banner.png)

# Simplify your Apple Vision Pro demos

Pilot turns your app into a remote controllable experience with **a single line of code**.

## Let's spin this up!

### Step 1: Get the package

Copy the repo url. Open XCode and add Pilot as an SPM dependency to your project.

### Step 2: Configure Pilot in your code

`import Pilot` at the top of your .swift file and apply the `.tryASpell()` modifier to your root view. This will start all networking tasks and set some mock spells to test Pilot with your app.

<!-- >[!TIP]
If your app is using UIKit, please refer directly to the [programmatic API](documentation coming soon). -->

### Step 3: Install Stobo Control

Download **[Stobo Control](https://apps.apple.com/fr/app/storyboard-pilot/id6746539692)** on your iPhone or iPad, our remote control app.

### Step 4: Test your experience
 >[!WARNING]
 Make sure both your devices (the one running your app and the one running Stobo) are connected to the same Wi-Fi network.

Open **Stobo Control**, you should see “*SpellBook”* at the top of your screen. Tap *“SpellBook”*, then tap on *“Revelio”*. Now check your Apple Vision Pro (or simulator).


Working? Great! Then you are ready to work on your own spells.


>[!TIP]
If you do not see *"SpellBook"* listed, or no action is happening when you tap on "*Revelio ✨"*, refer to our [Troubleshooting Guide](https://docs.stobo.app/s/afafd1aa-a3f1-4fbf-844e-26881024e9b7).

# Create your own Spells

**Pilot** integrates with your app using `Spells`. A `Spell` defines what your users will see on **Stobo Control** (name, description, icons...) and what action will be remotely triggered when a `Spell` is cast.

## Get started

To register a `Spell`, simply declare an array of type `[any AnySpell]`. This allows you to declare a non-homogeneous array of generic `Spell` structures. Once declared, register your `Spell` array with Pilot using `.startPilot(appName:, spells:)`. Apply this modifier on your root view and let Pilot handle the communication and networking for you.

## Examples

There are currently 3 ways to manage your `Spells`. Open the demo app and see all of them in action:

### 1. Reactive setup

With the reactive setup you get a truly SwiftUI-oriented approach. Use `.startPilot(appName:, spells:)` to pass a binding to a list of spells that you can then update during the view lifecycle. This setup allows you to start advertising the app on your local network instantly and add or remove `Spells` progressively.

For example, if your app has multiple Views, you can trigger navigation between the views using a Spell and add specific actions depending on what screen your user is facing in the app.

To test this configuration refer to the `ReactiveSpellBookView.swift` file.


### 2. Async setup

With the async setup you can defer the advertising of your app until your content is ready. Use `.startPilot(appName:, getSpells:)` to pass an async function that will prepare your data and create your `Spells`. Pilot will start advertising your app on the network only once the getSpells function finishes executing.

This ensures users never connect to an app with an empty list of Spells. For example, when your app needs to fetch content or load assets before being usable.

A common case would be immersive media apps that need to download a list of videos or 3D assets from a server. By waiting for the async function to resolve, you guarantee that your users will always land in a ready-to-control experience.

To test this configuration refer to the `AsyncSpellBookView.swift` file.

### 3. Manual setup

With the manual setup you get full programmatic control over Pilot. By accessing the pilotTarget environment variable `@Environment(\.pilotTarget)` you can directly call the functions without using the modifiers.

This approach is especially useful if you are working with UIKit or prefer to have more granular control over the Pilot communication lifecycle. You can take care of registering, starting, stopping hosting, or registering spells yourself, while still letting Pilot handle the network communication and setup for you.

To test this configuration refer to the `ContentView.swift` file.

>[!TIP]
In the manual setup `ContentView.swift`, you can see that a custom Spell ID is defined. This ID is used with `pilotTarget.invoke` to notify back to the control app of a change of state for a given Spell. This allows two-way synchronization of actions. For example, in a video player, both the remote control and the Apple Vision Pro can trigger play/pause.

## API reference

🚧 Work in progress (but feel free to refer to the source code, specifically in the `SpellTarget.swift` file)

# Why Pilot?

## Privacy oriented design
   * Sensitive data (payloads and function declarations) are stored **only on the controlled app**. Your app.
   * Stobo never has access to your logic or payloads.

## Non-intrusive API integration
   * Use your existing code to integrate Pilot in your app.
   * Even at runtime, only spell IDs defined automatically or manually are transmitted over the network. Perfect for proprietary apps looking to add a remote control protocol in record time without compromising their proprietary implementation.

## Customizable UI in proprietary software
   * You control names, descriptions, labels and icons depending on the state
   * When you decide to use Pilot with Stobo Control it grants you the best of both worlds. Open source transparency and guarantee of maintenance from our remote control app distributed on the App Store.


---

Now that you know everything, you can design remote experiences that range from simple triggers to fully data-driven controls, always private, always under your control.


## 📬 Contact

We’d love to hear from you!  

- Found an issue or have a feature request? Please open an [issue](https://github.com/stobo-app/Pilot/issues).  
- For anything else, reach me at: **[jonathan@stobo.app](mailto:jonathan@stobo.app)**  
<br>

---

*Pilot is an evolving SDK and may introduce breaking changes while in early versions. We aim to keep the API consistent and will do our best to maintain compatibility, but certain implementations (e.g. communication protocols) may change as we plan to experiment with BLE, and Apple's MPC protocol in the near future. Please refer to the changelog of each release for details*
