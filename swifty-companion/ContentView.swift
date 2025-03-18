//
//  ContentView.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var OAuth = OAuthManager.shared
    @State var username = "arturhar"
    var body: some View {
        VStack {
            if OAuth.isLoggedIn {
//                Home()
                SearchResult(username: $username)
            } else {
                Login()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
