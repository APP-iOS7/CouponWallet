import SwiftUI
import SwiftData

struct SelectedCouponView: View {
    // 선택된 기프티콘을 받아옴
    var initialGifticon: Gifticon
    
    // 사용 가능한 모든 기프티콘 쿼리
    @Query private var availableGifticons: [Gifticon]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss // 네비게이션 dismiss를 위한 환경 변수 추가
    
    // 현재 선택된, 현재 인덱스를 추적하기 위한 상태 변수
    @State private var selectedIndex: Int = 0
    
    // 수정 관련 상태 변수
    @State private var isEditing: Bool = false
    @State private var editedProductName: String = ""
    @State private var editedBrand: String = ""
    @State private var editedExpirationDate: Date = Date()
    @State private var showSaveAlert: Bool = false
    // 스크린샷 변수 추가
    @State private var screenshotImage: UIImage? = nil
    @State private var showToast = false
    init(selectedGifticon: Gifticon) {
        self.initialGifticon = selectedGifticon
        
        let now = Date()
        // 사용 가능한 기프티콘: 만료되지 않았고 사용되지 않은 것
        let predicate = #Predicate<Gifticon> { gifticon in
            !gifticon.isUsed && gifticon.expirationDate > now
        }
        _availableGifticons = Query(filter: predicate, sort: [SortDescriptor(\.expirationDate)])
    }
    
    // 초기 기프티콘의 인덱스를 찾는 함수
    private func findInitialIndex() -> Int {
        return availableGifticons.firstIndex(where: { $0.id == initialGifticon.id }) ?? 0
    }
    
    // 현재 선택된 기프티콘
    private var currentGifticon: Gifticon? {
        if availableGifticons.isEmpty || selectedIndex >= availableGifticons.count {
            return nil
        }
        return availableGifticons[selectedIndex]
    }
    
    // 변경사항 저장 함수
    private func saveChanges() {
        if let gifticon = currentGifticon {
            gifticon.productName = editedProductName
            gifticon.brand = editedBrand
            gifticon.expirationDate = editedExpirationDate
            
            try? modelContext.save()
            isEditing = false
            showSaveAlert = true
        }
    }
    
    // 수정 모드 시작 함수
    private func startEditing() {
        if let gifticon = currentGifticon {
            editedProductName = gifticon.productName
            editedBrand = gifticon.brand
            editedExpirationDate = gifticon.expirationDate
            isEditing = true
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                if availableGifticons.isEmpty {
                    Text("표시할 쿠폰이 없습니다")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    TabView(selection: $selectedIndex) {
                        ForEach(Array(availableGifticons.enumerated()), id: \.element.id) { index, gifticon in
                            if isEditing && index == selectedIndex {
                                EditableCouponCell(
                                    selectedCoupon: gifticon,
                                    productName: $editedProductName,
                                    brand: $editedBrand,
                                    expirationDate: $editedExpirationDate
                                )
                                .tag(index)
                            } else {
                                SelectedCouponCell(selectedCoupon: gifticon)
                                    .tag(index)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .animation(.easeInOut, value: selectedIndex)
                    .onAppear {
                        selectedIndex = findInitialIndex()
                    }

                    HStack {
                        if isEditing {
                            Button("취소") {
                                isEditing = false
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)

                            Button("저장") {
                                saveChanges()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        } else {
                            Button("수정하기") {
                                startEditing()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)

                            Button("돌아가기") {
                                dismiss()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.primary)

                            Button("사용하기") {
                                if let gifticon = currentGifticon {
                                    gifticon.isUsed = true
                                    try? modelContext.save()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(currentGifticon?.isUsed ?? true ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(currentGifticon?.isUsed ?? true)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("쿠폰 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
            .alert("수정 완료", isPresented: $showSaveAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("쿠폰 정보가 성공적으로 수정되었습니다.")
            }

            // Toast 메시지를 쿠폰 이미지 위로 이동 
            if showToast {
                VStack {
                    Text("📸 스크린샷이 앨범에 저장되었습니다.")
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top, 20) // 쿠폰 이미지 위에서 약간 아래로 위치
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity, alignment: .top) // 최상단 정렬
                .zIndex(1) // 다른 UI 요소보다 위에 표시
                .transition(.opacity)
                .animation(.easeInOut, value: showToast)
            }
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

// 기존 기프티콘 셀 (보기 모드)
struct SelectedCouponCell: View {
    var selectedCoupon: Gifticon
    
    var body: some View {
        Form {
            Section(header: Text("선택 쿠폰")) {
                if !selectedCoupon.imagePath.isEmpty {
                    AsyncImage(url: URL(string: selectedCoupon.imagePath)) { image in
                        image
                            .resizable()
                            .clipShape(.rect(cornerRadius: 12))
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 200)
                            .overlay(
                                Text(selectedCoupon.brand)
                                    .foregroundColor(.gray)
                            )
                    }
                } else {
                    Image(systemName: "gift")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .padding()
                }
                
                HStack {
                    Text("상품명")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(selectedCoupon.productName)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("브랜드")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(selectedCoupon.brand)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("유효기간")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("~ \(selectedCoupon.formattedExpiryDate) 까지")
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("사용 가능 여부")
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: selectedCoupon.isUsed ? "xmark.circle.fill" : "checkmark.circle")
                        .foregroundColor(selectedCoupon.isUsed ? .red : .green)
                    Text(selectedCoupon.isUsed ? "사용 불가" : "사용 가능")
                        .fontWeight(.medium)
                }
            }
        }
    }
}

// 수정 가능한 기프티콘 셀 (수정 모드)
struct EditableCouponCell: View {
    var selectedCoupon: Gifticon
    @Binding var productName: String
    @Binding var brand: String
    @Binding var expirationDate: Date
    
    var body: some View {
        Form {
            Section(header: Text("쿠폰 정보 수정")) {
                if !selectedCoupon.imagePath.isEmpty {
                    AsyncImage(url: URL(string: selectedCoupon.imagePath)) { image in
                        image
                            .resizable()
                            .clipShape(.rect(cornerRadius: 12))
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 200)
                            .overlay(
                                Text(selectedCoupon.brand)
                                    .foregroundColor(.gray)
                            )
                    }
                } else {
                    Image(systemName: "gift")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .padding()
                }
                
                // 상품명 수정 필드
                LabeledContent("상품명") {
                    TextField("상품명을 입력하세요", text: $productName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.trailing)
                }
                
                // 브랜드 수정 필드
                LabeledContent("브랜드") {
                    // 브랜드 선택 필드 (필요시 Picker로 대체 가능)
                    TextField("브랜드를 입력하세요", text: $brand)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.trailing)
                }
                
                // 유효기간 수정 필드
                DatePicker(
                    "유효기간",
                    selection: $expirationDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
            }
            
            Section(header: Text("안내")) {
                Text("스캔된 정보가 정확하지 않은 경우 수정해주세요.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    // For preview purposes, create a dummy gifticon
    let gifticon = Gifticon(
        brand: "스타벅스",
        productName: "아메리카노",
        expirationDate: Date().addingTimeInterval(30*24*60*60),
        isUsed: false,
        imagePath: ""
    )
    
    return SelectedCouponView(selectedGifticon: gifticon)
        .modelContainer(for: Gifticon.self, inMemory: true)
}
