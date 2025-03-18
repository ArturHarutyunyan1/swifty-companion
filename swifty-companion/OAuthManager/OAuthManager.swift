//
//  OAuthManager.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import Foundation
import UIKit


class OAuthManager : ObservableObject {
    static let shared = OAuthManager()
    private var credentials: Credentials?
    private var tokenValue: TokenValue?
    @Published var isLoggedIn = false
    @Published var errorMsg = ""
    
    init() {
        checkExpiration()
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
                        let creationTime = Date.now
                        let expirationTime = Calendar.current.date(byAdding: .hour, value: 2, to: creationTime)!
                        UserDefaults.standard.set(true, forKey: "LoginStatus")
                        UserDefaults.standard.set(token.access_token, forKey: "access_token")
                        UserDefaults.standard.set(expirationTime, forKey: "token_expiration_time")
                    }
                } catch {
                    self.errorMsg = "Something went wrong, please try again"
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
        UserDefaults.standard.set(nil, forKey: "access_token")
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
    func checkExpiration() {
        if let expirationTime = UserDefaults.standard.value(forKey: "token_expiration_time") as! Date?,
           Date.now > expirationTime
        {
            self.errorMsg = "Your access token has expired. Please login again."
            self.logout()
        }
    }
}
