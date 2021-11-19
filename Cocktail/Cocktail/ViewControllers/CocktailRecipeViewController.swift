import UIKit
import SnapKit

class CocktailRecipeViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var originRecipe: [Cocktail] = []
    var filteredRecipe: [Cocktail] = []
    
    
    //내가 클릭한 셀의 조건을 배열로 넘겨준다. 그배열에서 하나씩 필터함수를 forin 문으로 걸러준다.
    func baseFilter(condition: [Cocktail.Base], base: [Cocktail]) -> [Cocktail] {
            var filterviewRecipe: [Cocktail] = []
            for condi in condition {
                if isFiltering() {
                    filterviewRecipe.append(contentsOf: filteredRecipe.filter {
                        $0.base == condi
                    })
                } else {
                    filterviewRecipe.append(contentsOf: originRecipe.filter {
                        $0.base == condi
                    })
                }
            }
            return filterviewRecipe
        }
        
    
    
    let mainTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        layout()
        getRecipe(data: &originRecipe)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        title = "레시피 검색"
        view.backgroundColor = .systemCyan
        mainTableView.register(CocktailListCell.self, forCellReuseIdentifier: "key")
        originRecipe.sort {
            $0.name < $1.name
        }
        
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        //서치바의 텍스트가 변경되는것을 알려준다. 델리게이트 선언같은것 같음
        searchController.obscuresBackgroundDuringPresentation = false
        // 표시된 뷰를 흐리게 해주는것
        searchController.searchBar.placeholder = "이름, 재료, 기주, 잔, 색깔 등등"
        //뭐 그냥 플레이스홀더지뭐
        navigationItem.searchController = searchController
        //네비게이션바에 서치바 추가하는것
        definesPresentationContext = true
        //화면 이동시에 서치바가 안남아있게 해준대
        searchController.searchBar.keyboardType = .default
        //필터 버튼 추가하고싶은데..
        let filterButton = UIBarButtonItem(title: "필터", style: .plain, target: self, action: #selector(showFilterView))
        navigationItem.rightBarButtonItem = filterButton
        
    }
    
    @objc func showFilterView() {
        let filteredViewController = FilteredViewController()
        filteredViewController.modalPresentationStyle = .overCurrentContext
        filteredViewController.modalTransitionStyle = .crossDissolve
        filteredViewController.nowOn = true
//        self.definesPresentationContext = true
        navigationController?.present(filteredViewController, animated: true, completion: nil)
    }
    func layout() {
        mainTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func attribute() {
        view.addSubview(mainTableView)
    }
}

extension CocktailRecipeViewController: UITableViewDelegate, UITableViewDataSource {
    //테이블뷰에 관한것
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredRecipe.count
        }
        return originRecipe.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "key", for: indexPath) as? CocktailListCell else { return UITableViewCell() }
        if isFiltering() {
            cell.configure(data: filteredRecipe[indexPath.row])
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            cell.configure(data: originRecipe[indexPath.row])
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering() {
            let cocktailData = filteredRecipe[indexPath.row]
            let cocktailDetailViewController = CocktailDetailViewController()
            cocktailDetailViewController.setData(data: cocktailData)
            self.show(cocktailDetailViewController, sender: nil)
        } else {
            let cocktailData = originRecipe[indexPath.row]
            let cocktailDetailViewController = CocktailDetailViewController()
            cocktailDetailViewController.setData(data: cocktailData)
            self.show(cocktailDetailViewController, sender: nil)
        }
    }
}

extension CocktailRecipeViewController: UISearchResultsUpdating {
    //서치바에 관한것
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
        //서치바가 활성화 되어있는지, 그리고 서치바가 비어있지않은지
    }
    
    func searchBarIsEmpty() -> Bool {
        //서치바가 비어있는지 확인하는것
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        //만약 넘겨주는 데이터에 아무것도없다면 아래의 코드대로 작동하게 하기.일단 보류
        filteredRecipe = originRecipe.filter({
            return $0.name.contains(searchText) || $0.mytip.contains(searchText) || $0.ingredients.map({ baby in
                baby.rawValue
            })[0...].contains(searchText) || $0.glass.rawValue.contains(searchText) || $0.color.rawValue.contains(searchText) || $0.recipe.contains(searchText)
        })
        mainTableView.reloadData()
    }
}
