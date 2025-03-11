//
//  TrashView.swift
//  CouponWallet
//
//  Created by Reimos on 3/7/25.
//

import SwiftUI
import SwiftData

struct TrashView: View {
    // 삭제 확인 알림창을 표시할지 여부
    @State private var showDeleteAlert: Bool = false
    // 복구 확인 알림창을 표시할지 여부
    @State private var showRecoverAlert: Bool = false
    // 복구 완료 토스트 메시지 표시 여부
    @State private var showRecoveryToast: Bool = false
    // 복구 토스트 메시지 텍스트
    @State private var recoveryToastMessage: String = ""
    // 모든 쿠폰 복구 확인 알림창
    @State private var showRecoverAllAlert: Bool = false
    // 체크 모드 (여러 개 선택 가능)
    @State private var isCheckMode: Bool = false
    // 선택한 기프티콘
    @State private var selectedGifticon: Gifticon?
    // 삭제된 기프티콘을 저장하는 배열 (휴지통 기능을 위해 사용)
    @Binding var deletedGifticons: [Gifticon]
    // 현재 선택된 탭을 ContentView에서 가져옴
    @Binding var currentTab: Int
    // 모델 컨텍스트 추가
    @Environment(\.modelContext) private var modelContext
    // 다크모드 라이트모드 감지
    @Environment(\.colorScheme) var colorScheme
    
    // isUsed 및 expirationDate를 기반으로 상태 결정
    func determineGifticonStatus(_ gifticon: Gifticon) -> String {
        return gifticon.isUsed ? GifticonStatus.used.rawValue : GifticonStatus.expired.rawValue
    }
    
    // 기프티콘 복구 함수
    private func recoverGifticon(_ gifticon: Gifticon) {
        // 삭제된 기프티콘 목록에서 제거
        deletedGifticons.removeAll { $0.id == gifticon.id }
        
        // 데이터베이스에 다시 추가
        modelContext.insert(gifticon)
        try? modelContext.save()
        
        // 토스트 메시지 설정 및 표시
        recoveryToastMessage = "\(gifticon.productName) 쿠폰이 복구되었습니다"
        showRecoveryToast = true
        // 1.5초 후 토스트 메시지 숨기기
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showRecoveryToast = false
        }
        
        print("\(gifticon.productName) 복구됨")
    }
    
    // 모든 기프티콘 복구 함수
    private func recoverAllGifticons(confirmed: Bool = false) {
        if !confirmed {
            // 확인 알림창 표시
            showRecoverAllAlert = true
            return
        }
        
        // 복구할 쿠폰 개수 저장
        let recoveredCount = deletedGifticons.count
        
        // 모든 삭제된 기프티콘을 데이터베이스에 다시 추가
        for gifticon in deletedGifticons {
            // 중요: 기존 객체의 속성을 그대로 유지하면서 새 객체를 생성하여 추가
            let recoveredGifticon = Gifticon(
                brand: gifticon.brand,
                productName: gifticon.productName,
                expirationDate: gifticon.expirationDate,
                isUsed: gifticon.isUsed,
                imagePath: gifticon.imagePath
            )
            modelContext.insert(recoveredGifticon)
            print("\(gifticon.productName) 복구됨 (이미지 경로: \(gifticon.imagePath))")
        }
        
        // 삭제된 기프티콘 목록 비우기
        deletedGifticons.removeAll()
        
        try? modelContext.save()
        
        // 토스트 메시지 설정 및 표시
        recoveryToastMessage = "\(recoveredCount)개의 쿠폰이 모두 복구되었습니다"
        showRecoveryToast = true
        // 1.5초 후 토스트 메시지 숨기기
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showRecoveryToast = false
        }
        
        print("\(recoveredCount)개의 쿠폰 모두 복구됨")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if deletedGifticons.isEmpty {
                Spacer()
                Text("휴지통에 쿠폰이 없습니다")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                VStack {
                    // 복구/삭제 모드 선택 옵션
                    HStack(spacing: 10) {
                        Text("모드 선택:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        FilterButton(title: "복구", isSelected: !isCheckMode) {
                            isCheckMode = false
                        }
                        
                        FilterButton(title: "삭제", isSelected: isCheckMode) {
                            isCheckMode = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // 전체 복구 버튼
                    if !isCheckMode && deletedGifticons.count > 1 {
                        Button {
                            recoverAllGifticons()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("모든 쿠폰 복구하기")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 10)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(deletedGifticons) { gifticon in
                            ZStack(alignment: .topTrailing) {
                                GifticonCard(gifticon: gifticon, status: determineGifticonStatus(gifticon))
                                
                                Button {
                                    selectedGifticon = gifticon
                                    if isCheckMode {
                                        showDeleteAlert = true
                                    } else {
                                        showRecoverAlert = true
                                    }
                                } label: {
                                    Image(systemName: isCheckMode ? "xmark.circle.fill" : "arrow.counterclockwise.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    // 쿠폰이 선택되면 색상 변경 (삭제 모드는 빨간색, 복구 모드는 초록색)
                                        .foregroundColor(selectedGifticon == gifticon ?
                                                         (isCheckMode ? .red : .green) : .gray)
                                        .background(Circle().fill(Color.white).opacity(0.8))
                                        .clipShape(Circle())
                                }
                                .padding([.top, .trailing], 10)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("휴지통")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: {
                        isCheckMode = false
                    }) {
                        Label("복구 모드", systemImage: "arrow.counterclockwise")
                    }
                    
                    Button(action: {
                        isCheckMode = true
                    }) {
                        Label("삭제 모드", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: isCheckMode ? "trash" : "arrow.counterclockwise")
                        .foregroundStyle(isCheckMode ? .red : .green)
                }
            }
        }
        .alert("이 쿠폰을 완전히 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                if let selected = selectedGifticon {
                    deletedGifticons.removeAll { $0.id == selected.id }
                    print("\(selected.productName) 영구 삭제됨")
                }
                showDeleteAlert = false
                selectedGifticon = nil
            }
            Button("취소", role: .cancel) {
                showDeleteAlert = false
                selectedGifticon = nil
            }
        } message: {
            Text("해당 쿠폰은 완전히 삭제되며 복구할 수 없습니다")
        }
        .alert("이 쿠폰을 복구하시겠습니까?", isPresented: $showRecoverAlert) {
            Button("복구", role: .none) {
                if let selected = selectedGifticon {
                    recoverGifticon(selected)
                }
                showRecoverAlert = false
                selectedGifticon = nil
            }
            Button("취소", role: .cancel) {
                showRecoverAlert = false
                selectedGifticon = nil
            }
        } message: {
            Text("해당 쿠폰은 내쿠폰함으로 복구됩니다")
        }
        .alert("모든 쿠폰을 복구하시겠습니까?", isPresented: $showRecoverAllAlert) {
            Button("복구", role: .none) {
                recoverAllGifticons(confirmed: true)
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("\(deletedGifticons.count)개의 쿠폰이 모두 내쿠폰함으로 복구됩니다")
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .overlay(
            // 복구 토스트 메시지
            ZStack {
                if showRecoveryToast {
                    VStack {
                        Text("\(recoveryToastMessage)")
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 3)
                            .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .zIndex(1)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showRecoveryToast)
                }
            }
        )
        // 탭 변경 감지 및 체크모드 리셋
        .onChange(of: currentTab) { oldValue, newValue in
            if newValue != 2 && isCheckMode {
                // 다른 탭으로 이동했을 때 체크 모드 초기화
                isCheckMode = false
                selectedGifticon = nil
            }
        }
    }
}

#Preview {
    TrashView(deletedGifticons: .constant([]), currentTab: .constant(2))
}
