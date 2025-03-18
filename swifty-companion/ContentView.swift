//
//  ContentView.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var OAuth = OAuthManager.shared
    @EnvironmentObject var networkMonitor: NetworkMonitor
    var body: some View {
        VStack {
            if networkMonitor.isConnected {
                if OAuth.isLoggedIn {
                    Home()
                } else {
                    Login()
                }
            } else {
                VStack {
                    Text("No internet connection")
                        .font(.system(size: 28))
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .onAppear() {
            OAuth.checkExpiration()
        }
    }
}

#Preview {
    ContentView()
}
