//
//  HomeViewController.swift
//  BoxOffice
//
//  Created by kjs on 2022/10/14.
//

import UIKit

enum BoxOfficeMode: Int, CaseIterable {
    case daily
    case weekly
    
    var title: String {
        switch self {
        case .daily:
            return  "일별 박스오피스"
        case .weekly:
            return "주간/주말 박스오피스"
        }
    }
}

final class HomeViewController: UIViewController {
    private let homeCollectionView = HomeCollectionView()
    private let homeViewModel = HomeViewModel()
    private var searchingDate: Date = Date().previousDate(to: -7)
    private var viewMode: BoxOfficeMode = .daily
    
    private let viewModeChangeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(" ▼ " + BoxOfficeMode.daily.title, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemGray5
        button.contentHorizontalAlignment = .left
        return button
    }()

    lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.tintColor = .systemBlue
        indicator.hidesWhenStopped = true
        indicator.frame = view.frame
        return indicator
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            try await requestInitialData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }
    
    private func setupView() {
        setupInitialView()
        setupNavigationBar()
        setupCollectionView()
        setupButton()
    }
    
    private func setupInitialView() {
        view.backgroundColor = .systemBackground
        addSubviews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        let calendarBarButton = UIBarButtonItem(image: MovieInformation.Image.calendar,
                                             style: .done,
                                             target: self,
                                             action: #selector(calendarButtonTapped))
        
        navigationItem.rightBarButtonItem = calendarBarButton
        navigationItem.title = MovieInformation.mainviewTitle
    }
    
    private func setupCollectionView() {
        homeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        homeCollectionView.delegate = self
        homeCollectionView.register(HeaderView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: "headerView")
    }
    
    private func setupButton() {
        viewModeChangeButton.addTarget(self,
                                       action: #selector(viewModeChangeButtonTapped),
                                       for: .touchUpInside)
    }
    
    private func bind() {
        homeViewModel.dailyMovieCellDatas
            .bind { [weak self] cellDatas in
                let rankSortedCellDatas = cellDatas.sorted {
                    Int($0.currentRank) ?? 0 < Int($1.currentRank) ?? 0
                }
                
                DispatchQueue.main.async {
                    self?.homeCollectionView.appendDailySnapshot(with: rankSortedCellDatas)
                }
            }
        
        homeViewModel.allWeekMovieCellDatas
            .bind { [weak self] cellDatas in
                let rankSortedCellDatas = cellDatas.sorted {
                    Int($0.currentRank) ?? 0 < Int($1.currentRank) ?? 0
                }
                
                DispatchQueue.main.async {
                    self?.homeCollectionView.appendAllWeekSnapshot(data: rankSortedCellDatas)
                }
            }
        
        homeViewModel.weekEndMovieCellDatas
            .bind { [weak self] cellDatas in
                let rankSortedCellDatas = cellDatas.sorted {
                    Int($0.currentRank) ?? 0 < Int($1.currentRank) ?? 0
                }
                
                DispatchQueue.main.async {
                    self?.homeCollectionView.appendWeekEndSnapshot(data: rankSortedCellDatas)
                }
            }
        
        homeViewModel.isLoading
            .bind { [weak self] isLoading in
                DispatchQueue.main.async {
                    isLoading ?
                    self?.indicatorView.startAnimating() : self?.indicatorView.stopAnimating()
                }
            }
        
        homeCollectionView.currentDate = searchingDate.toString()
    }
    
    private func requestInitialData() async throws {
        try await homeViewModel.requestDailyData(with: searchingDate.toString())
    }
    
    @objc private func viewModeChangeButtonTapped() {
        let modeSelectViewController = ModeSelectViewController(passMode: viewMode)
        modeSelectViewController.delegate = self
        
        present(modeSelectViewController, animated: true)
    }
    
    @objc private func calendarButtonTapped() {
        let calendarViewController = CalendarViewController(viewMode: viewMode)
        calendarViewController.delegate = self
        calendarViewController.datePicker.date = searchingDate
        
        present(calendarViewController, animated: true)
    }
}

// MARK: CollectionView Delegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewMode {
        case .daily:
            pushMovieDetail(
                in: homeViewModel.dailyMovieCellDatas.value,
                at: indexPath.row
            )
        case .weekly:
            if indexPath.section == 0 {
                pushMovieDetail(
                    in: homeViewModel.allWeekMovieCellDatas.value,
                    at: indexPath.row
                )
            } else {
                pushMovieDetail(
                    in: homeViewModel.weekEndMovieCellDatas.value,
                    at: indexPath.row
                )
            }
        }
    }
    
    private func pushMovieDetail(in cellDatas: [MovieData], at index: Int) {
        let rankSortedCellDatas = cellDatas.sorted {
            Int($0.currentRank) ?? 0 < Int($1.currentRank) ?? 0
        }
        let tappedCellData = rankSortedCellDatas[index]
        let movieDetailViewController = MovieDetailViewController(movieDetail: tappedCellData)
        navigationController?.pushViewController(movieDetailViewController, animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height / 10
        return CGSize(width: width, height: height)
    }
}

// MARK: ModalView Delegate
extension HomeViewController: ModeSelectViewControllerDelegate {
    func didSelectedRowAt(indexPath: Int) async throws {
        guard let mode = BoxOfficeMode(rawValue: indexPath) else { return }
        
        viewMode = mode
        viewModeChangeButton.setTitle("▼ \(mode.title)", for: .normal)
        
        let dateText = searchingDate.toString()
        
        switch viewMode {
        case .daily:
            homeCollectionView.switchMode(.daily)
            try await homeViewModel.requestDailyData(with: dateText)
        case .weekly:
            homeCollectionView.switchMode(.weekly)
            Task {
                try await homeViewModel.requestAllWeekData(with: dateText)
            }
            Task {
                try await homeViewModel.requestWeekEndData(with: dateText)
            }
        }
    }
}

// MARK: CalendarView Delegate
extension HomeViewController: CalendarViewControllerDelegate {
    func searchButtonTapped(date: Date) async throws {
        searchingDate = date
        let dateText = date.toString()
        homeCollectionView.currentDate = dateText
        
        switch viewMode {
        case .daily:
            self.homeCollectionView.switchMode(.daily)
            try await homeViewModel.requestDailyData(with: dateText)
        case .weekly:
            self.homeCollectionView.switchMode(.weekly)
            
            Task {
                try await homeViewModel.requestAllWeekData(with: dateText)
            }
            Task {
                try await homeViewModel.requestWeekEndData(with: dateText)
            }
        }
    }
}

// MARK: Setup Layout
private extension HomeViewController {
    func addSubviews() {
        view.addSubview(homeCollectionView)
        view.addSubview(viewModeChangeButton)
        view.addSubview(indicatorView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            viewModeChangeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewModeChangeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            viewModeChangeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            viewModeChangeButton.heightAnchor.constraint(equalToConstant: 30),
            
            homeCollectionView.topAnchor.constraint(equalTo: viewModeChangeButton.bottomAnchor),
            homeCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            homeCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            homeCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}


enum MovieInformation {
    static let mainviewTitle = "영화목록"
    static let dailyBoxOfficeTitle = "▼ 일별 박스오피스"
    
    enum Image {
        static let calendar =  UIImage(systemName: "calendar")
    }
}
