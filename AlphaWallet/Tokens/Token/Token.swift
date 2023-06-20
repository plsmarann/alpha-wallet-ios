//
//  Token.swift
//  AlphaWallet
//
//  Created by PL Smarann Khadka on 18/06/2023.
//
struct ConnectionResponse: Decodable {
    let connections: [Connection]

    private enum CodingKeys: String, CodingKey {
        case connections
    }
}

struct Connection: Decodable {
    let fromChainId: Int
    let toChainId: Int
    let fromTokens: [TokenItem]

    private enum CodingKeys: String, CodingKey {
        case fromChainId, toChainId, fromTokens
    }
}

struct TokenItem: Decodable {
    let address: String
    let chainId: Int
    let symbol: String
    let decimals: Int
    let name: String
    let priceUSD: String?
    let coinKey: String
    let logoURI: String?

    private enum CodingKeys: String, CodingKey {
        case address, chainId, symbol, decimals, name, priceUSD, coinKey, logoURI
    }
}
