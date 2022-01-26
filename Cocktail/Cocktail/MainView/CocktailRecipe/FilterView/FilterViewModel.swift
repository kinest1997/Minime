//
//  FilterViewModel.swift
//  Cocktail
//
//  Created by 강희성 on 2022/01/21.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import Differentiator

struct FilterViewModel: FilterViewBindable {
    
    //viewModel -> view
    
    var cellData: Observable<[SectionOfFilterCell]>
    
    var showFilterView = PublishSubject<Void>()
    
    var dismissFilterView: Signal<Void>
    
    //viewModel -> SuperViewModel
    var conditionsOfCocktail: Observable<[FilteredView.FilterData]>
    
    // view -> viewModel
    
    var viewWillAppear = PublishSubject<Void>()
    
    var cellTapped = PublishRelay<IndexPath>()
    
    var closeButtonTapped = PublishRelay<Void>()
    
    var saveButtonTapped = PublishRelay<Void>()
    
    var resetButton = PublishRelay<Void>()
    
    //only here
    
    var selectedStatus = PublishSubject<[[(name: String, checked: Bool)]]>()
    
    let tappedData = PublishSubject<[FilteredView.FilterData]>()
    
    let disposeBag = DisposeBag()
    
    init(model: FilterModel = FilterModel()) {
        
        //리셋버튼이 탭될떄 그것을 다른 어떤 특별한 이벤트로 변경
        let resetButtonTapped = resetButton
            .map { _ in IndexPath(row: 20, section: 20)}
        
        //탭될때마다 조건을 합쳐준다, 만약 리셋버튼이 눌리면 모든조건을 초기화 해준다
        Observable.merge(cellTapped.asObservable(), resetButtonTapped)
            .scan(into: model.emptyconditionArray) {base, index in
                
                if index == IndexPath(row: 20, section: 20) {
                    base = model.emptyconditionArray
                } else {
                    if base[index.section].condition.contains(where: { condition in
                        condition.rawValue == base.map { $0.section }[index.section][index.row].rawValue
                    }){
                        guard let number = base[index.section].condition.firstIndex(where: { condition in
                            condition.rawValue == base.map { $0.section }[index.section][index.row].rawValue
                        }) else { return }
                        base[index.section].condition.remove(at: number)
                    } else {
                        base[index.section].condition.append(base.map { $0.section }[index.section][index.row])
                    }
                }
            }
            .bind(to: tappedData)
            .disposed(by: disposeBag)
        
        //저장버튼이 눌리거나, 리셋버튼이 눌릴때 그 조건을 상위 뷰에 전달해준다
        let sendDataSignal = Observable.merge(saveButtonTapped.asObservable(), resetButton.asObservable())
        
        conditionsOfCocktail = sendDataSignal.withLatestFrom(tappedData)

        //셀이 탭 되면 그 셀을 업데이트 해주고, 리셋버튼이 눌리면 스캔을 초기화 해준다
        Observable.merge(cellTapped.asObservable(), resetButtonTapped)
            .scan(into: [Cocktail.Alcohol.allCases.map {$0.rawValue}, Cocktail.Base.allCases.map {$0.rawValue}, Cocktail.DrinkType.allCases.map {$0.rawValue}, Cocktail.Craft.allCases.map {$0.rawValue}, Cocktail.Glass.allCases.map {$0.rawValue}, Cocktail.Color.allCases.map {$0.rawValue} ].map {
                $0.map { name in (name: name ,checked: false) }
            }) { data, index in
                if index == IndexPath(row: 20, section: 20) {
                    data = [Cocktail.Alcohol.allCases.map {$0.rawValue}, Cocktail.Base.allCases.map {$0.rawValue}, Cocktail.DrinkType.allCases.map {$0.rawValue}, Cocktail.Craft.allCases.map {$0.rawValue}, Cocktail.Glass.allCases.map {$0.rawValue}, Cocktail.Color.allCases.map {$0.rawValue} ].map {
                        $0.map { name in (name: name ,checked: false)}
                    }
                } else {
                    data[index.section][index.row].checked.toggle()
                }
            }
            .bind(to: selectedStatus)
            .disposed(by: disposeBag)
        
        //리셋, 닫기, 저장 버튼이 눌리면 필터뷰를 사라지게해준다
        dismissFilterView = Observable<Void>.merge(resetButton.asObservable(), closeButtonTapped.asObservable(), saveButtonTapped.asObservable())
            .asSignal(onErrorSignalWith: .empty())
        
        //셀은 리셋버튼이 눌리거나 뷰가 처음 나타날때, 셀이 탭되었을때 새로 그려진다
        
        let modifiedCellData = selectedStatus
            .map(model.modifiedFilterCellData)
            
        let defaultCellData = Observable.merge(resetButton.asObservable(), viewWillAppear)
            .map { _ -> [SectionOfFilterCell] in
                model.makeDefaultFilterData()
            }
        
        cellData = Observable.merge(defaultCellData, modifiedCellData)
    }
}

//셀이 탭 될때마다 해당셀의 이미지를 새로고침해준다

//리셋버튼, 또는 저장 버튼이 눌리면 칵테일 필터링 조건을 슈퍼뷰모델로 보내준다

//섹션에 들어가는 정보: 여기선 셀의 정보와 헤더의 이름

struct FilterCellData {
    var name: String
    var selected: Bool
}

struct SectionOfFilterCell {
    var header: String
    var items: [FilterCellData]
}

extension SectionOfFilterCell: SectionModelType {
    
    typealias Item = FilterCellData
    
    init(original: SectionOfFilterCell, items: [Item]) {
        self = original
        self.items = items
    }
}
