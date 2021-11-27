import UIKit

struct MyDrinks: Codable, Hashable {
    var iHave: Bool
    var base: Cocktail.Base
    let name: Cocktail.Ingredients
}

protocol CocktailCondition {
    var rawValue: String { get }
}

enum SortingStandard {
    case alcohol
    case name
    case ingredientsCount
    case wishList
}

struct Cocktail: Codable, Hashable {
    let name: String
    let craft: Craft
    var glass: Glass
    let recipe: String
    var ingredients: [Ingredients]
    let base: Base
    let alcohol: Alcohol
    let color: Color
    let mytip: String
    let drinkType: DrinkType
    var myRecipe: Bool
    var wishList: Bool

    enum Base: String, Codable, CaseIterable, CocktailCondition {
        case rum = "럼"
        case vodka = "보드카"
        case tequila = "데킬라"
        case brandy = "브랜디"
        case whiskey = "위스키"
        case gin = "진"
        case liqueur = "리큐르"
        case assets = "기타"
        case beverage = "음료"
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let status = try container.decode(String.self)
            
            switch status {
            case "rum".localized:
                self = .rum
            case "vodka".localized:
                self = .vodka
            case "tequila".localized:
                self = .tequila
            case "brandy".localized:
                self = .brandy
            case "whiskey".localized:
                self = .whiskey
            case "gin".localized:
                self = .gin
            case "liqueur".localized:
                self = .liqueur
            case "assets".localized:
                self = .assets
            case "beverage".localized:
                self = .beverage
            default:
                self = .assets
            }
        }
        
        var list: [Ingredients] {
            switch self {
            case .gin:
                return [Cocktail.Ingredients.gin]
            case .rum:
                return [Cocktail.Ingredients.darkRum, Cocktail.Ingredients.whiteRum, Cocktail.Ingredients.overProofRum]
            case .vodka:
                return [Cocktail.Ingredients.vodka]
            case .tequila:
                return [Cocktail.Ingredients.tequila]
            case .brandy:
                return [Cocktail.Ingredients.brandy]
            case .whiskey:
                return [Cocktail.Ingredients.whiskey, Cocktail.Ingredients.ryeWhiskey, Cocktail.Ingredients.scotchWhiskey, Cocktail.Ingredients.bourbonWhiskey, Cocktail.Ingredients.jackDanielWhiskey]
            case .liqueur:
                return [Cocktail.Ingredients.baileys, Cocktail.Ingredients.melonLiqueur, Cocktail.Ingredients.whiteCacaoLiqueur, Cocktail.Ingredients.sweetVermouth, Cocktail.Ingredients.dryVermouth, Cocktail.Ingredients.peachTree, Cocktail.Ingredients.grapeFruitLiqueur, Cocktail.Ingredients.cacaoLiqueur, Cocktail.Ingredients.cremeDeCassis, Cocktail.Ingredients.greenMintLiqueur, Cocktail.Ingredients.campari, Cocktail.Ingredients.kahlua, Cocktail.Ingredients.blueCuraso, Cocktail.Ingredients.malibu, Cocktail.Ingredients.bananaliqueur, Cocktail.Ingredients.amaretto, Cocktail.Ingredients.triplesec, Cocktail.Ingredients.butterScotchLiqueur, Cocktail.Ingredients.angosturaBitters]
            case .beverage:
                return [Cocktail.Ingredients.coke, Cocktail.Ingredients.tonicWater, Cocktail.Ingredients.milk, Cocktail.Ingredients.orangeJuice, Cocktail.Ingredients.cranBerryJuice, Cocktail.Ingredients.clubSoda, Cocktail.Ingredients.grapeFruitJuice, Cocktail.Ingredients.pineappleJuice, Cocktail.Ingredients.gingerAle, Cocktail.Ingredients.sweetAndSourMix, Cocktail.Ingredients.appleJuice, Cocktail.Ingredients.cider, Cocktail.Ingredients.lemonJuice]
            case .assets:
                return [Cocktail.Ingredients.lime, Cocktail.Ingredients.limeSqueeze, Cocktail.Ingredients.limeSyrup, Cocktail.Ingredients.lemon, Cocktail.Ingredients.lemonSqueeze, Cocktail.Ingredients.appleMint, Cocktail.Ingredients.whippingCream, Cocktail.Ingredients.honey, Cocktail.Ingredients.olive, Cocktail.Ingredients.oliveJuice, Cocktail.Ingredients.sugar, Cocktail.Ingredients.sugarSyrup, Cocktail.Ingredients.rawCream, Cocktail.Ingredients.grenadineSyrup]
            }
        }
    }
    
    enum DrinkType: String, Codable, CaseIterable, CocktailCondition {
        case longDrink = "롱드링크"
        case shortDrink =  "숏드링크"
        case shooter = "슈터"
    }
    
    enum Color: String, Codable, CaseIterable, CocktailCondition {
        case red = "빨간색"
        case orange = "주황색"
        case yellow = "노란색"
        case green = "초록색"
        case blue = "파란색"
        case violet = "보라색"
        case clear = "투명색"
        case white = "하얀색"
        case black = "검은색"
        case brown = "갈색"
    }
    
    enum Alcohol: String, Codable, CaseIterable, CocktailCondition {
        case extreme
        case high
        case mid
        case low
        var rank: Int {
            switch self {
            case .extreme:
                return 4
            case .high:
                return 3
            case .mid:
                return 2
            case .low:
                return 1
            }
        }
    }
    
    enum Glass: String, Codable, CaseIterable, CocktailCondition {
        case highBall = "하이볼"
        case shot = "샷잔"
        case onTheRock = "온더락"
        case cocktail = "칵테일"
        case martini = "마티니"
        case collins = "콜린스"
        case margarita = "마가리타"
        case philsner = "필스너"
    }
    
    enum Craft: String, Codable, CaseIterable, CocktailCondition {
        case build = "빌드"
        case shaking = "쉐이킹"
        case floating = "플로팅"
        case stir = "스터"
        case blending = "블렌딩"
    }
    
    enum Ingredients: String, Codable, CaseIterable {
        case gin = "진"
        
        case vodka = "보드카"
        
        case whiskey = "위스키"
        case scotchWhiskey = "스카치위스키"
        case bourbonWhiskey = "버번위스키"
        case ryeWhiskey = "라이위스키"
        case jackDanielWhiskey = "잭다니엘"
        
        case tequila = "데킬라"
        
        case baileys = "베일리스"
        case melonLiqueur = "멜론리큐르"
        case whiteCacaoLiqueur = "화이트카카오리큐르"
        case sweetVermouth = "스위트베르무트"
        case dryVermouth = "드라이베르무트"
        case peachTree = "피치트리"
        case grapeFruitLiqueur = "자몽리큐르"
        case cacaoLiqueur = "카카오리큐르"
        case cremeDeCassis = "크렘드카시스"
        case greenMintLiqueur = "그린민트리큐르"
        case campari = "캄파리"
        case kahlua = "깔루아"
        case blueCuraso = "블루큐라소"
        case malibu = "말리부"
        case bananaliqueur = "바나나리큐르"
        case amaretto = "아마레또"
        case triplesec = "트리플섹"
        case butterScotchLiqueur = "버터스카치리큐르"
        case angosturaBitters = "앙고스투라비터스"
        
        case brandy = "브랜디"
        
        case coke = "콜라"
        case tonicWater = "토닉워터"
        case milk = "우유"
        case orangeJuice = "오렌지주스"
        case cranBerryJuice = "크렌베리주스"
        case clubSoda = "탄산수"
        case grapeFruitJuice = "자몽주스"
        case pineappleJuice = "파인애플주스"
        case gingerAle = "진저에일"
        case sweetAndSourMix = "스윗앤사워믹스"
        case appleJuice = "사과주스"
        case cider = "사이다"
        case lemonJuice = "레몬주스"
        
        case whiteRum = "화이트럼"
        case darkRum = "다크럼"
        case overProofRum = "오버프루프럼"
        
        case lime = "라임"
        case limeSqueeze = "라임즙"
        case limeSyrup = "라임시럽"
        case lemon = "레몬"
        case lemonSqueeze = "레몬즙"
        case appleMint = "애플민트"
        case whippingCream = " 크림"
        case honey = "꿀"
        case olive = "올리브"
        case oliveJuice = "올리브주스"
        case sugar = "설탕"
        case sugarSyrup = "설탕시럽"
        case rawCream = "생크림"
        case grenadineSyrup = "그레나딘시럽"
        
        case unknown = "무명의 재료"
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let status = try container.decode(String.self)
            
            switch status {
            case "gin".localized:
                self = .gin
            case "vodka".localized:
                self = .vodka
            case "whiskey".localized:
                self = .whiskey
            case "scotchWhiskey".localized:
                self = .scotchWhiskey
            case "bourbonWhiskey".localized:
                self = .bourbonWhiskey
            case "ryeWhiskey".localized:
                self = .ryeWhiskey
            case "jackDanielWhiskey".localized:
                self = .jackDanielWhiskey
            case "tequila".localized:
                self = .tequila
            case "baileys".localized:
                self = .baileys
            case "melonLiqueur".localized:
                self = .melonLiqueur
            case "whiteCacaoLiqueur".localized:
                self = .whiteCacaoLiqueur
            case "sweetVermouth".localized:
                self = .sweetVermouth
            case "dryVermouth".localized:
                self = .dryVermouth
            case "peachTree".localized:
                self = .peachTree
            case "grapeFruitLiqueur".localized:
                self = .grapeFruitLiqueur
            case "cacaoLiqueur".localized:
                self = .cacaoLiqueur
            case "cremeDeCassis".localized:
                self = .cremeDeCassis
            case "greenMintLiqueur".localized:
                self = .greenMintLiqueur
            case "campari".localized:
                self = .campari
            case "kahlua".localized:
                self = .kahlua
            case "blueCuraso".localized:
                self = .kahlua
            case "malibu".localized:
                self = .malibu
            case "bananaliqueur".localized:
                self = .bananaliqueur
            case "amaretto".localized:
                self = .amaretto
            case "triplesec".localized:
                self = .triplesec
            case "butterScotchLiqueur".localized:
                self = .butterScotchLiqueur
            case "angosturaBitters".localized:
                self = .angosturaBitters
            case "brandy".localized:
                self = .brandy
            case "coke".localized:
                self = .coke
            case "tonicWater".localized:
                self = .tonicWater
            case "milk".localized:
                self = .milk
            case "orangeJuice".localized:
                self = .orangeJuice
            case "cranBerryJuice".localized:
                self = .cranBerryJuice
            case "clubSoda".localized:
                self = .clubSoda
            case "grapeFruitJuice".localized:
                self = .grapeFruitJuice
            case "pineappleJuice".localized:
                self = .pineappleJuice
            case "gingerAle".localized:
                self = .gingerAle
            case "sweetAndSourMix".localized:
                self = .sweetAndSourMix
            case "appleJuice".localized:
                self = .appleJuice
            case "cider".localized:
                self = .cider
            case "lemonJuice".localized:
                self = .lemonJuice
            case "whiteRum".localized:
                self = .whiteRum
            case "darkRum".localized:
                self = .darkRum
            case "overProofRum".localized:
                self = .overProofRum
            case "lime".localized:
                self = .lime
            case "limeSqueeze".localized:
                self = .limeSqueeze
            case "limeSyrup".localized:
                self = .limeSyrup
            case "lemon".localized:
                self = .lemon
            case "lemonSqueeze".localized:
                self = .lemonSqueeze
            case "appleMint".localized:
                self = .appleMint
            case "whippingCream".localized:
                self = .whippingCream
            case "honey".localized:
                self = .honey
            case "olive".localized:
                self = .olive
            case "oliveJuice".localized:
                self = .oliveJuice
            case "sugar".localized:
                self = .sugar
            case "sugarSyrup".localized:
                self = .sugarSyrup
            case "rawCream".localized:
                self = .rawCream
            case "grenadineSyrup".localized:
                self = .grenadineSyrup
            default:
                self = .unknown
            }
        }
    }
}

//realm은 일단 보류
//class MyDrinks: Object {
//    @objc dynamic var name: String = ""
//    override static func primaryKey() -> String? {
//          return "name"
//        }
//}




