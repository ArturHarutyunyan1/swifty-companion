//
//  swifty_companionApp.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import SwiftUI

@main
struct swifty_companionApp: App {
    @StateObject var networkMonitor = NetworkMonitor()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL {url in
                    handleRedirect(url: url)
                }
                .environmentObject(networkMonitor)
        }
    }
}

func handleRedirect(url: URL) {
    if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
       let queryItems = components.queryItems {
        for item in queryItems {
            if item.name == "code", let code = item.value {
                print("Received auth code: \(code)")  // Add this to check the auth code
                OAuthManager.shared.exchangeForToken(authCode: code)
            }
        }
    }
}
