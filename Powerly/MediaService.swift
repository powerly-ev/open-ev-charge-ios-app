//
//  MediaService.swift
//  Powerly
//
//  Created by ADMIN on 30/08/24.
//  
//

import Foundation

struct MediaResult {
    let statusCode: Int
    let message: String
    let mediaList: [Media]
}

struct MediaService {
    func addMediaToPowerSource(id: String, title: String, medias: [Data]) async throws -> MediaResult {
        return try await withCheckedThrowingContinuation { continuation in
            NetworkManager().performAPIRequest(request: .addMediaToPowerSource(id, title, medias)) { json, _ in
                guard let json = json else {
                    continuation.resume(throwing: APIError.apiFailure(message: NetworkManager.jsonNilMessage()))
                    return
                }
                let success = json["success"].intValue
                let message = json["msg"].stringValue
                if success == 1 {
                    let decoder = JSONDecoder()
                    if let jsonData = try? json["results"].rawData(),
                       let mediaList = try? decoder.decode([Media].self, from: jsonData) {
                        continuation.resume(returning: MediaResult(statusCode: success, message: message, mediaList: mediaList))
                    } else {
                        continuation.resume(returning: MediaResult(statusCode: success, message: message, mediaList: []))
                    }
                } else {
                    continuation.resume(returning: MediaResult(statusCode: success, message: message, mediaList: []))
                }
            }
        }
    }
    
    func getPowerSourceMediaList(id: String, completion: @escaping (Int, String, [Media]) -> Void) {
        NetworkManager().performAPIRequest(request: .getPowerSourceMediaList(id)) { json, _ in
            guard let json = json else {
                completion(0, NetworkManager.jsonNilMessage(), [])
                return
            }
            
            let success = json["success"].intValue
            let message = json["message"].stringValue
            
            if success == 1 {
                do {
                    let decoder = JSONDecoder()
                    let jsonData = try json["data"].rawData()
                    let makeList = try decoder.decode([Media].self, from: jsonData)
                    completion(success, message, makeList)
                } catch {
                    completion(success, message, [])
                }
            } else {
                completion(success, message, [])
            }
        }
    }
    
    func deleteMediaFromPowersource(id: String, mediaId: Int, completion: @escaping (Int, String, [Media]) -> Void) {
        NetworkManager().performAPIRequest(request: .deleteMediaFromPowersource(id, mediaId)) { json, _ in
            guard let json = json else {
                completion(0, NetworkManager.jsonNilMessage(), [])
                return
            }
            
            let success = json["success"].intValue
            let message = json["msg"].stringValue
            
            if success == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? json["results"].rawData(),
                   let makeList = try? decoder.decode([Media].self, from: jsonData) {
                    completion(success, message, makeList)
                } else {
                    completion(success, message, [])
                }
            } else {
                completion(success, message, [])
            }
        }
    }
}
