//
//  APIClient.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02. -> Refacted by Judy on 2023/01/20.
//

import Foundation
import RxSwift
import RxCocoa

final class APIProvider {
    static let shared = APIProvider(sesseion: URLSession.shared)
    private let session: URLSession
    
    private init(sesseion: URLSession) {
        self.session = sesseion
    }
    
    func requestData(with urlRequest: URLRequest) -> Observable<Data> {
        return URLSession.shared.rx.response(request: urlRequest)
            .filter { response, data in
                200..<300 ~= response.statusCode
            }
            .map { _, data -> Data in
                return data
            }
    }
}
