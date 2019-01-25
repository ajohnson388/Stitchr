//
//  Codable+Extensions.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

extension Encodable {
    
    func encode(keyStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase,
                dateStrategy: JSONEncoder.DateEncodingStrategy = .iso8601) -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = keyStrategy
        encoder.dateEncodingStrategy = dateStrategy

        do {
            return try encoder.encode(self)
        } catch {
            Logger.log(error.localizedDescription)
            return nil
        }
    }
}

extension Decodable {
    
    static func decode(data: Data?,
                       keyStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase,
                       dateStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) -> Self? {
        guard let data = data else { return nil }
        print(try? JSONSerialization.jsonObject(with: data, options: []))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyStrategy
        decoder.dateDecodingStrategy = dateStrategy
        do {
            return try decoder.decode(self, from: data)
        } catch {
            Logger.log(error)
            return nil
        }
    }
}
