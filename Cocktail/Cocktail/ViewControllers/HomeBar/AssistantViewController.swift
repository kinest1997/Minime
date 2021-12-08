import UIKit
import SnapKit
import FirebaseAuth

class AssistantViewController: UIViewController {
    
    let myRecipeButton = UIButton()
    let myBarButton = UIButton()
    let wishListButton = UIButton()
    let mainStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        layout()
    }
    
    func attribute() {
        myRecipeButton.addAction(UIAction(handler: {[weak self] _ in
            if Auth.auth().currentUser?.uid == nil {
                self?.pleaseLoginAlert()
            } else {
                let myOwnCocktailRecipeViewController = MyOwnCocktailRecipeViewController()
                self?.show(myOwnCocktailRecipeViewController, sender: nil)
            }
        }), for: .touchUpInside)
        
        myBarButton.addAction(UIAction(handler: {[weak self] _ in
            let homeBarViewController = MyDrinksViewController()
            self?.show(homeBarViewController, sender: nil)
        }), for: .touchUpInside)
        wishListButton.addAction(UIAction(handler: {[weak self] _ in
            if Auth.auth().currentUser?.uid == nil {
                self?.pleaseLoginAlert()
            } else {
                let wishListCocktailListTableView = WishListCocktailListTableView()
                self?.show(wishListCocktailListTableView, sender: nil)
            }
            
        }), for: .touchUpInside)
        
        myRecipeButton.backgroundColor = .blue
        myRecipeButton.setTitle("My Recipes".localized, for: .normal)
        myBarButton.backgroundColor = .red
        myBarButton.setTitle("My Drinks".localized, for: .normal)
        wishListButton.setTitle("Bookmark".localized, for: .normal)
        wishListButton.backgroundColor = .systemPink
    }
    
    func layout() {
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(myRecipeButton)
        mainStackView.addArrangedSubview(myBarButton)
        mainStackView.addArrangedSubview(wishListButton)
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(300)
        }
    }
    
    func pleaseLoginAlert() {
        let alert = UIAlertController(title: "로그인시에 사용가능합니다".localized, message: "로그인은 설정에서 할수있습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인".localized, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
