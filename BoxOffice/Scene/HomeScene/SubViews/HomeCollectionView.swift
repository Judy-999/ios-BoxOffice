//
//  HomeCollectionView.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/03.
//

import UIKit

final class HomeCollectionView: UICollectionView {
    private enum Section: String, CaseIterable {
        case allWeek = "주간 박스오피스"
        case weekEnd = "주말 박스오피스"
        case main
    }
    
    private var currentDate: String
    private var currentViewMode: BoxOfficeMode = .daily
    private var homeDataSource: UICollectionViewDiffableDataSource<Section, MovieData>?
    private var snapshot = NSDiffableDataSourceSnapshot<Section, MovieData>()
    
    init(searchDate: Date) {
        currentDate = searchDate.toString()
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        configureHierachy()
        configureDataSource(with: createDailyCellRegistration())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func appendDailySnapshot(with cellDatas: [MovieData]) {
        guard cellDatas.count == 10 else { return }
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        snapshot.appendItems(cellDatas)
        homeDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func appendAllWeekSnapshot(data: [MovieData]) {
        guard data.count == 10 else { return }
        snapshot.appendItems(data, toSection: .allWeek)
        homeDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func appendWeekEndSnapshot(data: [MovieData]) {
        guard data.count == 10 else { return }
        snapshot.appendItems(data, toSection: .weekEnd)
        homeDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func updateDate(_ date: Date) {
        currentDate = date.toString()
    }
    
    func switchMode(_ mode: BoxOfficeMode){
        currentViewMode = mode
        setCollectionViewLayout(createLayout(for: mode), animated: true)
        
        switch mode {
        case .daily:
            configureDataSource(with: createDailyCellRegistration())
        case .weekly:
            configureDataSource(with: createWeeklyCellRegistration())
        }
    }
    
    private func configureHierachy() {
        collectionViewLayout = createLayout(for: currentViewMode)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func createLayout(for mode: BoxOfficeMode) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: .zero,
                                                     leading: 10,
                                                     bottom: .zero,
                                                     trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(mode.layoutWidth),
                                               heightDimension: .fractionalHeight(mode.layoutHeight))
       
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        if mode == .weekly {
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        }
        
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(50))

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize,
                                                                        elementKind: "headerView",
                                                                        alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
  
    private func configureDataSource<T: UICollectionViewCell>(
        with cellRegistration: UICollectionView.CellRegistration<T, MovieData>
    ) {
        let headerRegistration = createHeaderRegistration()
        homeDataSource = createDataSource(with: cellRegistration)
        
        homeDataSource?.supplementaryViewProvider = { (view, kind, index) in
            return self.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }
        
        snapshot.deleteAllItems()
        
        switch currentViewMode {
        case .daily:
            snapshot.appendSections([.main])
        case .weekly:
            snapshot.appendSections([.allWeek, .weekEnd])
        }
        
        homeDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<HeaderView> {
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderView>(elementKind: "headerView") { [self]
            (supplementaryView, elementKind, indexPath) in
            switch self.currentViewMode {
            case .daily:
                supplementaryView.sectionHeaderlabel.text = currentDate.toHearderDateFormat()
            case .weekly:
                supplementaryView.sectionHeaderlabel.text = Section.allCases[indexPath.section].rawValue
            }
        }
        return headerRegistration
    }
    
    private func createDailyCellRegistration() -> UICollectionView.CellRegistration<ListCell, MovieData> {
        let cellRegistration = UICollectionView.CellRegistration<ListCell, MovieData> { (cell, _, item) in
            cell.setup(with: item)
        }
        return cellRegistration
    }
    
    private func createWeeklyCellRegistration() -> UICollectionView.CellRegistration<GridCell, MovieData> {
        let cellRegistration = UICollectionView.CellRegistration<GridCell, MovieData> { (cell, _, item) in
            cell.setup(with: item)
        }
        return cellRegistration
    }
    
    private func createDataSource<T: UICollectionViewCell>(
        with cellRegistration: UICollectionView.CellRegistration<T, MovieData>
    ) -> UICollectionViewDiffableDataSource<Section, MovieData>? {
        let dataSource = UICollectionViewDiffableDataSource<Section, MovieData>(collectionView: self) {
            collectionView, indexPath, itemIdentifier -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: itemIdentifier)
        }
        return dataSource
    }
}

fileprivate extension BoxOfficeMode {
    var layoutWidth: CGFloat {
        switch self {
        case .daily:
            return 1.0
        case .weekly:
            return 0.45
        }
    }
    
    var layoutHeight: CGFloat {
        switch self {
        case .daily:
            return 0.25
        case .weekly:
            return 0.42
        }
    }
}
