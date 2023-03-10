//
//  HomeViewController.swift
//  BoxOffice
//
//  Created by kjs on 2022/10/14.
//

import UIKit
import RxSwift

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
    private lazy var homeCollectionView = HomeCollectionView(searchDate: searchingDate)
    private let homeViewModel: HomeViewModelType
    private var searchingDate: Date = Date().previousDate(to: -7)
    private var viewMode: BoxOfficeMode = .daily
    private let disposeBag = DisposeBag()
    
    private let viewModeChangeButton: UIButton = {
        let button = MoviewButton(title: " ▼ " + BoxOfficeMode.daily.title)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
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
    
    init(_ viewModel :HomeViewModelType) {
        self.homeViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestInitialData()
        setupView()
        bind()
    }
    
    private func setupView() {
        setupInitialView()
        setupNavigationBar()
        setupCollectionView()
    }
    
    private func setupInitialView() {
        view.backgroundColor = .systemBackground
        addSubviews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        let calendarBarButton = UIBarButtonItem(image: BoxOfficeImage.calendar,
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
    
    private func bind() {
        homeViewModel.dailyMovieCellDatas
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] cellDatas in
                self?.homeCollectionView.appendDailySnapshot(with: cellDatas)
            })
            .disposed(by: disposeBag)

        Observable.zip(homeViewModel.allWeekMovieCellDatas,
                       homeViewModel.weekEndMovieCellDatas)
        .subscribe(onNext: { [weak self] allWeek, weekEnd in
            self?.homeCollectionView.appendWeekSnapshot(allWeek: allWeek,
                                                        weekEnd: weekEnd)
        })
        .disposed(by: disposeBag)
        
        homeViewModel.isLoading
            .asDriver(onErrorJustReturn: false)
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModeChangeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModeChangeButtonTapped()
            })
            .disposed(by: disposeBag)
    }
    
    private func requestInitialData() {
        homeViewModel.requestDailyData(with: searchingDate.toString(),
                                                 disposeBag: disposeBag)
    }
    
    private func viewModeChangeButtonTapped() {
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
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
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
        let tappedCellData = cellDatas[index]
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
    func didSelectedRowAt(indexPath: Int) {
        guard let mode = BoxOfficeMode(rawValue: indexPath) else { return }
        
        viewMode = mode
        viewModeChangeButton.setTitle(" ▼ \(mode.title)", for: .normal)
        
        let dateText = searchingDate.toString()
        
        switch viewMode {
        case .daily:
            homeCollectionView.switchMode(.daily)
            homeViewModel.requestDailyData(with: dateText,
                                           disposeBag: disposeBag)
        case .weekly:
            homeCollectionView.switchMode(.weekly)
            homeViewModel.requestWeeklyDate(with: dateText,
                                            disposeBag: disposeBag)
        }
    }
}

// MARK: CalendarView Delegate
extension HomeViewController: CalendarViewControllerDelegate {
    func searchButtonTapped(date: Date) {
        searchingDate = date
        homeCollectionView.updateDate(date)
        
        let dateText = date.toString()
        self.homeCollectionView.switchMode(viewMode)
        
        switch viewMode {
        case .daily:
            homeViewModel.requestDailyData(with: dateText,
                                           disposeBag: disposeBag)
        case .weekly:
            homeViewModel.requestWeeklyDate(with: dateText,
                                            disposeBag: disposeBag)
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
}
