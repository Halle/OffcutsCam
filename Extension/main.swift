//
//  main.swift
//  Extension
//
//  Created by Halle Winkler on 10.08.22.
//

import Foundation
import CoreMediaIO

let providerSource = ExtensionProviderSource(clientQueue: nil)
CMIOExtensionProvider.startService(provider: providerSource.provider)

CFRunLoopRun()
