//
//  PeerBrowser.swift
//  Pilot
//
//  Created by Jonathan Bereyziat on 20/08/2025
//

import Network

final class PeerBrowser {
    var browser: NWBrowser?
    
    private weak var connectionManager: ConnectionManager?
    
    // Create a browsing object with a delegate.
    init(connectionManager: ConnectionManager?) {
        self.connectionManager = connectionManager
        
        startBrowsing()
    }
    
    // Start browsing for services.
    func startBrowsing() {
        // Create parameters, and allow browsing over a peer-to-peer link.
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        let browser = NWBrowser(
            for: .bonjour(type: ConnectionManager.serviceType, domain: nil),
            using: parameters
        )
        self.browser = browser
        
        browser.stateUpdateHandler = { newState in
            switch newState {
            case .failed(let error):
                // Restart the browser if it loses its connection.
                if error == NWError.dns(DNSServiceErrorType(kDNSServiceErr_DefunctConnection)) {
                    logger.error("Browser failed with \(error), restarting")
                    browser.cancel()
                    self.startBrowsing()
                } else {
                    logger.error("Browser failed with \(error), stopping")
                    self.connectionManager?.browsingError(error)
                    browser.cancel()
                }
            case .ready:
                self.connectionManager?.refreshResults(results: browser.browseResults)
            case .cancelled:
                self.connectionManager?.connectionCancelled()
            default:
                break
            }
        }
        
        // When the list of discovered endpoints changes, refresh the delegate.
        browser.browseResultsChangedHandler = { results, changes in
            self.connectionManager?.refreshResults(results: results)
        }
        
        // Start browsing and ask for updates on the main queue.
        browser.start(queue: .main)
    }
}
