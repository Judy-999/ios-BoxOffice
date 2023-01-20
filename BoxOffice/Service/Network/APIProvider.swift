//
//  APIClient.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02. -> Refacted by Judy on 2023/01/20.
//

import Foundation

final class APIProvider {
    static let shared = APIProvider(sesseion: URLSession.shared)
    private let session: URLSession
    
    private init(sesseion: URLSession) {
        self.session = sesseion
    }
    
    func requestData(with urlRequest: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: urlRequest)
        let successRange = 200..<300
        if let statusCode = (response as? HTTPURLResponse)?.statusCode,
           !successRange.contains(statusCode) {
            
        }
        return data
    }
}
