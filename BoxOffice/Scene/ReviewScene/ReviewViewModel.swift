//
//  WriteReviewViewModel.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/04.
//

import RxSwift
import RxRelay

protocol ReviewViewModelInput {
    func save(_ review: Review, at movieKey: String)
    func fetch(at movieKey: String)
}

protocol ReviewViewModelOutput {
    var reviews: BehaviorRelay<[Review]> { get set }
    var rating: PublishRelay<String> { get set }
    var error: PublishRelay<String> { get set }
}

protocol ReviewViewModelType: ReviewViewModelInput, ReviewViewModelOutput { }

final class MovieReviewViewModel: ReviewViewModelType {
    private let reviewFirebaseUseCase = ReviewFirebaseUseCase()
    
    /// Output
    var reviews = BehaviorRelay<[Review]>(value: [])
    var rating = PublishRelay<String>()
    var error = PublishRelay<String>()
    
    /// Input
    func save(_ review: Review, at movieKey: String) {
        reviewFirebaseUseCase.save(review, at: movieKey) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                self.error.accept(error.localizedDescription)
            }
        }
        
        fetch(at: movieKey)
    }
    
    func fetch(at movieKey: String) {
        reviewFirebaseUseCase.fetch(at: movieKey) { [weak self] result in
            switch result {
            case .success(let reviews):
                self?.reviews.accept(reviews)
                self?.calculateRating()
            case .failure(let error):
                self?.error.accept(error.localizedDescription)
            }
        }
    }
    
    func delete(_ review: Review, at movieKey: String) {
        reviewFirebaseUseCase.delete(review, at: movieKey) { [weak self] result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                self?.error.accept(error.localizedDescription)
            }
        }
        
        fetch(at: movieKey)
    }
    
    func calculateRating() {
        let ratings = reviews.value.map { $0.rating }
        let ratingValues = ratings.compactMap { Double($0) }
        let ratingSum = ratingValues.reduce(0, +)
        let result = String(format: "%.1f", ratingSum / Double(ratingValues.count))
        
        rating.accept(result)
    }
}

