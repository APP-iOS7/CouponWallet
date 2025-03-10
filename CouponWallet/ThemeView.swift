//
//  ThemeView.swift
//  CouponWallet
//
//  Created by Reimos on 3/8/25.
//

import SwiftUI
/*
 테스트로 ThemeView에서 공유 아이콘 클릭 시 갤러리에 저장 및 공유
 */

// ThemeView 수정 버전
struct ThemeView: View {
    // 스크린샷 변수 추가
    @State private var screenshotImage: UIImage? = nil
    @State private var showToast = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("디스플레이 설정").foregroundColor(colorScheme == .dark ? .white : .black)) {
                    
                    // 다크 모드 버튼
                    Button(action: {
                        isDarkMode = true
                    }) {
                        HStack {
                            Text("🌙 다크 모드")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            if isDarkMode { Image(systemName: "checkmark").foregroundColor(colorScheme == .dark ? .white : .black) }
                        }
                    }
                    
                    // 라이트 모드 버튼
                    Button(action: {
                        isDarkMode = false
                    }) {
                        HStack {
                            Text("☀️ 라이트 모드")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            if !isDarkMode { Image(systemName: "checkmark").foregroundColor(colorScheme == .dark ? .white : .black) }
                        }
                    }
                }
            }
            .navigationTitle("화면 테마")
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // 스크린샷이 있으면 ShareLink 표시, 없으면 캡처 버튼 표시
                if let screenshot = screenshotImage {
                    ShareLink(item: Image(uiImage: screenshot),
                              preview: SharePreview("화면 테마 스크린샷", image: Image(uiImage: screenshot))) {
                        Image(systemName: "square.and.arrow.up")
                    }
                } else {
                    Button {
                        captureScreenshot()
                    } label: {
                        Image(systemName: "camera")
                    }
                }
            }
        }
        // 캡쳐 이미지를 저장하면 Toast 메시지로 알려줌
        if showToast {
            VStack {
                Text("스크린샷 앨범 저장")
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .transition(.opacity)
            .animation(.easeInOut, value: showToast)
            .padding(.bottom, 50)
        }
    }
    
    // 스크린샷 캡처 함수
    private func captureScreenshot() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let screenshot = window.rootViewController?.view.changeUIImage() {
            self.screenshotImage = screenshot
            
            // 원하는 경우 앨범에도 저장 가능
            saveCaptureImageToAlbum(screenshot)
            
            // 토스트 메시지 표시
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showToast = false
            }
        }
    }
}
#Preview {
    ThemeView()
}
