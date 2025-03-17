//
//  OAuthManager.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import Foundation
import UIKit

struct Credentials : Codable {
    var uid: String
    var secret: String
    var url: String
}

struct TokenValue : Codable {
    var access_token: String
}

class OAuthManager : ObservableObject {
    static let shared = OAuthManager()
    private var credentials: Credentials?
    private var tokenValue: TokenValue?
    private var access_token = ""
    @Published var isLoggedIn = false
    @Published var errorMsg = ""
    
    init() {
        if UserDefaults.standard.bool(forKey: "LoginStatus") {
            self.isLoggedIn = true
        } else {
            isLoggedIn = false
        }
        getValues()
    }
    
    func exchangeForToken(authCode: String) {
        let url = URL(string: "https://api.intra.42.fr/oauth/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let params = [
            "grant_type": "authorization_code",
            "client_id": credentials?.uid,
            "client_secret": credentials?.secret,
            "code": authCode,
            "redirect_uri": "myapp://callback"
        ]
        request.httpBody = params
            .map { "\($0.key)=\($0.value ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let data = data {
                do {
                    let token = try JSONDecoder().decode(TokenValue.self, from: data)
                    DispatchQueue.main.async {
                        self.isLoggedIn = true
                        self.access_token = token.access_token
                        UserDefaults.standard.set(true, forKey: "LoginStatus")
                    }
                } catch {
                    print("Error \(error)")
                }
            }
        }.resume()
    }
    func authorize() {
        if let authURL = URL(string: credentials?.url ?? "") {
            UIApplication.shared.open(authURL)
        }
    }
    func getValues() {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let config = try? PropertyListSerialization.propertyList(from: xml, options: [], format: nil) as? [String: Any] {
            if credentials == nil {
                credentials = Credentials(uid: "", secret: "", url: "")
            }
            
            if let uid = config["uid"] as? String {
                credentials?.uid = uid
            }
            if let secret = config["secret"] as? String {
                credentials?.secret = secret
            }
            if let url = config["url"] as? String {
                credentials?.url = url
            }
        }
    }
}
