//
//  ReviewFirestoreUseCase.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/03.
//

import UIKit
import RxSwift
import FirebaseFirestore

final class ReviewFirebaseUseCase {
    private enum ReviewData {
        static let nickName = "nickName"
        static let password = "password"
        static let rating = "rating"
        static let content = "content"
        static let imageURL = "imageURL"
    }
    
    private let firestoreManager = FirestoreManager.shared
    
    func save(_ review: Review, at movie: String) -> Observable<Void> {
        let reviewData: [String: Any] = [
            ReviewData.nickName: review.nickName,
            ReviewData.password: review.password,
            ReviewData.rating: review.rating,
            ReviewData.content: review.content,
            ReviewData.imageURL: review.imageURL
        ]

        return firestoreManager.save(reviewData,
                                     at: movie,
                                     with: review.nickName + review.password)
    }

    func fetch(at movie: String) -> Observable<[Review]> {
        return firestoreManager.fetch(at: movie)
            .map {
                $0.compactMap { [weak self] in
                    self?.toReview(from: $0)
                }
            }
            .catchAndReturn([])
    }

    func delete(_ review: Review, at movie: String) -> Observable<Void> {
        return firestoreManager.delete(with: review.nickName + review.password,
                                       at: movie)
    }
}

extension ReviewFirebaseUseCase {
    private func toReview(from document: QueryDocumentSnapshot) -> Review? {
        guard let nickName = document[ReviewData.nickName] as? String,
              let password = document[ReviewData.password] as? String,
              let rating = document[ReviewData.rating] as? String,
              let content = document[ReviewData.content] as? String,
              let imageURL = document[ReviewData.imageURL] as? String else { return nil }
        
        return Review(nickName: nickName,
                      password: password,
                      rating: rating,
                      content: content,
                      imageURL: imageURL)
    }
}
