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
    func execute(using client: APIProvider = APIProvider.shared) -> Observable<ResponseType> {
        guard let urlRequest = configuration.urlRequest else {
            return Observable<ResponseType>.empty()
        }
        
        return client.requestData(with: urlRequest)
            .map { data in
                return try JSONDecoder().decode(ResponseType.self, from: data)
            }
    }
}
