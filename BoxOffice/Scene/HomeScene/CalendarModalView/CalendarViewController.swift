//
//  CalendarViewController.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/04.
//

import UIKit

protocol CalendarViewControllerDelegate: AnyObject {
    func searchButtonTapped(date: Date) async throws
}

final class CalendarViewController: UIViewController {
    weak var delegate: CalendarViewControllerDelegate?
    private var customTransitioningDelegate = CalendarTransitioningDelegate()
    private let navigationBar = UINavigationBar(frame: .zero)
    private let boxOfficeMode: BoxOfficeMode
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.timeZone = .autoupdatingCurrent
        return datePicker
    }()
    
    init(viewMode: BoxOfficeMode) {
        self.boxOfficeMode = viewMode
        super.init(nibName: nil, bundle: nil)
        setupModalStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
        setupDatePicker()
        addSubviews()
        setupLayer()
        setupNavigationBar()
    }
    
    private func setupModalStyle() {
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = customTransitioningDelegate
    }
    
    private func setupInitialView() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    private func setupDatePicker() {
        switch boxOfficeMode {
        case .daily:
            datePicker.maximumDate = Date()
        case .weekly:
            datePicker.maximumDate = Date().previousDate(to: -7)
        }
    }
    
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        let naviItem = UINavigationItem(title: "날짜 선택")
        
        naviItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                     target: self,
                                                     action: #selector(closeButtonTapped))
        
        naviItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                      target: self,
                                                      action: #selector(searchButtonTapped))
        
        navigationBar.items = [naviItem]
    }
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func searchButtonTapped() {
        Task {
            try await delegate?.searchButtonTapped(date: datePicker.date)
        }
        
        self.dismiss(animated: true)
    }
}

// MARK: Setup Layout
private extension CalendarViewController {
    
    func addSubviews() {
        view.addSubview(navigationBar)
        view.addSubview(datePicker)
    }
    
    func setupLayer() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalTo: view.heightAnchor,
                                                  multiplier: 1/5),
            
            datePicker.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            datePicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}
