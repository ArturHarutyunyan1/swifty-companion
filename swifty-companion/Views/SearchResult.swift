//
//  SearchResult.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import SwiftUI

struct SearchResult: View {
    @ObservedObject var OAuth = OAuthManager.shared
    @Binding var username: String
    var body: some View {
        GeometryReader {geometry in
            VStack {
                Text("Search results for \(username)")
                    .font(.system(size: 25))
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            Task {
                OAuth.searchUser(username: username)
            }
        }
    }
}
