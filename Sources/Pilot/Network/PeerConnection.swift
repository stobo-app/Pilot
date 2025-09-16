//
//  PeerConnection.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 20/08/2025
//

import Foundation
import Network

// Create parameters for use in PeerConnection and PeerListener with app services.
func applicationServiceParameters() -> NWParameters {
    return NWParameters.tcp
}

public final class PeerConnection {
    private weak var connectionManager: ConnectionManager?
    var connection: NWConnection?
    let endpoint: NWEndpoint?
    let initiatedConnection: Bool
    
    // Handle an inbound connection when the user receives a connection request from a peer
    init(
        connection: NWConnection,
        connectionManager: ConnectionManager?
    ) {
        self.connectionManager = connectionManager
        self.endpoint = nil
        self.connection = connection
        self.initiatedConnection = false
        
        startConnection()
    }
    
    // Create an outbound connection when the user initiates a connection to a peer
    init(
        endpoint: NWEndpoint,
        interface: NWInterface?,
        connectionManager: ConnectionManager?
    ) {
        self.connectionManager = connectionManager
        self.endpoint = endpoint
        self.initiatedConnection = true
        
        // Use consistent parameters for both inbound and outbound connections
        let connection = NWConnection(to: endpoint, using: applicationServiceParameters())
        self.connection = connection
        
        startConnection()
    }
    
    func cancel() {
        if let connection = self.connection {
            connection.cancel()
            self.connection = nil
        }
    }
    
    func startConnection() {
        guard let connection = connection else { return }
        
        connection.stateUpdateHandler = { [weak self] newState in
            guard let self else { return }
            switch newState {
            case .ready:
                self.receiveNextMessage()
                self.connectionManager?.connectionReady()
            case .failed(let error):
                // Cancel the connection upon a failure.
                connection.cancel()
                
                
                if let endpoint = self.endpoint, self.initiatedConnection && error == NWError.posix(.ECONNABORTED) {
                    // Reconnect if the user suspends the app on the nearby device.
                    let connection = NWConnection(to: endpoint, using: applicationServiceParameters())
                    self.connection = connection
                    self.startConnection()
                } else {
                    self.connectionManager?.connectionFailed()
                }
            case .cancelled:
                // Connection was cancelled (e.g., app closed on STDemo side)
                self.connectionManager?.connectionLost()
            default:
                break
            }
        }
        
        // Start the connection establishment.
        connection.start(queue: .main)
    }
    
    func send(_ message: Message, onSuccess: (() -> Void)? = nil, onFail: (() -> Void)? = nil) {
        guard let connection else { return }
        
        do {
            let jsonData = try JSONEncoder().encode(message)
            let context = NWConnection.ContentContext(identifier: "JSONMessage", metadata: [])
            
            // Log the message being sent
            logger.info("📤 Sending message: \(message)")
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                logger.debug("📤 JSON payload: \(jsonString)")
            }
            
            connection.send(
                content: jsonData,
                contentContext: context,
                isComplete: true,
                completion: .contentProcessed { error in
                    if let error {
                        logger.error("❌ Failed to send message: \(error)")
                        onFail?()
                    } else {
                        logger.debug("✅ Message sent successfully")
                        onSuccess?()
                    }
                }
            )
        } catch {
            logger.error("❌ Failed to encode message as JSON: \(error)")
        }
    }
    
    // Receive a message, deliver it to your delegate, and continue receiving more messages.
    func receiveNextMessage() {
        guard let connection = connection else {
            return
        }
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, context, isComplete, error) in
            if let error = error {
                logger.error("❌ Failed to receive message: \(error)")
                return
            }
            
            if let data = data, !data.isEmpty {
                // Log the received data
                if let jsonString = String(data: data, encoding: .utf8) {
                    logger.debug("📥 Received JSON payload: \(jsonString)")
                }
                
                do {
                    let message = try JSONDecoder().decode(Message.self, from: data)
                    logger.info("📥 Received message: \(message)")
                    self.connectionManager?.receivedMessage(message)
                } catch {
                    logger.error("❌ Failed to decode JSON message: \(error)")
                }
            }
            
            if error == nil {
                self.receiveNextMessage()
            }
        }
    }
}
