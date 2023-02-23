//
//  ReviewFirestoreUseCase.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/03.
//

import UIKit
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
    
    func save(_ review: Review,
              at movie: String,
              completion: @escaping (Result<Void, FirebaseError>) -> Void) {
        let reviewData: [String: Any] = [
            ReviewData.nickName: review.nickName,
            ReviewData.password: review.password,
            ReviewData.rating: review.rating,
            ReviewData.content: review.content,
            ReviewData.imageURL: review.imageURL
        ]

        firestoreManager.save(reviewData,
                              at: movie,
                              with: review.nickName + review.password,
                              completion: completion)
    }

    func fetch(at movie: String,
               completion: @escaping (Result<[Review], FirebaseError>) -> Void) {
        firestoreManager.fetch(at: movie) { [weak self] result in
            switch result {
            case .success(let documents):
                let reviews = documents.compactMap {
                    return self?.toReview(from: $0)
                }
                
                completion(.success(reviews))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func delete(_ review: Review,
                at movie: String,
                completion: @escaping (Result<Void, FirebaseError>) -> Void) {
        firestoreManager.delete(with: review.nickName + review.password,
                                at: movie,
                                completion: completion)
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
