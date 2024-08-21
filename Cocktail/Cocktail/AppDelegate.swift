//
//  AppDelegate.swift
//  Cocktail
//
//  Created by 강희성 on 2021/11/02.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging
import FirebaseAnalytics
import FirebaseAuth
import Siren

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        FirebaseRecipe.shared.getRecipe { data in
            FirebaseRecipe.shared.recipe = (try? data.get()) ?? []
        }
        
        FirebaseRecipe.shared.getCocktailLikeData { data in
            FirebaseRecipe.shared.cocktailLikeList = (try? data.get()) ?? [:]
        }
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
        }
        application.registerForRemoteNotifications()
        
        if Auth.auth().currentUser?.uid == nil {
            UserDefaults.standard.set(true, forKey: "firstLaunch")
        } else {
            UserDefaults.standard.set(false, forKey: "firstLaunch")
        }
        ///네비게이션바 글자 색깔 바꾸기
        UINavigationBar.appearance().tintColor = .mainGray
        
        ///네비게이션바  폰트 정해주기
        let naviBarTextAttributes = [NSAttributedString.Key.font: UIFont.nexonFont(ofSize: 16, weight: .semibold)]
        UIBarButtonItem.appearance().setTitleTextAttributes(naviBarTextAttributes, for: UIControl.State.normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(naviBarTextAttributes, for: .highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes(naviBarTextAttributes, for: .focused)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.nexonFont(ofSize: 20, weight: .bold)]
        
        ///탭바 폰트
        let attributes = [NSAttributedString.Key.font: UIFont.nexonFont(ofSize: 12, weight: .semibold)]
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        
        
        let siren = Siren.shared
        siren.apiManager = APIManager(country: .korea) //기준 위치 대한민국 앱스토어로 변경
        siren.presentationManager = PresentationManager(forceLanguageLocalization: .korean) //알림 메시지 한국어로
        //일단 업뎃시켜버려~
        siren.rulesManager = RulesManager(majorUpdateRules: .critical,
                                          minorUpdateRules: .critical,
                                          patchUpdateRules: .critical,
                                          revisionUpdateRules: .critical)
        
        siren.wail()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "")")
    }
}
