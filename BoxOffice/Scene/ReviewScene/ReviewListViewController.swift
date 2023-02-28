//
//  ReviewListViewController.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/01/06.
//

import UIKit
import RxSwift

final class ReviewListViewController: UIViewController {
    private let reviewTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ReviewTableViewCell.self,
                           forCellReuseIdentifier: ReviewTableViewCell.identifier)
        return tableView
    }()
    
    private let reviewViewModel: MovieReviewViewModel
    private let movie: MovieData
    private let disposeBag = DisposeBag()
    
    init(movie: MovieData, viewModel: MovieReviewViewModel) {
        self.reviewViewModel = viewModel
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
        bind()
    }
    
    private func setupView() {
        navigationItem.title = movie.title
        view.backgroundColor = .systemBackground
        view.addSubview(reviewTableView)
        
        NSLayoutConstraint.activate([
            reviewTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                     constant: 8),
            reviewTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -8),
            reviewTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                     constant: 16),
            reviewTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: -16)
        ])
    }
    
    private func bind() {
        reviewViewModel.reviews
            .bind(to: reviewTableView.rx.items(cellIdentifier: ReviewTableViewCell.identifier,
                                               cellType: ReviewTableViewCell.self)) { index, item, cell in
                cell.configure(with: item)
                cell.addTargetDeleteButton(with: self,
                                           selector: #selector(self.reviewDeleteButtonTapped),
                                           tag: index)
            }.disposed(by: disposeBag)
        
        reviewViewModel.reviews
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.reviewTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        reviewViewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(message: error)
            })
            .disposed(by: disposeBag)
    }
}

//MARK: Review TableView
extension ReviewListViewController {
    private func setupTableView() {
        reviewTableView.rowHeight = view.bounds.height * 0.1
        reviewTableView.allowsSelection = false
    }

    @objc private func reviewDeleteButtonTapped(button: UIButton) {
        let review = reviewViewModel.reviews.value[button.tag]
        let checkPasswordAlert = UIAlertController(title: ReviewInfo.Alert.delete,
                                                   message: ReviewInfo.Alert.enterPassword,
                                                   preferredStyle: .alert)
        checkPasswordAlert.addTextField()
        
        let confirmAction = UIAlertAction(title: ReviewInfo.Alert.ok, style: .default) { [self] _ in
            let inputPassword = checkPasswordAlert.textFields?.first?.text
            if inputPassword == review.password {
                reviewViewModel.delete(review,
                                       at: movie.title + movie.openYear,
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
