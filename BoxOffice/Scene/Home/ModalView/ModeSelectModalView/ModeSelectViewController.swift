//
//  ModeSelectViewController.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/03.
//

import UIKit

protocol ModeSelectViewControllerDelegate: AnyObject {
    func didSelectedRowAt(indexPath: Int) async throws
}

final class ModeSelectViewController: UIViewController {
    weak var delegate: ModeSelectViewControllerDelegate?
    private let currentMode: BoxOfficeMode
    private let customTransitioningDelegate = ModeSelectTransitioningDelegate()
    
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar(frame: .zero)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.isTranslucent = false
        navigationBar.backgroundColor = .systemBackground
        return navigationBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.register(ModeSelectCell.self,
                           forCellReuseIdentifier: "modalCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(passMode: BoxOfficeMode) {
        self.currentMode = passMode
        super.init(nibName: nil, bundle: nil)
        setupModalStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupModalStyle() {
        modalPresentationStyle = .custom
        modalTransitionStyle = .coverVertical
        transitioningDelegate = customTransitioningDelegate
    }
    
    private func setupInitialView() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    private func setupNavigationBar() {
        let navigationItem = UINavigationItem(title: "보기 모드")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                     target: self,
                                                     action: #selector(dismissView))
        navigationBar.items = [navigationItem]
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = view.bounds.height / 15
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true)
    }
}

extension ModeSelectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return BoxOfficeMode.allCases.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "modalCell",
                                                       for: indexPath) as? ModeSelectCell else {
            return UITableViewCell(style: .default, reuseIdentifier: .none)
        }
        
        let mode = BoxOfficeMode.allCases[indexPath.row]
        
        cell.setup(label: mode.title, isChecked: currentMode == mode)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        Task {
            try await delegate?.didSelectedRowAt(indexPath: indexPath.row)
        }
        
        dismissView()
    }
}

// MARK: Setup Layout
extension ModeSelectViewController {
    private func setupView() {
        setupInitialView()
        setupNavigationBar()
        setupLayout()
        setupTableView()
    }
    
    private func setupLayout() {
        view.addSubview(navigationBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}
