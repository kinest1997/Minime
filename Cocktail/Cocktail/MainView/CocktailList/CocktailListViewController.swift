import UIKit
import SnapKit
import Kingfisher

class CocktailListViewController: UIViewController {
    
    let mainCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var lastRecipe: [Cocktail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mainCollectionView)
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(CocktailListCollectionViewCell.self, forCellWithReuseIdentifier: "CocktailListCollectionViewCell")
        mainCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(15)
        }
        mainCollectionView.backgroundColor = .clear
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainCollectionView.reloadData()
    }
}

extension CocktailListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lastRecipe.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CocktailListCollectionViewCell", for: indexPath) as? CocktailListCollectionViewCell else { return UICollectionViewCell() }
        
        cell.configure(data: lastRecipe[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/2.2
        let yourHeight = collectionView.bounds.height/4
        return CGSize(width: yourWidth, height: yourHeight)
    }
}
