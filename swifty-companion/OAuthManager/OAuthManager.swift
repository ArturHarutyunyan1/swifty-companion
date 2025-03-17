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
    @Published var access_token: String = UserDefaults.standard.string(forKey: "access_token") ?? ""
    @Published var isLoggedIn = false
    @Published var errorMsg = ""
    
    init() {
        if UserDefaults.standard.bool(forKey: "LoginStatus") {
            self.isLoggedIn = true
        } else {
            isLoggedIn = false
        }
        if UserDefaults.standard.string(forKey: "access_token") == "" {
            self.isLoggedIn = false
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
                        UserDefaults.standard.set(token.access_token, forKey: "access_token")
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
    func logout() {
        self.isLoggedIn = false
        UserDefaults.standard.set(false, forKey: "LoginStatus")
        UserDefaults.standard.set("", forKey: "access_token")
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
    func searchUser(username: String) {
        let url = URL(string: "https://api.intra.42.fr/v2/users/\(username)")!
        var request = URLRequest(url: url)
        let accessToken = self.access_token
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request failed with error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("HTTP Response: \(response.statusCode)")
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("User Info: \(json)")
                } catch {
                    print("Error decoding user info: \(error)")
                }
            }
        }.resume()
    }
}
