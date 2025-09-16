//
//  PeerListener.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 8/29/25.
//

import Network

final class PeerListener {
    private weak var connectionManager: ConnectionManager?
    var listener: NWListener?
    
    // Create a listener with a name to advertise, a passcode for authentication,
    // and a delegate to handle inbound connections.
    init(connectionManager: ConnectionManager?) {
        self.connectionManager = connectionManager
        setupBonjourListener()
    }
    
    // Start listening and advertising.
    func setupBonjourListener() {
        logger.info("PeerListener: setupBonjourListener called")
        do {
            logger.info("PeerListener: Setting up bonjour listener")
            // Create the listener object with consistent parameters
            let listener = try NWListener(using: applicationServiceParameters())
            self.listener = listener
            logger.info("PeerListener: NWListener created successfully")
            
            // Use the service name that was set by the connection manager
            // The name should already include the app name and device ID
            let serviceName = connectionManager?.name ?? "UnknownApp"
            logger.info("PeerListener: Advertising service with name: \(serviceName)")
            
            listener.service = NWListener.Service(
                name: serviceName,
                type: ConnectionManager.serviceType
            )
            logger.info("PeerListener: Service configured with type: \(ConnectionManager.serviceType)")
            
            startListening()
        } catch {
            // Gracefully handle error
            logger.error("PeerListener: Failed to create bonjour listener: \(error)")
            return
        }
    }
    
    func bonjourListenerStateChanged(newState: NWListener.State) {        
        switch newState {
        case .ready:
            logger.info("PeerListener: Listener ready on \(String(describing: self.listener?.port))")
        case .failed(let error):
            logger.error("PeerListener: Listener failed with error: \(error)")
            if error == NWError.dns(DNSServiceErrorType(kDNSServiceErr_DefunctConnection)) {
                logger.error("PeerListener: DNS defunct connection error, restarting listener")
                self.listener?.cancel()
                self.setupBonjourListener()
            } else {
                logger.error("PeerListener: Other error, stopping listener")
                self.connectionManager?.connectionError(error)
                self.listener?.cancel()
            }
        case .cancelled:
            logger.info("PeerListener: Listener cancelled")
            // Don't set bonjourListener to nil here - let NetworkManager handle it
        case .setup:
            logger.info("PeerListener: Listener in setup state")
        case .waiting(let error):
            return
        default:
            return
        }
    }
    
    func startListening() {
        logger.info("PeerListener: startListening called")
        self.listener?.stateUpdateHandler = bonjourListenerStateChanged
        
        // The system calls this when a new connection arrives at the listener.
        // Start the connection to accept it, cancel to reject it.
        self.listener?.newConnectionHandler = { [weak self] newConnection in
            guard let self else { return }
            
            logger.info("PeerListener: newConnectionHandler called")
            
            if self.connectionManager?.sharedConnection == nil {
                logger.info("PeerListener: Creating new PeerConnection")
                self.connectionManager?.sharedConnection = PeerConnection(
                    connection: newConnection,
                    connectionManager: self.connectionManager
                )
            } else {
                logger.info("PeerListener: Connection already exists, cancelling new connection")
                newConnection.cancel()
            }
        }
        
        // Start listening, and request updates on the main queue.
        logger.info("PeerListener: Starting listener on main queue")
        self.listener?.start(queue: .main)
    }
    
    // Stop listening.
    func stopListening() {
        logger.info("PeerListener::stopListening")
        
        if let listener = listener {
            listener.cancel()
            // Don't set bonjourListener to nil here - let NetworkManager handle it
        }
    }
}
