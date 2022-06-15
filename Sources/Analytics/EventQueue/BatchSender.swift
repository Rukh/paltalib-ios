//
//  BatchSender.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 02/06/2022.
//

import Foundation
import CoreData
import PaltaLibCore

enum BatchSendError: Error {
    case serializationError(Error)
    case networkError(URLError)
    case notConfigured
}

protocol BatchSender {
    func sendBatch(_ batch: Batch, completion: @escaping (Result<Void, BatchSendError>) -> Void)
}

final class BatchSenderImpl: BatchSender {
    var apiToken: String? {
        didSet {
            httpClient.mandatoryHeaders = [
                "X-API-Key": apiToken ?? ""
            ]
        }
    }
    
    var url: URL?
    
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func sendBatch(_ batch: Batch, completion: @escaping (Result<Void, BatchSendError>) -> Void) {
        guard let url = url else {
            completion(.failure(.notConfigured))
            return
        }

        let data: Data
        
        do {
            data = try batch.serialize()
        } catch {
            completion(.failure(.serializationError(error)))
            return
        }
        
        let request = BatchSendRequest(
            url: url,
            sdkName: "IOS-PROTOTYPE",
            sdkVersion: "-1",
            time: .currentTimestamp(),
            data: data
        )
        
        httpClient.perform(request) { (result: Result<String, NetworkErrorWithoutResponse>) in
            switch result {
            case .success:
                completion(.success(()))
                
            case .failure(let error):
                print(error)
                completion(.failure(.networkError(.init(.badURL))))
            }
        }
    }
}