import UIKit
import FirebaseDatabase
import FirebaseAuth
import AuthenticationServices
import RxCocoa
import RxSwift

///유저의 개인 취향을 저장하는곳, 설정에서 나중에 취향 재설정 가능하게 하자

class UserFavor {
    static let shared = UserFavor()
    
    var colorFavor: [Cocktail.Color] = []
    
    var alcoholFavor: Cocktail.Alcohol?
    
    var drinkTypeFavor: Cocktail.DrinkType?
    
    var baseDrinkFavor: Cocktail.Base?
    
    func makeAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title.localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        return alert
    }
    
    private init() { }
}

class ContentNetwork {
    static let shared = ContentNetwork()
    
    func setlinkAction(appURL: String, webURL: String){
        let appURL = URL(string: appURL)!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            application.open(appURL)
        } else {
            let webURL = URL(string: webURL)!
            application.open(webURL)
        }
    }
}

class FirebaseRecipe {
    static let shared = FirebaseRecipe()
    
    let ref = Database.database().reference()
    
    var recipe: [Cocktail] = []
    
    var wishList: [Cocktail] = []
    
    var myRecipe: [Cocktail] = []
    
    var recommendations: [Recommendation] = []
    
    var youTubeData: [YouTubeVideo] = []
    
    var cocktailLikeList: [String:[String: Bool]] = [:]
    
    let uid = Auth.auth().currentUser?.uid
    
    /// 추천 카테고리의 칵테일 리스트를 불러온다
    func getRecommendations(completion: @escaping (Result<[Recommendation], ShakerError>) -> (Void)) {
        ref.child("CocktailRecommendation").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]],
                  let data = try? JSONSerialization.data(withJSONObject: value, options: []),
                  let cocktailList = try? JSONDecoder().decode([Recommendation].self, from: data) else {
                completion(.failure(.decoding("추천목록을 받아오는데 오류가 발생했습니다")))
                return }
            completion(.success(cocktailList))
        }
    }
    
    /// 추천 카테고리의 칵테일 리스트를 Single로 반환해준다
    func getRecommendationsRx() -> Single<[Recommendation]> {
        return Single.create {[weak self] observer in
            self?.ref.child("CocktailRecommendation").observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [[String: Any]],
                      let data = try? JSONSerialization.data(withJSONObject: value, options: []),
                      let cocktailList = try? JSONDecoder().decode([Recommendation].self, from: data) else {
                    observer(.failure(ShakerError.decoding()))
                    return }
                observer(.success(cocktailList))
            }
            return Disposables.create()
        }
    }
    
    /// 전체 레시피를 Single로 불러온다
    func getRecipeRx() -> Single<[Cocktail]> {
        return Single.create {[weak self] observer in
            self?.ref.child("CocktailRecipes").observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [[String: Any]],
                      let data = try? JSONSerialization.data(withJSONObject: value, options: []),
                      let cocktailList = try? JSONDecoder().decode([Cocktail].self, from: data) else {
                    observer(.failure(ShakerError.decoding()))
                    return }
                observer(.success(cocktailList))
            }
            return Disposables.create()
        }
    }
    
    /// 전체 레시피를 불러온다
    func getRecipe(completion: @escaping (Result<[Cocktail], ShakerError>) -> (Void)) {
        ref.child("CocktailRecipes").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]],
                  let data = try? JSONSerialization.data(withJSONObject: value, options: []),
                  let cocktailList = try? JSONDecoder().decode([Cocktail].self, from: data) else {
                completion(.failure(.encoding()))
                return }
            completion(.success(cocktailList))
        }
    }
    
    /// 내가 직접 만든 레시피를 불러온다
    func getMyRecipe(completion: @escaping (Result<[Cocktail], ShakerError>) -> (Void)) {
        guard let uid = uid else { return }
        ref.child("users").child(uid).child("MyRecipes").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]],
                  let data = try? JSONSerialization.data(withJSONObject: value, options: []),
                  let cocktailList = try? JSONDecoder().decode([Cocktail].self, from: data) else {
                completion(.failure(.decoding()))
                return }
            let myRecipes = cocktailList.filter { $0.myRecipe == true }
            completion(.success(myRecipes))
        }
    }
    
    /// 내가 직접 만든 레시피를 Single로 불러온다
    func getMyRecipeRx() -> Single<[Cocktail]> {
        return Single.create {[weak self] observer in
            guard let uid = self?.uid else { return Disposables.create() }
            self?.ref.child("users").child(uid).child("MyRecipes").observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [[String: Any]],
                      let data = try? JSONSerialization.data(withJSONObject: value, options: []),
                      let cocktailList = try? JSONDecoder().decode([Cocktail].self, from: data) else {
                    observer(.failure(ShakerError.decoding()))
                    return }
                let myRecipes = cocktailList.filter { $0.myRecipe == true }
                return observer(.success(myRecipes))
            }
            return Disposables.create()
        }
    }
    
    /// 내가 즐겨찾기해놓은 리스트를 불러온다
    func getWishList(completion: @escaping (Result<[Cocktail], ShakerError>) -> (Void)) {
        guard let uid = uid else { return }
        ref.child("users").child(uid).child("WishList").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]],
                  let data = try? JSONSerialization.data(withJSONObject: value, options: []),
                  let cocktailList = try? JSONDecoder().decode([Cocktail].self, from: data) else {
                completion(.failure(.decoding()))
                return }
            let myRecipes = cocktailList.filter { $0.wishList == true }
            completion(.success(myRecipes))
        }
    }
    
    /// 유튜브 추천 영상 리스트를 받아온다
    func getYoutubeContents(completion: @escaping (Result<[YouTubeVideo], ShakerError>) -> (Void)) {
        ref.child("Youtube").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]],
                  let data = try? JSONSerialization.data(withJSONObject: value, options: []),
                  let youTubeVideoList = try? JSONDecoder().decode([YouTubeVideo].self, from: data) else {
                completion(.failure(.decoding()))
                return }
            completion(.success(youTubeVideoList))
        }
    }
    
    /// 칵테일들의 좋아요 데이터를 받아온다
    func getCocktailLikeData(completion: @escaping (Result<[String:[String: Bool]], ShakerError>) -> (Void)) {
        Database.database().reference().child("CocktailLikeData").observe( .value) { snapshot in
            guard let value = snapshot.value as? [String:[String: Bool]] else {
                completion(.failure(.firebase("칵테일의 좋아요를 불러오는데 실패하였습니다")))
                return
            }
            completion(.success(value))
        }
    }
    
    /// 하나의 칵테일의 좋아요 데이터를 받아온다
    func getSingleCocktialData(cocktail: Cocktail, completion: @escaping (Result<[String: Bool], ShakerError>) -> (Void)) {
        Database.database().reference().child("CocktailLikeData").child(cocktail.name).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Bool] else {
                completion(.failure(.firebase("칵테일의 좋아요를 불러오는데 실패하였습니다")))
                return  }
            completion(.success(value))
        }
    }
    
    func likeOrDislikeCount(cocktailList: [String: Bool], choice: Bool) -> Int {
        switch choice {
        case true:
            return cocktailList.filter { $0.value == true }.count
        case false:
            return cocktailList.filter { $0.value == false }.count
        }
    }
    /// 좋아요 리스트를 업로드 한다
    func uploadWishList() {
        guard let data = try? JSONEncoder().encode(FirebaseRecipe.shared.wishList),
              let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
              let uid = uid else { return }
        ref.child("users").child(uid).child("WishList").setValue(jsonData)
    }
    
    /// 나의 레시피를 업로드 한다
    func uploadMyRecipe() {
        guard let data = try? JSONEncoder().encode(FirebaseRecipe.shared.myRecipe),
              let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
              let uid = uid else { return }
        ref.child("users").child(uid).child("MyRecipes").setValue(jsonData)
    }
    
    /**
     전체 레시피를 업로드 한다
     
     - 유저가 사용할일 없으며 내가 만든 레시피를 업데이트 할때 사용한다
     */
    func uploadWholeRecipe() {
        let cocktailList = getJSONRecipe()
        guard let data = try? JSONEncoder().encode(cocktailList) else { return }
        let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
        Database.database().reference().child("CocktailRecipes").setValue(jsonData)
    }
    
    /// 좋아요를 추가한다
    func addLike(cocktail: Cocktail) {
        guard let uid = uid else { return }
        Database.database().reference().child("CocktailLikeData").child(cocktail.name).child(uid).setValue(true)
    }
    
    
    func uploadId(cocktail: Cocktail) {
        Database.database().reference().child("CocktailLikeData").child(cocktail.name).child("id").setValue(cocktail.name)
    }
    
    /// 싫어요를 추가한다
    func addDislike(cocktail: Cocktail) {
        guard let uid = uid else { return }
        Database.database().reference().child("CocktailLikeData").child(cocktail.name).child(uid).setValue(false)
    }
    /// 좋아요를 제거한다
    func deleteFavor(cocktail: Cocktail) {
        guard let uid = uid else { return }
        Database.database().reference().child("CocktailLikeData").child(cocktail.name).child(uid).setValue(nil)
    }
    
    /// Plist로 부터 JSon파일을 반환해주는 함수, 기존에 Plist에 담겨있던 레시피를 변환 하기위하여 사용했었다.
    /// 현재는 사용처 없음
    func getJSONRecipe() -> [Cocktail] {
        guard let bundleURL = Bundle.main.url(forResource: "CocktailData", withExtension: "json"),
              let cocktailData = FileManager.default.contents(atPath: bundleURL.path) else { return [] }
        do {
            let cocktailList = try JSONDecoder().decode([Cocktail].self, from: cocktailData).sorted {
                $0.name < $1.name
            }
            return cocktailList
        } catch let error{
            print(String(describing: error))
            return []
        }
    }
    
    /// 유튜브 json파일을 업로드 하기위해 사용했었던 함수, 현재는 사용처가 없다
    func uploadyoutube() {
        guard let data = try? JSONEncoder().encode([YouTubeVideo(videoName: "firstName", videoCode: "HzxdVaKaPyA", owner: .drinkLecture)]),
              let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else { return }
        Database.database().reference().child("Youtube").setValue(jsonData)
    }
    private init() { }
}
