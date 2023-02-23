//
//  ImageCacheManager.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/04.
//

import UIKit
import RxSwift

protocol ImageCacheManager {
    func getImage(with imageURL: URL?) -> Observable<UIImage?>
}

final class URLCacheManager: ImageCacheManager {
    private let cache = URLCache.shared
    private var dataTask: URLSessionDataTask?
    
    func getImage(with imageURL: URL?) -> Observable<UIImage?> {
        guard let imageURL = imageURL else {
            return Observable<UIImage?>.just(nil)
        }
        
        let request = URLRequest(url: imageURL)
        
        if cache.cachedResponse(for: request) != nil {
            return Observable.just(loadImageFromCache(with: imageURL))
        }
        
        return downloadImage(with: imageURL)
    }
    
    func loadImageFromCache(with imageURL: URL) -> UIImage? {
        let request = URLRequest(url: imageURL)
        
        guard let data = cache.cachedResponse(for: request)?.data else { return nil }
        return UIImage(data: data)
    }
    
    func downloadImage(with imageURL: URL) -> Observable<UIImage?> {
        let request = URLRequest(url: imageURL)
        
        return URLSession.shared.rx
            .response(request: request)
            .do { response,data in
                let cachedData = CachedURLResponse(response: response, data: data)
                self.cache.storeCachedResponse(cachedData, for: request)
            }
            .map { _, data in
                UIImage(data: data)
            }
    }
}
