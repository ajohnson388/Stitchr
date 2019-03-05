//
//  Codable+Extensions.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

extension Encodable {
    
    /// A convenience function for encoding an object into data.
    ///
    /// - Parameters:
    ///   - keyStrategy: An optional strategy for converting the keys.
    ///   - dateStrategy: An optional strategy for converting date values.
    /// - Returns: The encoded data, or nil, if encoding failed.
    func encode(keyStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase,
                dateStrategy: JSONEncoder.DateEncodingStrategy = .iso8601) -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = keyStrategy
        encoder.dateEncodingStrategy = dateStrategy

        do {
            return try encoder.encode(self)
        } catch {
            Logger.log(#function, error)
            return nil
        }
    }
}

extension Decodable {
    
    /// A convenience method to decode data into an object.
    ///
    /// - Parameters:
    ///   - data: The data to construct the object with.
    ///   - keyStrategy: An optional strategy for converting the keys.
    ///   - dateStrategy: An optional strategy for converting date values.
    /// - Returns: The constructed object, or nil, if decoding failed.
    static func decode(data: Data?,
                       keyStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase,
                       dateStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) -> Self? {
        guard let data = data else {
            Logger.log(#function, "Failed to decode data because the data is nil.")
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyStrategy
        decoder.dateDecodingStrategy = dateStrategy
        do {
            return try decoder.decode(self, from: data)
        } catch {
            logJsonFailure(data: data, error: error)
            return nil
        }
    }
    
    private static func logJsonFailure(data: Data, error: Error) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            Logger.log(json as Any)
        } catch {
            Logger.log(#function, "Failed to parse json with data: \(data) with error \(error)")
        }
    }
}
