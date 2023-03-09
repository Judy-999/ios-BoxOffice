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
    var isLoading: BehaviorRelay<Bool> { get set }
}

protocol HomeViewModelType: HomeViewModelInput, HomeViewModelOutput {}

final class HomeViewModel: HomeViewModelType {
    private let movieRepository: BoxOfficeRepository
    private let posterRepository: PosterRepository
    
    var dailyMovieCellDatas = BehaviorRelay<[MovieData]>(value: [])
    var allWeekMovieCellDatas = BehaviorRelay<[MovieData]>(value:[])
    var weekEndMovieCellDatas = BehaviorRelay<[MovieData]>(value:[])
    var isLoading = BehaviorRelay<Bool>(value: true)
    
    init(movieRepository: BoxOfficeRepository,
         posterRepository: PosterRepository) {
        self.movieRepository = movieRepository
        self.posterRepository = posterRepository
    }
    
    func requestDailyData(with date: String, disposeBag: DisposeBag) {
        isLoading.accept(true)
        
        let dailyUseCase = DailyBoxOfficeUseCase(movieRepository,
                                                 posterRepository)
        dailyUseCase.execute(date: date)
            .subscribe(onNext: { [weak self] in
                self?.dailyMovieCellDatas.accept($0)},
                       onCompleted: { [weak self] in
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    func requestWeeklyDate(with date: String, disposeBag: DisposeBag) {
        isLoading.accept(true)
        
        let allWeek = WeeklyBoxOfficeUseCase(movieRepository,
                                             posterRepository)
            .execute(date: date)
        let weekend = WeekendBoxOfficeUseCase(movieRepository,
                                              posterRepository)
            .execute(date: date)
        
        Observable.zip(allWeek, weekend)
        .subscribe(onNext: { _, _ in
            self.isLoading.accept(false)
        })
        .disposed(by: disposeBag)
        
        allWeek
            .subscribe(onNext: { [weak self] in
                self?.allWeekMovieCellDatas.accept($0)
            })
            .disposed(by: disposeBag)
        
        weekend
            .subscribe(onNext: { [weak self] in
                self?.weekEndMovieCellDatas.accept($0)
            })
            .disposed(by: disposeBag)
        
       
    }
}
