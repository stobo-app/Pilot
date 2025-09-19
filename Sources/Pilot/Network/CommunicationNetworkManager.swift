//
//  NetworkManager.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 20/08/2025
//

import Foundation
import Network

@Observable
public class ConnectionManager {
    static let serviceType = "_storyboard._tcp"
    static let deviceId: String = {
        let userDefaults = UserDefaults.standard
        let key = "PilotDeviceId"
        
        if let existingId = userDefaults.string(forKey: key) {
            return existingId
        }
        
        // Generate new random 3-digit ID
        let randomId = String(format: "%03d", Int.random(in: 0...999))
        userDefaults.set(randomId, forKey: key)
        return randomId
    }()
    
    var name = "UnknownApp"
    var mode: ConnectionMode = .none
    public var isConnected: Bool {
        mode == .connected
    }
    
    // Available apps discovered on the network
    public var availableApps: [AvailableApp] = []
    
    // Connection management
    public var sharedConnection: PeerConnection?
    var bonjourListener: PeerListener?
    var sharedBrowser: PeerBrowser?
    
    // Message handling callback
    public var onMessageReceived: ((Message) -> Void)?
    
    // Connection event callbacks
    public var onConnectionReady: (() -> Void)?
    public var onConnectionFailed: (() -> Void)?
    public var onConnectionError: ((NWError) -> Void)?
    public var onConnectionLost: (() -> Void)?
    
    public init() {}
}

// MARK: - Core Functionality

extension ConnectionManager {
    
    // MARK: - Hosting
    
    public func startHosting(appName: String) {
        assert(!appName.contains("_"), "Hosting failed, underscore characater is forbiden in the application name")
        logger.info("NetworkManager: startHosting called for app: \(appName) on device: \(Self.deviceId)")
        
        logger.info("NetworkManager: Stopping any existing services before starting hosting")
        stopAll()
        
        let serviceName = "\(appName)_\(Self.deviceId)"
        self.name = serviceName
        logger.info("NetworkManager: Service name set to: \(serviceName)")
        
        mode = .hosting
        logger.info("NetworkManager: Mode set to hosting")
        
        bonjourListener = PeerListener(connectionManager: self)
        logger.info("NetworkManager: PeerListener created and hosting started")
    }
    
    public func startDiscovering() {
        logger.info("Starting discovery mode")
        
        // Stop any existing services
        stopAll()
        
        mode = .discovering
        sharedBrowser = PeerBrowser(connectionManager: self)
    }
    
    // MARK: - Connection Management
    
    public func connect(to availableApp: AvailableApp) {
        logger.info("Connecting to app: \(availableApp.appName)")
        
        // Stop discovering
        if mode == .discovering {
            sharedBrowser?.browser?.cancel()
            sharedBrowser = nil
        }
        
        // Establish connection
        mode = .connected
        sharedConnection = PeerConnection(
            endpoint: availableApp.endpoint,
            interface: nil,
            connectionManager: self
        )
    }
    
    public func disconnect() {
        logger.info("Disconnecting")
        
        sharedConnection?.cancel()
        sharedConnection = nil
        mode = .none
    }
    
    public func stopAll() {
        availableApps = []
        // Stop hosting
        if bonjourListener != nil {
            logger.info("NetworkManager: Stopping bonjour listener")
            bonjourListener?.stopListening()
            bonjourListener = nil
        }
        
        // Stop discovering
        if sharedBrowser != nil {
            logger.info("NetworkManager: Stopping shared browser")
            sharedBrowser?.browser?.cancel()
            sharedBrowser = nil
        }
        
        // Stop connection
        if sharedConnection != nil {
            logger.info("NetworkManager: Stopping shared connection")
            sharedConnection?.cancel()
            sharedConnection = nil
        }
        
        mode = .none
        logger.info("NetworkManager: All services stopped, mode set to none")
    }
    
    // MARK: - Messaging
    
    public func send(_ message: Message, onSuccess: (() -> Void)? = nil, onFail: (() -> Void)? = nil) {
        logger.info("📤 Sending message through network manager: \(message)")
        sharedConnection?.send(message, onSuccess: onSuccess, onFail: onFail)
    }
}

// MARK: - Browser Results Processing

extension ConnectionManager {
    
    func refreshResults(results: Set<NWBrowser.Result>) {
        logger.info("Processing \(results.count) discovered applications")
        
        availableApps = []
        
        for result in results {
            if case let NWEndpoint.service(name: serviceName, type: type, domain: _, interface: _) = result.endpoint {
                if type == ConnectionManager.serviceType {
                    // Parse service name: "AppId-AppName-DeviceId"
                    let components = serviceName.components(separatedBy: "_")
                    if components.count >= 2 {
                        let appName = components[0]
                        let deviceId = components[1]
                        
                        let availableApp = AvailableApp(
                            appName: appName,
                            deviceId: deviceId,
                            endpoint: result.endpoint
                        )
                        
                        availableApps.append(availableApp)
                        logger.info("Found app: \(appName) on device: \(deviceId)")
                    } else {
                        logger.warning("Invalid service name format: \(serviceName)")
                    }
                }
            }
        }
        
        logger.info("Total available apps: \(self.availableApps.count)")
    }
    
    func browsingError(_ error: NWError) {
        logger.error("Browsing error: \(error.localizedDescription)")
    }
    
    func connectionCancelled() {
        logger.info("Browser connection cancelled")
        sharedBrowser = nil
    }
}

// MARK: - Connection Event Handling

extension ConnectionManager {
    
    public func connectionReady() {
        logger.info("Connection ready")
        onConnectionReady?()
    }
    
    public func connectionFailed() {
        logger.error("Connection failed")
        onConnectionFailed?()
        disconnect()
    }
    
    public func connectionError(_ error: NWError) {
        logger.error("Connection error: \(error.localizedDescription)")
        onConnectionError?(error)
        disconnect()
    }
    
    public func connectionLost() {
        logger.info("Connection lost - STDemo app may have closed")
        onConnectionLost?()
        disconnect()
    }
    
    func receivedMessage(_ message: Message) {
        logger.info("📥 Processing received message: \(message)")
        onMessageReceived?(message)
    }
}
