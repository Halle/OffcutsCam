//
//  ContentView.swift
//  OffcutsCam
//
//  Created by Halle Winkler on 10.08.22.
//

import SwiftUI
import SystemExtensions

struct ContentView: View {
    @ObservedObject var systemExtensionRequestManager: SystemExtensionRequestManager

    var body: some View {
        VStack {
            Button("Install", action: {
                systemExtensionRequestManager.install()
            })
            Button("Uninstall", action: {
                systemExtensionRequestManager.uninstall()
            })
        }
        Text(systemExtensionRequestManager.logText)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(systemExtensionRequestManager: SystemExtensionRequestManager(logText: ""))
    }
}

class SystemExtensionRequestManager: NSObject, ObservableObject {
    @Published var logText: String = "Installation results here"

    init(logText: String) {
        super.init()
        self.logText = logText
    }

    func install() {
        guard let extensionIdentifier = _extensionBundle().bundleIdentifier else { return }
        let activationRequest = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: extensionIdentifier, queue: .main)
        activationRequest.delegate = self
        OSSystemExtensionManager.shared.submitRequest(activationRequest)
    }

    func uninstall() {
        guard let extensionIdentifier = _extensionBundle().bundleIdentifier else { return }
        let deactivationRequest = OSSystemExtensionRequest.deactivationRequest(forExtensionWithIdentifier: extensionIdentifier, queue: .main)
        deactivationRequest.delegate = self
        OSSystemExtensionManager.shared.submitRequest(deactivationRequest)
    }

    func _extensionBundle() -> Bundle {
        let extensionsDirectoryURL = URL(fileURLWithPath: "Contents/Library/SystemExtensions", relativeTo: Bundle.main.bundleURL)
        let extensionURLs: [URL]
        do {
            extensionURLs = try FileManager.default.contentsOfDirectory(at: extensionsDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        } catch {
            fatalError("failed to get the contents of \(extensionsDirectoryURL.absoluteString): \(error.localizedDescription)")
        }
        guard let extensionURL = extensionURLs.first else {
            fatalError("failed to find any system extensions")
        }
        guard let extensionBundle = Bundle(url: extensionURL) else {
            fatalError("failed to create a bundle with URL \(extensionURL.absoluteString)")
        }
        return extensionBundle
    }
}

extension SystemExtensionRequestManager: OSSystemExtensionRequestDelegate {
    public func request(_ request: OSSystemExtensionRequest, actionForReplacingExtension existing: OSSystemExtensionProperties, withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        logText = "Replacing extension version \(existing.bundleShortVersion) with \(ext.bundleShortVersion)"
        return .replace
    }

    public func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        logText = "Extension needs user approval"
    }

    public func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        switch result.rawValue {
        case 0:
            logText = "\(request) did finish with success"
        case 1:
            logText = "\(request) Extension did finish with result success but requires reboot"
        default:
            logText = "\(request) Extension did finish with result \(result)"
        }
    }

    public func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        let errorCode = (error as NSError).code
        var errorString = ""
        switch errorCode {
        case 1:
            errorString = "unknown error"
        case 2:
            errorString = "missing entitlement"
        case 3:
            errorString = "Container App for Extension has to be in /Applications to install Extension."
        case 4:
            errorString = "extension not found"
        case 5:
            errorString = "extension missing identifier"
        case 6:
            errorString = "duplicate extension identifer"
        case 7:
            errorString = "unknown extension category"
        case 8:
            errorString = "code signature invalid"
        case 9:
            errorString = "validation failed"
        case 10:
            errorString = "forbidden by system policy"
        case 11:
            errorString = "request canceled"
        case 12:
            errorString = "request superseded"
        case 13:
            errorString = "authorization required"
        default:
            errorString = "unknown code"
        }
        logText = "Extension did fail with error: \(errorString)"
    }
}
