import UIKit
import SnapKit
import Kingfisher
import FirebaseDatabase
import FirebaseAuth

final class CocktailDetailViewController: ViewController {
    
    var cocktailData: Cocktail = Cocktail(name: "", craft: .blending, glass: .collins, recipe: [], ingredients: [], base: .assets, alcohol: .low, color: .various, mytip: "", drinkType: .longDrink, myRecipe: false, wishList: false, imageURL: "")
    
    var likeData: [String: Bool] = [:] {
        didSet {
            if likeData.contains(where: { (key: String, value: Bool) in
                key == Auth.auth().currentUser?.uid
            }) {
                switch likeData[Auth.auth().currentUser!.uid] {
                case true:
                    iLike = true
                case false:
                    iLike = false
                default:
                    return
                }
            }
            
            let likeCount = FirebaseRecipe.shared.likeOrDislikeCount(cocktailList: likeData, choice: true)
            DispatchQueue.main.async { [weak self] in
                self?.likeCountLabel.text = String(likeCount)
            }
            
            let dislikeCount = FirebaseRecipe.shared.likeOrDislikeCount(cocktailList: likeData, choice: false)
            DispatchQueue.main.async {[weak self] in
                self?.disLikeCountLabel.text = String(dislikeCount)
                self?.stopLoading()
            }
        }
    }
    
    var iLike: Bool? {
        didSet {
            switch iLike {
            case true:
                DispatchQueue.main.async { [weak self] in
                    self?.likeButton.setBackgroundImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                    self?.disLikeButton.setBackgroundImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
                }
            case false:
                DispatchQueue.main.async { [weak self] in
                    self?.disLikeButton.setBackgroundImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
                    self?.likeButton.setBackgroundImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                }
            case nil:
                DispatchQueue.main.async { [weak self] in
                    self?.disLikeButton.setBackgroundImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
                    self?.likeButton.setBackgroundImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                }
            default:
                return
            }
        }
    }
    
    private let mainScrollView = UIScrollView()
    private let mainView = UIView()
    private let popUpView = PopUpView()
    
    private let wishListButton = UIButton()
    
    private let cocktailImageView = UIImageView()
    private let imageSplitLine = UILabel()
    private let nameLabel = UILabel()
    private let alcoholSplitLine = UILabel()
    
    private let alcoholGuideLabel = UILabel()
    private let alcoholStackView = UIStackView()
    private let lowAlcoholLabel = UIImageView(image: UIImage(systemName: "circle.fill"))
    private let midAlcoholLabel = UIImageView(image: UIImage(systemName: "circle.fill"))
    private let highAlcoholLabel = UIImageView(image: UIImage(systemName: "circle.fill"))
    private let alcoholLabel = UILabel()
    
    private let leftStackView = UIStackView()
    private let centerLine = UIView()
    private let rightStackView = UIStackView()
    private let groupStackView = UIStackView()
    
    private let colorGuideLabel = UILabel()
    private let colorLabel = UILabel()
    
    private let baseDrinkGuideLabel = UILabel()
    private let baseDrinkLabel = UILabel()
    
    private let glassGuideLabel = UILabel()
    private let glassLabel = UILabel()
    
    private let craftGuideLabel = UILabel()
    private let craftLabel = UILabel()
    
    private let drinkTypeLabel = UILabel()
    private let drinkTypeGuideLabel = UILabel()
    
    private let myTipLabel = UILabel()
    
    private let firstSplitLine = UILabel()
    private let ingredientsGuideLabel = UILabel()
    private let ingredientsLabel = UILabel()
    
    private let secondSplitLine = UILabel()
    private let recipeGuideLabel = UILabel()
    private let recipeLabel = UILabel()
    
    private let likeButton = UIButton()
    private let likeCountLabel = UILabel()
    private let disLikeButton = UIButton()
    private let disLikeCountLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startLoading()
        attribute()
        layout()
        addBarButton()
        FirebaseRecipe.shared.getSingleCocktialData(cocktail: cocktailData) {[weak self] data in
            self?.likeData = ((try? data.get()) ?? [:])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if cocktailData.myRecipe {
            [likeButton, disLikeButton, disLikeCountLabel, likeCountLabel].forEach {
                $0.isHidden = true
            }
        }
    }
    
    private func layout() {
        view.addSubview(mainScrollView)
        view.addSubview(popUpView)
        mainScrollView.addSubview(mainView)
        
        [nameLabel, alcoholLabel, alcoholGuideLabel, alcoholStackView, ingredientsLabel, ingredientsGuideLabel, firstSplitLine, secondSplitLine, recipeLabel, recipeGuideLabel, myTipLabel, likeButton, likeCountLabel, disLikeCountLabel, disLikeButton, imageSplitLine, alcoholSplitLine].forEach { mainView.addSubview($0) }
        
        [groupStackView, cocktailImageView, wishListButton].forEach { mainView.addSubview($0) }
        
        [leftStackView, centerLine, rightStackView].forEach{ groupStackView.addArrangedSubview($0) }
        
        [colorGuideLabel, baseDrinkGuideLabel, drinkTypeGuideLabel, glassGuideLabel, craftGuideLabel].forEach { leftStackView.addArrangedSubview($0) }
        
        [colorLabel, baseDrinkLabel, drinkTypeLabel, glassLabel, craftLabel].forEach { rightStackView.addArrangedSubview($0) }
        
        [lowAlcoholLabel, midAlcoholLabel, highAlcoholLabel].forEach {
            alcoholStackView.addArrangedSubview($0)
            $0.snp.makeConstraints {
                $0.height.equalTo(lowAlcoholLabel.snp.width)
            }
        }
        
        //위에서부터 아래로 쭉 순서대로 찾으면 됨
        wishListButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
        }
        
        cocktailImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(wishListButton.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(cocktailImageView.snp.width)
        }
        
        imageSplitLine.snp.makeConstraints {
            $0.top.equalTo(cocktailImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(imageSplitLine.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalToSuperview()
        }
        
        if cocktailData.myRecipe {
            alcoholSplitLine.snp.makeConstraints {
                $0.top.equalTo(nameLabel.snp.bottom).offset(20)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(20)
            }
        } else {
            likeButton.snp.makeConstraints {
                $0.leading.equalTo(alcoholStackView.snp.leading)
                $0.width.height.equalTo(30)
                $0.top.equalTo(nameLabel.snp.bottom).offset(20)
            }
            
            likeCountLabel.snp.makeConstraints {
                $0.leading.trailing.equalTo(likeButton)
                $0.top.equalTo(likeButton.snp.bottom)
            }
            
            disLikeButton.snp.makeConstraints {
                $0.trailing.equalTo(alcoholStackView.snp.trailing)
                $0.width.height.equalTo(30)
                $0.top.equalTo(likeButton)
            }
            
            disLikeCountLabel.snp.makeConstraints {
                $0.leading.trailing.equalTo(disLikeButton)
                $0.top.equalTo(disLikeButton.snp.bottom)
            }
            
            alcoholSplitLine.snp.makeConstraints {
                $0.top.equalTo(disLikeCountLabel.snp.bottom).offset(20)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(20)
            }
        }
        
        alcoholStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(alcoholSplitLine.snp.bottom).offset(20)
        }
        
        alcoholGuideLabel.snp.makeConstraints {
            $0.centerY.equalTo(alcoholStackView)
            $0.trailing.equalTo(alcoholStackView.snp.leading).offset(-5)
        }
        
        alcoholLabel.snp.makeConstraints {
            $0.centerY.equalTo(alcoholStackView)
            $0.leading.equalTo(alcoholStackView.snp.trailing).offset(5)
        }
        
        myTipLabel.snp.makeConstraints {
            $0.top.equalTo(alcoholStackView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
        }
        
        groupStackView.snp.makeConstraints {
            $0.top.equalTo(myTipLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        centerLine.snp.makeConstraints {
            $0.width.equalTo(2)
        }
        
        firstSplitLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(groupStackView.snp.bottom).offset(50)
        }
        
        ingredientsGuideLabel.snp.makeConstraints {
            $0.top.equalTo(firstSplitLine.snp.bottom).offset(50)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
        }
        
        ingredientsLabel.snp.makeConstraints {
            $0.top.equalTo(ingredientsGuideLabel.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.centerX.equalToSuperview()
        }
        
        secondSplitLine.snp.makeConstraints {
            $0.top.equalTo(ingredientsLabel.snp.bottom).offset(50)
            $0.width.equalTo(firstSplitLine)
            $0.height.equalTo(20)
            $0.centerX.equalToSuperview()
        }
        
        recipeGuideLabel.snp.makeConstraints {
            $0.top.equalTo(secondSplitLine.snp.bottom).offset(50)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
        }
        
        recipeLabel.snp.makeConstraints {
            $0.top.equalTo(recipeGuideLabel.snp.bottom).offset(30)
            $0.width.equalTo(ingredientsLabel)
            $0.centerX.equalToSuperview()
        }
        
        mainScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mainView.snp.makeConstraints {
            $0.width.equalTo(mainScrollView.frameLayoutGuide)
            $0.edges.equalTo(mainScrollView.contentLayoutGuide)
            $0.bottom.equalTo(recipeLabel.snp.bottom).offset(100)
        }
    }
    
    private func attribute() {
        view.backgroundColor = .white
        mainView.backgroundColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.nexonFont(ofSize: 20, weight: .bold)]
        //구분선의 색상 설정
        [centerLine, firstSplitLine, secondSplitLine, imageSplitLine, alcoholSplitLine].forEach {
            $0.backgroundColor = .splitLineGray
        }
        
        //내용 설정하는곳
        [alcoholLabel, alcoholGuideLabel, myTipLabel, colorLabel, baseDrinkLabel, glassLabel, craftLabel, ingredientsLabel, recipeLabel, drinkTypeLabel, likeCountLabel, disLikeCountLabel].forEach {
            $0.textColor = .mainGray
            $0.font = .nexonFont(ofSize: 14, weight: .medium)
            $0.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        }
        
        //제목 설정하는곳
        [colorGuideLabel, baseDrinkGuideLabel, glassGuideLabel, craftGuideLabel, drinkTypeGuideLabel, ingredientsGuideLabel, recipeGuideLabel].forEach {
            $0.textColor = .mainGray
            $0.font = .nexonFont(ofSize: 16, weight: .bold)
        }
        
        //제일 두꺼운 칵테일 이름 설정
        [nameLabel].forEach {
            $0.textAlignment = .center
            $0.textColor = .mainGray
            $0.font = .nexonFont(ofSize: 24, weight: .heavy)
        }
        
        [alcoholLabel, alcoholGuideLabel, myTipLabel].forEach {
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        [colorLabel, baseDrinkLabel, glassLabel, craftLabel, drinkTypeLabel].forEach {
            $0.textAlignment = .left
        }
        
        [colorGuideLabel, baseDrinkGuideLabel, glassGuideLabel, craftGuideLabel, drinkTypeGuideLabel].forEach {
            $0.textAlignment = .right
        }
        
        [myTipLabel, recipeLabel, ingredientsLabel].forEach {
            $0.sizeToFit()
            $0.numberOfLines = 0
            $0.textColor = .mainGray
        }
        
        [leftStackView, rightStackView].forEach {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.spacing = 10
        }
        
        [likeButton, disLikeButton, likeCountLabel, disLikeCountLabel].forEach {
            $0.tintColor = .mainGray
        }
        
        wishListButton.tintColor = .mainOrange
        cocktailImageView.contentMode = .scaleAspectFit

        alcoholStackView.distribution = .fillEqually
        alcoholStackView.alignment = .center
        alcoholStackView.spacing = 20
        
        groupStackView.axis = .horizontal
        groupStackView.spacing = 10
        groupStackView.distribution = .fillProportionally
        
        likeButton.setBackgroundImage(UIImage(systemName: "hand.thumbsup"), for: .normal)

        disLikeButton.setBackgroundImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)

        alcoholGuideLabel.text = "Alcohol".localized
        colorGuideLabel.text = "Color".localized
        baseDrinkGuideLabel.text = "Base".localized
        drinkTypeGuideLabel.text = "DrinkType".localized
        glassGuideLabel.text = "Glass".localized
        craftGuideLabel.text = "Craft".localized
        recipeGuideLabel.text = "Recipe".localized
        ingredientsGuideLabel.text = "Ingredients".localized

        popUpView.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        popUpView.isHidden = true
        
        wishListButton.addAction(UIAction(handler: {[weak self] _ in
            guard let self = self,
                  let _ = Auth.auth().currentUser?.uid else {
                      self?.pleaseLoginAlert()
                      return }
                if FirebaseRecipe.shared.wishList.contains(self.cocktailData) {
                    self.popUpView.animating(text: "Removed from\nWishList".localized)
                    self.wishListButton.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
                    guard let number = FirebaseRecipe.shared.wishList.firstIndex(of: self.cocktailData) else { return }
                    FirebaseRecipe.shared.wishList.remove(at: number)
                    self.cocktailData.wishList = false
                } else {
                    self.popUpView.animating(text: "Add to\nWishList".localized)
                    self.wishListButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
                    var data = self.cocktailData
                    data.wishList = true
                    FirebaseRecipe.shared.wishList.append(data)
                    self.cocktailData.wishList = true
                }
                FirebaseRecipe.shared.uploadWishList()
        }), for: .touchUpInside)
        
        likeButton.addAction(UIAction(handler: {[weak self] _ in
            guard let self = self,
                  let _ = Auth.auth().currentUser?.uid else {
                      self?.pleaseLoginAlert()
                      return }
            if self.iLike == true {
                FirebaseRecipe.shared.deleteFavor(cocktail: self.cocktailData)
                FirebaseRecipe.shared.getSingleCocktialData(cocktail: self.cocktailData) { data in
                    self.likeData = (try? data.get()) ?? [:]
                }
                self.iLike = nil
            } else {
                self.popUpView.animating(text: "I like it!".localized)
                FirebaseRecipe.shared.addLike(cocktail: self.cocktailData)
                FirebaseRecipe.shared.getSingleCocktialData(cocktail: self.cocktailData) { data in
                    self.likeData = (try? data.get()) ?? [:]
                }
            }
        }), for: .touchUpInside)
        
        disLikeButton.addAction(UIAction(handler: {[weak self] _ in
            guard let self = self,
                  let _ = Auth.auth().currentUser?.uid else {
                      self?.pleaseLoginAlert()
                      return }
            if self.iLike == false {
                FirebaseRecipe.shared.deleteFavor(cocktail: self.cocktailData)
                FirebaseRecipe.shared.getSingleCocktialData(cocktail: self.cocktailData) { data in
                    self.likeData = (try? data.get()) ?? [:]
                }
                self.iLike = nil
            } else {
                self.popUpView.animating(text: "I don't like it...".localized)
                FirebaseRecipe.shared.addDislike(cocktail: self.cocktailData)
                FirebaseRecipe.shared.getSingleCocktialData(cocktail: self.cocktailData) { data in
                    self.likeData = (try? data.get()) ?? [:]
                }
            }
        }), for: .touchUpInside)
    }
    
    private func addBarButton() {
        let editingButton = UIBarButtonItem(title: "Add".localized, style: .done, target: self, action: #selector(startEditing))
        navigationItem.rightBarButtonItem = editingButton
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc private func startEditing() {
        guard let _ = Auth.auth().currentUser?.uid else {
                  self.pleaseLoginAlert()
                  return }
        
        let addMyOwnCocktailRecipeViewController = AddMyOwnCocktailRecipeViewController()
        addMyOwnCocktailRecipeViewController.editing(data: cocktailData)
        addMyOwnCocktailRecipeViewController.beforeEditingData = cocktailData
        addMyOwnCocktailRecipeViewController.choiceView.myIngredients = cocktailData.ingredients
        addMyOwnCocktailRecipeViewController.cocktailImageView.image = cocktailImageView.image
        addMyOwnCocktailRecipeViewController.choiceView.havePresetData = true
        show(addMyOwnCocktailRecipeViewController, sender: nil)
    }
    
    func setData(data: Cocktail) {
        nameLabel.text = data.name.localized
        alcoholLabel.text = data.alcohol.rawValue.localized
        colorLabel.text = data.color.rawValue.localized
        baseDrinkLabel.text = data.base.rawValue.localized
        drinkTypeLabel.text = data.drinkType.rawValue.localized
        glassLabel.text = data.glass.rawValue.localized
        craftLabel.text = data.craft.rawValue.localized
        myTipLabel.text = data.mytip.localized
        recipeLabel.text = String.makeRecipeText(recipe: data.recipe)
        ingredientsLabel.text = String.makeIngredientsText(ingredients: data.ingredients)
        cocktailImageView.kf.setImage(with: URL(string: data.imageURL), placeholder: UIImage(named: "\(data.glass.rawValue)" + "Empty"))
        [lowAlcoholLabel, highAlcoholLabel, midAlcoholLabel].forEach {
            $0.tintColor = UIColor(named: "nonSelectedAlcoholColor")
        }
        switch data.alcohol {
        case .high:
            highAlcoholLabel.tintColor = .mainOrange
        case .mid:
            midAlcoholLabel.tintColor = .mainOrange
        case .low:
            lowAlcoholLabel.tintColor = .mainOrange
        }
        
        var justRecipe = data
        justRecipe.wishList = true
        
        var wishListData = FirebaseRecipe.shared.wishList
        wishListData.indices.forEach { wishListData[$0].wishList = true }
        
        if wishListData.contains(justRecipe) {
            self.cocktailData = justRecipe
            wishListButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            self.cocktailData = data
            wishListButton.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
}
