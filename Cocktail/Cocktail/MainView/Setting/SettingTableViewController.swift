//
//  SettingTableViewController.swift
//  Cocktail
//
//  Created by 강희성 on 2021/12/04.
//

import UIKit
import SnapKit
import FirebaseAuth
import StoreKit     //For AppStore Review Request
import MessageUI    //For Send Email

final class SettingTableViewController: UITableViewController {
    enum Settings: Int, CaseIterable {
        case serviceInformation
        case alarm
        case support
        case developerInfo
        case account
        
        var sectionTitle: String {
            switch self {
            case .serviceInformation:
                return "Service Information".localized
            case .alarm:
                return "Alarm".localized
            case .support:
                return "Support".localized
            case .developerInfo:
                return "DeveloperInfo".localized
            case .account:
                return "Account".localized
            }
        }
        
        var rowTitles: [String] {
            switch self {
            case .serviceInformation:
                return ["Version".localized + "\(String(describing: Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""))", "Open Source Library".localized]
            case .alarm:
                return ["Alarm Setting".localized]
            case .support:
                return ["Review Shaker in the App Store".localized, "Join the Shaker TestFlight".localized]
            case .developerInfo:
                return ["Developers".localized]
            case .account:
                return Auth.auth().currentUser == nil ? ["LogIn".localized] : ["LogOut".localized]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings".localized
        tableView.register(SettingCell.self, forCellReuseIdentifier: "SettingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

///UITableView DataSource & Delegate
extension SettingTableViewController {
    
    override func tableView(_  tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 10, y: -10, width: 320, height: 30)
        myLabel.textColor = .mainGray
        myLabel.font = .nexonFont(ofSize: 12, weight: .semibold)
        myLabel.text = Settings(rawValue: section)?.sectionTitle
        let headerView = UIView()
        headerView.addSubview(myLabel)

        return headerView
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Settings.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Settings(rawValue: section)?.rowTitles.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 1:
                show(OpenSourceView(), sender: nil)
            default:
                return
            }
        case 2:
            switch indexPath.row {
            case 0:
                requestAppStoreReview()
            case 1:
                setlinkAction(appURL: "items-beta://", webURL: "")
            default:
                return
            }
        case 3:
            let settingDetailViewController = SettingDetailViewController()
            show(settingDetailViewController, sender: nil)
        case 4:
            Auth.auth().currentUser == nil ? logIn() : logOut()
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as? SettingCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.mainLabel.text = Settings(rawValue: indexPath.section)?.rowTitles[indexPath.row]
        cell.accessoryView?.isHidden = true

        switch indexPath.section {
        case 1:
            cell.accessoryView?.isHidden = false
            let accessorySwitch = UISwitch()
            UNUserNotificationCenter.current().getNotificationSettings { data in
                if data.notificationCenterSetting == .enabled {
                    DispatchQueue.main.async {
                        accessorySwitch.isOn = true
                    }
                } else {
                    DispatchQueue.main.async {
                        accessorySwitch.isOn = false
                    }
                }
            }
            accessorySwitch.addTarget(self, action: #selector(switchAction(sender:)), for: .valueChanged)
            cell.accessoryView = accessorySwitch
            return cell
        default:
            return cell
        }
    }
    
    @objc func switchAction(sender: UISwitch) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}

///Actions per indexPath.row
extension SettingTableViewController {
    private func requestAppStoreReview() {
        let scenes = UIApplication.shared.connectedScenes
        guard let windowScene = scenes.first as? UIWindowScene else { return }
        
        guard let count = UserDefaults.standard.value(forKey: "ReviewCount") as? Int else {
            UserDefaults.standard.set(1, forKey: "ReviewCount")
            SKStoreReviewController.requestReview(in: windowScene)
            return
        }
        
        if count < 2 {
            let count = count + 1
            UserDefaults.standard.set(count, forKey: "ReviewCount")
            SKStoreReviewController.requestReview(in: windowScene)
        } else {
            guard let appStoreURL = URL(string: "https://apps.apple.com/app/id1597875622") else { return }    //TODO: 앱아이디 입력해줄 것 예)id100043049583
            var components = URLComponents(url: appStoreURL, resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "action", value: "write-review")]
            guard let writeReviewURL = components?.url else { return }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
    
    private func setlinkAction(appURL: String, webURL: String) {
        let appURL = URL(string: appURL)!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            application.open(appURL)
        } else if let webURL = URL(string: webURL) {
            application.open(webURL)
        }
    }
    
    private func logIn() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let loginViewController = LoginViewController()
        let loginViewModel = LoginViewModel()
        loginViewController.bind(loginViewModel)
        window?.rootViewController = UINavigationController(rootViewController: loginViewController)
    }
    
    private func logOut() {
        let alert = UIAlertController(title: "Do you want to log out?".localized, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes".localized, style: .default) { _ in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                UserDefaults.standard.set(true, forKey: "firstLaunch")
            } catch let error {
                print(error)
            }
            FirebaseRecipe.shared.myRecipe = []
            FirebaseRecipe.shared.wishList = []
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "No".localized, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
