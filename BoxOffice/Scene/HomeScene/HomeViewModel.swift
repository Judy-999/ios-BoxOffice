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
    func requestDailyData(with date: String, disposeBag: DisposeBag)
    func requestWeeklyDate(with date: String, disposeBag: DisposeBag)
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
            .subscribe(onNext: { [weak self] in
                self?.dailyMovieCellDatas.accept($0)},
                       onCompleted: { [weak self] in
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    func requestWeeklyDate(with date: String, disposeBag: DisposeBag) {
        let allWeek = movieAPIUseCase.requestAllWeekData(with: date)
        let weekend = movieAPIUseCase.requestWeekEndData(with: date)
        
        isLoading.accept(true)
        
        allWeek.subscribe(onNext: { [weak self] in
            self?.allWeekMovieCellDatas.accept($0)
        })
        .disposed(by: disposeBag)
        
        weekend.subscribe(onNext: { [weak self] in
            self?.weekEndMovieCellDatas.accept($0)
        })
        .disposed(by: disposeBag)
        
        Observable.zip(allWeek, weekend)
        .subscribe(onNext: { _, _ in
            self.isLoading.accept(false)
        })
        .disposed(by: disposeBag)
    }
}
