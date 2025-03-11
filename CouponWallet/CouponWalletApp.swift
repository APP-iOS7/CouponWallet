//
//  CouponWalletApp.swift
//  CouponWallet
//
//  Created by 조영민 on 3/6/25.
//

import SwiftUI
import SwiftData

@main
struct CouponWalletApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.colorScheme, isDarkMode ? .dark : .light)
                .modelContainer(for: Gifticon.self)
        }
    }
}
