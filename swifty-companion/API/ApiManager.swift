//
//  ApiManager.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import Foundation
import SwiftUI

class ApiManager : ObservableObject {
    @Published var userInfo: UserInfo?
    @ObservedObject var OAuth = OAuthManager.shared
    
    func searchUser(username: String) async {
        OAuth.checkExpiration()
        let url = URL(string: "https://api.intra.42.fr/v2/users/\(username)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "access_token") ?? "")", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) {data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.OAuth.errorMsg = "Something went wrong, please try again"
                }
                return
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 404 {
                    DispatchQueue.main.async {
                        self.OAuth.errorMsg = "User not found"
                    }
                    return
                }
                if response.statusCode != 200 {
                    DispatchQueue.main.async {
                        self.OAuth.errorMsg = "Something went wrong - \(response.statusCode)"
                    }
                    return
                }
            }
            if let data = data {
                do {
                    let decoder = try JSONDecoder().decode(UserInfo.self, from: data)
                    DispatchQueue.main.async {
                        self.userInfo = decoder
                        self.OAuth.errorMsg = ""
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.OAuth.errorMsg = "SOmething went wrong, please try again"
                    }
                }
            }
        }.resume()
    }
}
