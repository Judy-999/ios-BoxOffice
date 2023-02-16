//
//  HomeViewModel.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/04.
//

import Foundation

protocol HomeViewModelInput {
    func requestDailyData(with date: String) async throws
    func requestAllWeekData(with date: String) async throws
    func requestWeekEndData(with date: String) async throws
}

protocol HomeViewModelOutput {
    var dailyMovieCellDatas: Observable<[MovieData]> { get }
    var allWeekMovieCellDatas: Observable<[MovieData]> { get }
    var weekEndMovieCellDatas: Observable<[MovieData]> { get }
    var isLoading: Observable<Bool> { get set }
}

protocol HomeViewModelType: HomeViewModelInput, HomeViewModelOutput {}

final class HomeViewModel: HomeViewModelType {
    private let movieAPIUseCase = MovieAPIUseCase()
    
    var dailyMovieCellDatas = Observable<[MovieData]>([])
    var allWeekMovieCellDatas = Observable<[MovieData]>([])
    var weekEndMovieCellDatas = Observable<[MovieData]>([])
    var isLoading = Observable<Bool>(true)
    
    
    func requestDailyData(with date: String) async throws {
        isLoading.value = true
        try await movieAPIUseCase.requestDailyData(with: date,
                                                   in: dailyMovieCellDatas)
        isLoading.value = false
    }
    
    func requestAllWeekData(with date: String) async throws {
        isLoading.value = true
        try await movieAPIUseCase.requestAllWeekData(with: date,
                                                     in: allWeekMovieCellDatas)
        isLoading.value = false
    }
    
    func requestWeekEndData(with date: String) async throws {
        isLoading.value = true
        try await movieAPIUseCase.requestWeekEndData(with: date,
                                                     in: weekEndMovieCellDatas)
        isLoading.value = false
    }
}
