//
//  URLSession+Rx.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/03/09.
//

import RxSwift
import UIKit

enum NetworkError: Error {
    case unknown
    case invalidResponse(response: URLResponse)
    case requestFailed(response: HTTPURLResponse, data: Data?)
}

extension ObservableType where Element == (URLRequest, HTTPURLResponse, Data) {
    func cache() -> Observable<Element> {
        return self.do(onNext: { (request, response, data) in
            URLCacheManager.shared.saveDataInCache(with: request, response, data)
        })
    }
}

extension Reactive where Base: URLSession {
    func response(request: URLRequest) -> Observable<(URLRequest, HTTPURLResponse, Data)> {
        return Observable.create { observer in
            let task = self.base.dataTask(with: request) { data, response, error in
                guard let response = response, let data = data else {
                    observer.onError(error ?? NetworkError.unknown)
                    return
                }
                
                guard let httpResposne = response as? HTTPURLResponse else {
                    observer.onError(NetworkError.invalidResponse(response: response))
                    return
                }
                
                observer.onNext((request, httpResposne, data))
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create(with: task.cancel)
        }
    }
    
    func data(request: URLRequest) -> Observable<Data> {
        if let data = URLCacheManager.shared.getDataFromCache(with: request) {
            return Observable.just(data)
        }

        return response(request: request).cache().map { _, response, data -> Data in
            if 200..<300 ~= response.statusCode {
                return data
            }
            
            throw NetworkError.requestFailed(response: response, data: data)
        }
    }
    
    func image(with url: URL?) -> Observable<UIImage?> {
        guard let url = url else {
            return Observable<UIImage?>.just(nil)
        }
        
        let request = URLRequest(url: url)
        
        return URLSession.shared.rx.data(request: request)
            .map { data in
                UIImage(data: data)
            }
    }
}
