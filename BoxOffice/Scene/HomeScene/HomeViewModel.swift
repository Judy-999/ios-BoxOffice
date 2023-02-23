//
//  HomeViewModel.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/04.
//

import Foundation
import RxSwift
import RxRelay

protocol HomeViewModelInput {
    func requestDailyData(with date: String, disposeBag: DisposeBag) async throws
    func requestAllWeekData(with date: String, disposeBag: DisposeBag) async throws
    func requestWeekEndData(with date: String, disposeBag: DisposeBag) async throws
}

protocol HomeViewModelOutput {
    var dailyMovieCellDatas: BehaviorRelay<[MovieData]> { get }
    var allWeekMovieCellDatas: BehaviorRelay<[MovieData]> { get }
    var weekEndMovieCellDatas: BehaviorRelay<[MovieData]> { get }
    var isLoading: PublishRelay<Bool> { get set }
}

protocol HomeViewModelType: HomeViewModelInput, HomeViewModelOutput {}

final class HomeViewModel: HomeViewModelType {
    private let movieAPIUseCase = MovieAPIUseCase()
    
    var dailyMovieCellDatas = BehaviorRelay<[MovieData]>(value: [])
    var allWeekMovieCellDatas = BehaviorRelay<[MovieData]>(value:[])
    var weekEndMovieCellDatas = BehaviorRelay<[MovieData]>(value:[])
    var isLoading = PublishRelay<Bool>()
    
    
    func requestDailyData(with date: String, disposeBag: DisposeBag) {
        isLoading.accept(true)
        movieAPIUseCase.requestDailyData(with: date)
            .subscribe(onNext: {
                self.dailyMovieCellDatas.accept($0)
                self.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    func requestAllWeekData(with date: String, disposeBag: DisposeBag) {
        isLoading.accept(true)
        movieAPIUseCase.requestAllWeekData(with: date)
            .subscribe(onNext: {
                self.dailyMovieCellDatas.accept($0)
                self.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    func requestWeekEndData(with date: String, disposeBag: DisposeBag) {
        isLoading.accept(true)
        movieAPIUseCase.requestWeekEndData(with: date)
            .subscribe(onNext: {
                self.dailyMovieCellDatas.accept($0)
                self.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
}
