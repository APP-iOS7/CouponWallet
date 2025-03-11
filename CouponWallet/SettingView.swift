//
//  SettingView.swift
//  CouponWallet
//
//  Created by 조영민 on 3/6/25.
//

import SwiftUI

struct SettingView: View {
    @Binding var deletedGifticons: [Gifticon]
    @Binding var currentTab: Int
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("계정")) {
                    NavigationLink("프로필 설정", destination: Text("프로필 설정 화면"))
                    NavigationLink("알림 설정", destination: Text("알림 설정 화면"))
                    NavigationLink {
                        TrashView(deletedGifticons: $deletedGifticons, currentTab: $currentTab)
                    } label: {
                        HStack {
                            Text("휴지통")
                            
                            if !deletedGifticons.isEmpty {
                                Spacer()
                                Text("\(deletedGifticons.count)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                
                Section(header: Text("앱 설정")) {
                    NavigationLink("테마 설정", destination: ThemeView())
                    NavigationLink("언어 설정", destination: Text("언어 설정 화면"))
                    NavigationLink("정렬 기준", destination: Text("정렬 기준 화면"))
                    NavigationLink("프로필 설정", destination: Text("Comming soon..."))
                    NavigationLink("알림 설정", destination: Text("이것도 Comming soon..."))
                }
                
                Section(header: Text("정보")) {
                    Text("앱 버전 1.0.0")
                    NavigationLink("개인정보 처리방침", destination: Text("이것도 Comming soon..."))
                    NavigationLink("이용약관", destination: Text("이것도 Comming soon..."))
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
