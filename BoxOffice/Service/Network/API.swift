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
    func execute() -> Observable<ResponseType> {
        guard let urlRequest = configuration.urlRequest else {
            return Observable<ResponseType>.empty()
        }
        
        return URLSession.shared.rx.data(request: urlRequest)
            .map { data in
                return try JSONDecoder().decode(ResponseType.self, from: data)
            }
    }
}
