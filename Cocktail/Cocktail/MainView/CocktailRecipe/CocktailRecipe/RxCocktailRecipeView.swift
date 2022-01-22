//
//  RxCocktailRecipeView.swift
//  Cocktail
//
//  Created by 강희성 on 2022/01/21.
//

import UIKit
import RxAppState
import RxCocoa
import RxSwift
import SnapKit

protocol CocktailRecpeViewBindable {
    //    view -> ViewModel
    var filterButtonTapped: PublishRelay<Void> { get }
    var arrangeButtonTapped: PublishRelay<Void> { get }
//    var showLoadingView: PublishRelay<Void> { get }
    var filterRecipe: PublishSubject<SortingStandard> { get }
    var viewWillAppear:PublishSubject<Void> { get }
    
    //    viewModel -> view
    var sortedRecipe: Driver<[Cocktail]> { get }
    var showFilterView: Signal<Void> { get }
    var dismissLoadingView: Signal<Void> { get }
    
    //viewModel
    var filterviewModel: FilterViewBindable { get }
    var searchController: SearchControllerBindble { get }
}

class CocktailRecipeViewController: UIViewController {
    
    let loadingView = LoadingView()
    
    let filterView = FilteredView()
    
    let searchBar = SearchController()
    
    let tableView = UITableView()
    
    let filterButton = UIBarButtonItem(title: "Filter".localized, style: .plain, target: nil, action: nil)
    
    var leftarrangeButton: UIBarButtonItem { UIBarButtonItem(title: "Sorting".localized, image: nil, primaryAction: nil, menu: filterMenu) }
//
//
    var filterMenu: UIMenu {
        return UIMenu(title: "", image: nil, identifier: nil, options: .singleSelection, children: filtertMenuItems)
    }
    
    let disposeBag = DisposeBag()
    
    var filterOption = PublishSubject<SortingStandard>()
    
    var filtertMenuItems: [UIAction] {
        return [
            UIAction(title: "Name".localized, state: .on, handler: {[weak self] _ in
                guard let self = self else { return }
                let someObservable = Observable.just(SortingStandard.name)
                someObservable.bind(to: self.filterOption)
                    .disposed(by: self.disposeBag)
            })
        ]
    }
    
    //메뉴를 선택할때마다 특정값을 바꾼다. 그값을 옵저빙 하는것을 넘겨준다.

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        attribute()
        tableView.register(CocktailListCell.self, forCellReuseIdentifier: "CocktailListCell")
    }
    
    func bind(_ viewModel: CocktailRecpeViewBindable) {
        self.filterButton.rx.tap
            .bind(to: viewModel.filterButtonTapped)
            .disposed(by: disposeBag)
        
        self.leftarrangeButton.rx.tap
            .bind(to: viewModel.arrangeButtonTapped)
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .map { _ in Void() }
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
     
        self.filterOption
            .bind(to: viewModel.filterRecipe)
            .disposed(by: disposeBag)
        
        viewModel.showFilterView
            .emit {[weak self] _ in
                self?.filterView.isHidden = !(self?.filterView.isHidden)!
            }
            .disposed(by: disposeBag)
        
        viewModel.dismissLoadingView
            .emit {[weak self] _ in
                self?.loadingView.isHidden = true
            }
            .disposed(by: disposeBag)
        
        viewModel.sortedRecipe
            .drive(self.tableView.rx.items(cellIdentifier: "CocktailListCell", cellType: CocktailListCell.self)) { int, cocktail, cell in
                cell.configure(data: cocktail)
            }
            .disposed(by: disposeBag)
    }
    
    func layout() {
        navigationController?.view.addSubview(filterView)
        [tableView, loadingView].forEach { view.addSubview($0) }
        [tableView, loadingView, filterView].forEach { $0.snp.makeConstraints { $0.edges.equalToSuperview()} }
        
        navigationItem.searchController = searchBar
        
        tableView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func attribute() {
        title = "Recipe".localized
        tableView.backgroundColor = .white
        filterView.isHidden = true
        loadingView.isHidden = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItem = filterButton
        navigationItem.leftBarButtonItem = leftarrangeButton
    }
}
