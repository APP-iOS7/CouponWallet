import SwiftUI

struct ThemeView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
            Form {
                Section(header: Text("디스플레이 설정").foregroundColor(colorScheme == .dark ? .white : .black)) {
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
}
