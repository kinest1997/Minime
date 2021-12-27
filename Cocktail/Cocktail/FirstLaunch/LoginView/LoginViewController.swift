//
//  LoginViewController.swift
//  Cocktail
//
//  Created by 강희성 on 2021/11/30.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import SnapKit
import FirebaseDatabase
import RxCocoa
import RxSwift

protocol LoginViewBiandable {
    // view -> viewModel
    var appleLoginButtonTapped: PublishRelay<Void> { get }
    var justUseButtonTapped: PublishRelay<Void> { get }
    
    // viewModel -> view
    var startSignInWithAppleFlow: Signal<Void> { get }
    var updateFirstLogin: Signal<Bool> { get }
    var changeLoginView: Signal<Void> { get }
}

class LoginViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let mainImageView = UIImageView()
    
    let userNotiCenter = UNUserNotificationCenter.current()
    
    let mainViewController = MainViewController()
    let shakerLabel = UILabel()
    let loginlabel = UILabel()
    
    private var currentNonce: String?
    
    let appleLoginButton = UIButton()
    let justUseButton = UIButton()
    
    func bind(_ viewModel: LoginViewBiandable) {
//        view -> viewModel
        appleLoginButton.rx.tap
            .bind(to: viewModel.appleLoginButtonTapped)
            .disposed(by: disposeBag)
        
        justUseButton.rx.tap
            .bind(to: viewModel.justUseButtonTapped)
            .disposed(by: disposeBag)
        
        //viewModel -> view
        viewModel.updateFirstLogin
            .emit { bool in
                UserDefaults.standard.set(bool, forKey: "firstLaunch")}
            .disposed(by: disposeBag)
        
        viewModel.changeLoginView
            .emit(onNext: {[weak self] _ in
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                let window = windowScene?.windows.first
                window?.rootViewController = self?.mainViewController
            })
            .disposed(by: disposeBag)
        
        viewModel.startSignInWithAppleFlow
            .emit(to: self.rx.startSignWithAppleLogin)
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthNoti()
        layout()
        attribute()
    }
    
    func attribute() {
        view.backgroundColor = .white
        mainImageView.image = UIImage(named: "logoImage")
        justUseButton.setTitle("로그인없이 시작하기", for: .normal)
        justUseButton.setTitleColor(.gray, for: .normal)
        shakerLabel.font = .systemFont(ofSize: 45, weight: .bold)
        shakerLabel.textColor = UIColor(named: "shaker")
        loginlabel.font = .systemFont(ofSize: 45, weight: .light)
        loginlabel.textColor = UIColor(named: "login")
        shakerLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        shakerLabel.text = "SHAKER"
        loginlabel.text = "LOGIN"
        shakerLabel.sizeToFit()
        loginlabel.sizeToFit()
        mainImageView.contentMode = .bottomLeft

        appleLoginButton.layer.cornerRadius = 15
        appleLoginButton.clipsToBounds = true
        appleLoginButton.contentMode = .scaleAspectFill
        appleLoginButton.setBackgroundImage(UIImage(named: "appleid_button"), for: .normal)
    }
    
    func layout() {
        [appleLoginButton, justUseButton, loginlabel, mainImageView, shakerLabel].forEach {
            view.addSubview($0)
        }

        mainImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-5)
            $0.height.equalTo(470)
            $0.leading.equalTo(shakerLabel.snp.trailing)
            $0.bottom.equalTo(appleLoginButton.snp.top).offset(-50)
        }
        
        shakerLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(35)
            $0.height.equalTo(50)
            $0.bottom.equalTo(loginlabel.snp.top)
        }
        
        loginlabel.snp.makeConstraints {
            $0.leading.equalTo(shakerLabel)
            $0.top.equalTo(shakerLabel.snp.bottom)
            $0.height.equalTo(shakerLabel)
            $0.bottom.equalTo(mainImageView)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-150)
            $0.width.equalTo(250)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
        
        justUseButton.snp.makeConstraints {
            $0.top.equalTo(appleLoginButton.snp.bottom).offset(20)
            $0.width.height.equalTo(appleLoginButton)
            $0.centerX.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func requestAuthNoti() {
        let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        userNotiCenter.requestAuthorization(options: notiAuthOptions) { (success, error) in
            if let error = error {
                print(#function, error)
            }
        }
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print ("Error Apple sign in: %@", error)
                    return
                }
                UserDefaults.standard.set(false, forKey: "firstLaunch")
                self.show(ColorChoiceViewController(), sender: nil)
            }
        }
    }
}

extension LoginViewController {
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}

extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension Reactive where Base: LoginViewController {
    var startSignWithAppleLogin: Binder<Void> {
        return Binder(base) { base, _ in
            base.startSignInWithAppleFlow()
        }
    }
}
