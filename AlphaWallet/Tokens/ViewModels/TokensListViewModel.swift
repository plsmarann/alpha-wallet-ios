//
//  TokensListViewModel.swift
//  AlphaWallet
//
//  Created by PL Smarann Khadka on 18/06/2023.
//

// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit
import Combine
import AlphaWalletFoundation

class TokensListViewModel {
    var fromTokens: [TokenItem] = []

  
    func fetchTokens(limit: Int, completion: @escaping ([TokenItem]) -> Void) {
        let urlString = "https://li.quest/v1/connections?fromChain=1&toChain=1"

        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching tokens: \(error)")
                completion([])
                return
            }

            guard let data = data else {
                print("Empty response data")
                completion([])
                return
            }

            do {
                let connectionResponse = try JSONDecoder().decode(ConnectionResponse.self, from: data)
                
                if let connection = connectionResponse.connections.first {
                    let limitedTokens = Array(connection.fromTokens.prefix(limit))
                    self.fromTokens = limitedTokens
                    completion(limitedTokens)
                } else {
                    print("No connections found")
                    completion([])
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion([])
            }
        }.resume()
    }
  
}

