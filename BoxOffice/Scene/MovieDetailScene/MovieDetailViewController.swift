//
//  MovieDetailViewController.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/04.
//

import UIKit
import RxSwift

final class MovieDetailViewController: UIViewController {
    private let entireStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let reviewTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ReviewTableViewCell.self,
                           forCellReuseIdentifier: ReviewTableViewCell.identifier)
        return tableView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = ReviewInfo.Phrase.emptyReview
        label.textAlignment = .center
        return label
    }()

    private lazy var movieReviewView = MovieReviewView(tableView: reviewTableView)
    private let movieMainInfoView = MovieMainInfoView()
    private let movieSubInfoView = MovieSubInfoView()
    private let reviewViewModel = MovieReviewViewModel()
    private let movieDetail: MovieData
    private let disposeBag = DisposeBag()
    
    init(movieDetail: MovieData) {
        self.movieDetail = movieDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadReview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationItem()
        bind()
    }
    
    private func loadReview() {
        let movieKey = movieDetail.title + movieDetail.openYear
        reviewViewModel.fetch(at: movieKey, bag: disposeBag)
    }
    
    private func bind() {
        reviewViewModel.reviews
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.reviewTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        reviewViewModel.rating
            .subscribe(onNext: { [self] rating in
                movieMainInfoView.configure(with: movieDetail,
                                            rating: rating)
            })
            .disposed(by: disposeBag)
        
        reviewViewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(message: error)
            })
            .disposed(by: disposeBag)
        
        reviewViewModel.reviews
            .map {
                !($0.isEmpty)
            }
            .asDriver(onErrorJustReturn: false)
            .drive(emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        reviewViewModel.reviews
            .map { reviews in
                return reviews.count > 3 ? Array(reviews[0..<3]) : reviews
            }
            .bind(to: reviewTableView.rx.items(cellIdentifier: ReviewTableViewCell.identifier,
                                               cellType: ReviewTableViewCell.self)) { index, item, cell in
                cell.configure(with: item)
                cell.addTargetDeleteButton(with: self,
                                           selector: #selector(self.reviewDeleteButtonTapped),
                                           tag: index)
            }.disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        reviewTableView.rowHeight = view.bounds.height * 0.1
        reviewTableView.backgroundView = emptyLabel
        reviewTableView.isScrollEnabled = false
        reviewTableView.allowsSelection = false
    }
}

//MARK: Setup View
extension MovieDetailViewController {
    private func setupView() {
        movieSubInfoView.configure(with: movieDetail)
        
        addSubView()
        setupTableView()
        setupConstraint()
        addTagetButton()
        view.backgroundColor = .systemBackground
    }
    
    private func addSubView() {
        entireStackView.addArrangedSubview(movieMainInfoView)
        entireStackView.addArrangedSubview(movieSubInfoView)
        entireStackView.addArrangedSubview(movieReviewView)
        
        view.addSubview(entireStackView)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            entireStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            entireStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            entireStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            entireStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            movieMainInfoView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor,
                                                      multiplier: 1/3),
            movieReviewView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor,
                                                    multiplier: 5/10)
        ])
    }
}

//MARK: Button Action
extension MovieDetailViewController {
    private func addTagetButton() {
        movieSubInfoView.addTargetMoreButton(with: self,
                                             selector: #selector(moreActorButtonTapped))
        movieReviewView.addTargetWriteButton(with: self,
                                             selector: #selector(writeReviewButtonTapped))
        movieReviewView.addTargetMoreButton(with: self,
                                            selector: #selector(moreReviewButtonTapped))
    }
    
    @objc private func moreActorButtonTapped() {
        let actorList = movieDetail.actors
        let actorListViewController = ActorListViewController(actorList: actorList)
        present(actorListViewController, animated: true)
    }
    
    @objc private func writeReviewButtonTapped() {
        let writeReviewViewController = WriteReviewViewController(movie: movieDetail)
        navigationController?.pushViewController(writeReviewViewController,
                                                 animated: true)
    }
    
    @objc private func moreReviewButtonTapped() {
        let reviewListViewController = ReviewListViewController(movie: movieDetail,
                                                                 viewModel: reviewViewModel)
        navigationController?.pushViewController(reviewListViewController,
                                                 animated: true)
    }
    
    @objc func reviewDeleteButtonTapped(button: UIButton) {
        let review = reviewViewModel.reviews.value[button.tag]
        let checkPasswordAlert = UIAlertController(title: ReviewInfo.Alert.delete,
                                                   message: ReviewInfo.Alert.enterPassword,
                                                   preferredStyle: .alert)
        checkPasswordAlert.addTextField()
        
        let confirmAction = UIAlertAction(title: ReviewInfo.Alert.ok, style: .default) { [self] _ in
            let inputPassword = checkPasswordAlert.textFields?.first?.text
            if inputPassword == review.password {
                reviewViewModel.delete(review,
                                       at: movieDetail.title + movieDetail.openYear,
                                       bag: disposeBag)
            } else {
                showAlert(title: ReviewInfo.Alert.deleteFailure,
                          message: ReviewInfo.Alert.inconsistency)
            }
        }
        
        checkPasswordAlert.addAction(confirmAction)
        checkPasswordAlert.addAction(UIAlertAction(title: ReviewInfo.Alert.cancle,
                                                   style: .cancel))
        present(checkPasswordAlert, animated: true)
    }
}

//MARK: Setup NavigationItem
extension MovieDetailViewController {
    private func setupNavigationItem() {
        let shareBarButton = UIBarButtonItem(image: BoxOfficeImage.share,
                                             style: .plain,
                                             target: self,
                                             action: #selector(shareButtonTapped))
        
        navigationItem.rightBarButtonItem = shareBarButton
        navigationItem.title = movieDetail.title
    }
    
    @objc private func shareButtonTapped() {
        let shareObject: [String] = convertMovieInfo()
        let activityViewController = UIActivityViewController(activityItems: shareObject,
                                                              applicationActivities: nil)
        
        present(activityViewController, animated: true)
    }
    
    private func convertMovieInfo() -> [String] {
        let movieInfo = [movieDetail.title,
                         movieDetail.openYear + " 개봉",
                         movieDetail.ageLimit,
                         movieDetail.currentRank + "위",
                         movieDetail.directorName,
                         movieDetail.actors.joined(separator: ","),
                         movieDetail.genreName,
                         movieDetail.isNewEntry ? "순위 진입" : "",
                         movieDetail.openDate,
                         movieDetail.rankChange + "단계 변동",
                         movieDetail.showTime + "분"
        ]
        
        return movieInfo
    }
}


