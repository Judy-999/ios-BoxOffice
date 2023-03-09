//
//  URLCacheManager.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/03/07.
//

import UIKit
import RxSwift

final class URLCacheManager {
    static let shared = URLCacheManager()
    private let cache = URLCache.shared
    private var dataTask: URLSessionDataTask?
    
    private init(dataTask: URLSessionDataTask? = nil) {
        self.dataTask = dataTask
    }
    
    func getDataFromCache(with request: URLRequest) -> Data? {
        guard let data = cache.cachedResponse(for: request)?.data else { return nil }
        
        return data
    }
    
    func saveDataInCache(with request: URLRequest, _ response: URLResponse, _ data: Data) {
        let cachedData = CachedURLResponse(response: response, data: data)
        self.cache.storeCachedResponse(cachedData, for: request)
    }
}
