//
//  AppDelegate.swift
//  AFL
//
//  Created by Parth on 20/05/2025.
//
import FirebaseCore
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var afMatch: Match?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        navigtaionBarCustomization()
        FirebaseApp.configure()
        return true
    }
    
    func navigtaionBarCustomization() {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(red: 0.55, green: 0.44, blue: 0.32, alpha: 1.00)
        navigationBarAppearace.shadowColor = .clear
        navigationBarAppearace.shadowImage = UIImage()
        navigationBarAppearace.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearace.isTranslucent = true
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24.0)]
        navigationBarAppearace.backgroundColor = UIColor.systemBackground
        navigationBarAppearace.barTintColor = UIColor(red: 0.55, green: 0.44, blue: 0.32, alpha: 1.00)
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24.0)]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            let appearance2 = UITabBarAppearance()
            appearance2.configureWithOpaqueBackground()
            appearance2.backgroundColor = UIColor.systemBackground
            UITabBar.appearance().standardAppearance = appearance2
            UITabBar.appearance().scrollEdgeAppearance = appearance2
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.label], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 0.55, green: 0.44, blue: 0.32, alpha: 1.00)], for: .selected)
        }
    }
    
}

