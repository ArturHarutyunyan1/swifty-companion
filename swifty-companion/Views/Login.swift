//
//  Login.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import SwiftUI

struct Login: View {
    @ObservedObject var OAuth = OAuthManager.shared
    var body: some View {
        GeometryReader {geometry in
            VStack {
                Button(action: {
                    Task {
                        OAuth.authorize()
                    }
                }, label: {
                    Text("Login")
                })
                .padding()
                .frame(width: 200)
                .background(.black)
                .foregroundStyle(.white)
                .cornerRadius(15)
                .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    Login()
}
