//
//  ContentView.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var OAuth = OAuthManager.shared
    var body: some View {
        VStack {
            if OAuth.isLoggedIn {
                Text("Welcome!")
            } else {
                Button(action: {
                    OAuth.authorize()
                }, label: {
                    Text("Log in")
                })
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
