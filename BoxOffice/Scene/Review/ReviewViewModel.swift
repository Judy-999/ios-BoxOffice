//
//  WriteReviewViewModel.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/04.
//

import RxSwift
import RxRelay

protocol ReviewViewModelInput {
    func save(_ review: Review, at movieKey: String, bag: DisposeBag)
    func fetch(at movieKey: String, bag: DisposeBag)
    func delete(_ review: Review, at movieKey: String, bag: DisposeBag)
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
    func save(_ review: Review, at movieKey: String, bag: DisposeBag) {
        reviewFirebaseUseCase.save(review, at: movieKey)
            .subscribe(onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: bag)
        
        fetch(at: movieKey, bag: bag)
    }
    
    func fetch(at movieKey: String, bag: DisposeBag) {
        reviewFirebaseUseCase.fetch(at: movieKey)
            .subscribe(onNext: { [weak self] reviews in
                self?.reviews.accept(reviews)
                self?.calculateRating(bag: bag)
            }, onError: { [weak self]  error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    func delete(_ review: Review, at movieKey: String, bag: DisposeBag) {
        reviewFirebaseUseCase.delete(review, at: movieKey)
            .subscribe(onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: bag)
        
        fetch(at: movieKey, bag: bag)
    }
    
    private func calculateRating(bag: DisposeBag) {
        reviews
            .map { reviews in
                reviews.compactMap { review in
                    Double(review.rating)
                }
            }
            .map { ratings in
                ratings.reduce(Double.zero, +) / Double(ratings.count)
            }
            .map {
                String(format: "%.1f", $0)
            }
            .bind(to: rating)
            .disposed(by: bag)
    }
}

