//
//  API.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02. -> Refacted by Judy on 2023/01/20.
//

import Foundation
import RxSwift

protocol API {
    associatedtype ResponseType: Decodable
    var configuration: MovieRequest { get }
}

extension API {
    func execute(using client: APIService = APIService.shared) -> Observable<ResponseType> {
        guard let urlRequest = configuration.urlRequest else {
            return Observable<ResponseType>.empty()
        }
        
        return client.requestData(with: urlRequest)
            .map { data in
                let result = try JSONDecoder().decode(ResponseType.self, from: data)
                return result
            }
    }
}
