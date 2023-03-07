//
//  API.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02. -> Refacted by Judy on 2023/01/20.
//

import Foundation
import RxSwift
import RxCocoa

protocol API {
    associatedtype ResponseType: Decodable
    var configuration: MovieRequest { get }
}

extension API {
    func execute(using cache: URLCacheManager = URLCacheManager.shared) -> Observable<ResponseType> {
        guard let urlRequest = configuration.urlRequest else {
            return Observable<ResponseType>.empty()
        }
        
        if let data = cache.getDataFromCache(with: urlRequest) {
            return Observable.just(data)
                .map {
                    return try JSONDecoder().decode(ResponseType.self, from: $0)
                }
        }
        
        return URLSession.shared.rx.response(request: urlRequest)
            .filter { response, data in
                200..<400 ~= response.statusCode
            }
            .do(onNext: { response, data in
                cache.saveDataInCache(with: urlRequest, response, data)
            })
            .map { _, data in
                return try JSONDecoder().decode(ResponseType.self, from: data)
            }
    }
}
