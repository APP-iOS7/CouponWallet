//
//  ExpiredView.swift
//  CouponWallet
//
//  Created by 조영민 on 3/6/25.
//

import SwiftUI
import SwiftData

enum GifticonStatus: String, CaseIterable {
    case used = "사용 완료"
    case expired = "만료"
}

struct ExpiredView: View {
    // 날짜 정렬 기준 (true: 최신순, false: 오래된 순)
    @State private var sortByDateDesc: Bool = true
    // 삭제 확인 알림창을 표시할지 여부
    @State private var showDeleteAlert: Bool = false
    // 선택한 상태 필터 (전체 / 사용 완료 / 만료)
    @State private var selectedGifticonStatusFilter: String = "전체"
    // 체크 모드 - 삭제 -> 휴지통이동
    @State private var isCheckMode: Bool = false
    // 선택한 기프티콘들 - 다중 선택을 위해 배열로 변경
    @State private var selectedGifticons: Set<UUID> = []
    // 삭제된 기프티콘 목록을 부모 뷰(ContentView)에서 전달받음
    @Binding var deletedGifticons: [Gifticon]
    @Binding var currentTab: Int
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    // 만료되었거나 사용된 기프티콘을 SwiftData에서 가져옴
    @Query private var expiredGifticons: [Gifticon]
    
    // 상태 필터 배열 (전체, 사용 완료, 만료)
    let gifticonStatusFilter: [String] = ["전체"] + GifticonStatus.allCases.map { $0.rawValue }
    
    init(deletedGifticons: Binding<[Gifticon]>, currentTab: Binding<Int>) {
        self._deletedGifticons = deletedGifticons
        self._currentTab = currentTab
        
        let now = Date()
        // 쿼리: 만료되었거나 사용된 기프티콘 필터링
        let predicate = #Predicate<Gifticon> { gifticon in
            gifticon.isUsed || gifticon.expirationDate <= now
        }
        _expiredGifticons = Query(filter: predicate, sort: [SortDescriptor(\.expirationDate)])
    }
    
    // isUsed 및 expirationDate를 기반으로 상태 결정
    func determineGifticonStatus(_ gifticon: Gifticon) -> String {
        if gifticon.isUsed {
            return GifticonStatus.used.rawValue
        } else if gifticon.expirationDate <= Date() {
            return GifticonStatus.expired.rawValue
        } else {
            return ""
        }
    }
    
    // 필터 적용 -> 전체, 사용 완료, 만료
    var filteredGifticons: [Gifticon] {
        expiredGifticons.filter { gifticon in
            let status = determineGifticonStatus(gifticon)
            return selectedGifticonStatusFilter == "전체" || status == selectedGifticonStatusFilter
        }
    }
    
    // 정렬된 기프티콘 목록 반환
    var sortedGifticons: [Gifticon] {
        filteredGifticons.sorted {
            sortByDateDesc ? $0.expirationDate > $1.expirationDate : $0.expirationDate < $1.expirationDate
        }
    }
    
    // 선택된 기프티콘 개수
    var selectedCount: Int {
        return selectedGifticons.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    ForEach(gifticonStatusFilter, id: \.self) { filter in
                        FilterButton(title: filter, isSelected: filter == selectedGifticonStatusFilter) {
                            selectedGifticonStatusFilter = filter
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                if sortedGifticons.isEmpty {
                    Spacer()
                    Text("표시할 만료된 쿠폰이 없습니다")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            // 정렬된 기프티콘 리스트 사용
                            ForEach(sortedGifticons) { gifticon in
                                ZStack(alignment: .topTrailing) { // 정렬을 topTrailing으로 변경
                                    // 대홍 코드 추가 수정 시작
                                    NavigationLink(destination: SelectExpiredCouponView(selectedGifticon: gifticon)) {
                                    // 대홍 코드 추가 수정 끝
                                        GifticonCard(gifticon: gifticon, status: determineGifticonStatus(gifticon))
                                    }
                                    
                                    if isCheckMode {
                                        Button {
                                            toggleSelection(gifticon)
                                        } label: {
                                            Image(systemName: isSelected(gifticon) ? "checkmark.circle.fill" : "circle")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                // 쿠폰이 선택되면 red로 색상 변경
                                                .foregroundColor(isSelected(gifticon) ? .red : .gray)
                                                .background(Circle().fill(Color.white).opacity(0.8))
                                                .clipShape(Circle())
                                        }
                                        .padding([.top, .trailing], 10) // 상단과 오른쪽에 여백 추가
                                    }
                                }
                            }
                        }
                        .padding()
                    }

                    if isCheckMode && selectedCount > 0 {
                        Button {
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("\(selectedCount)개 삭제")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
            }
            .navigationTitle("사용·만료")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        sortByDateDesc.toggle()
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    // 체크 모드 활성화를 통해 선택한 쿠폰을 휴지통으로 보냄
                    Button {
                        isCheckMode.toggle()
                        // 체크 모드 종료시 선택 초기화
                        if !isCheckMode {
                            selectedGifticons.removeAll()
                        }
                    } label: {
                        Image(systemName: isCheckMode ? "xmark.circle" : "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            .alert("선택한 쿠폰 삭제", isPresented: $showDeleteAlert) {
                Button("삭제", role: .destructive) {
                    deleteSelectedGifticons()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("선택한 \(selectedCount)개의 쿠폰이 휴지통으로 이동됩니다.")
            }
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        // 탭 변경 감지 및 체크모드 리셋
        .onChange(of: currentTab) { oldValue, newValue in
            if newValue != 1 && isCheckMode {
                // 다른 탭으로 이동했을 때 체크 모드 초기화
                isCheckMode = false
                selectedGifticons.removeAll()
            }
        }
    }
    
    // 선택 여부 확인 함수
    private func isSelected(_ gifticon: Gifticon) -> Bool {
        return selectedGifticons.contains(gifticon.id)
    }
    
    // 선택/해제 토글 함수
    private func toggleSelection(_ gifticon: Gifticon) {
        if selectedGifticons.contains(gifticon.id) {
            selectedGifticons.remove(gifticon.id)
        } else {
            selectedGifticons.insert(gifticon.id)
        }
    }
    
    // 선택된 기프티콘 모두 삭제
    private func deleteSelectedGifticons() {
        for gifticon in sortedGifticons {
            if selectedGifticons.contains(gifticon.id) {
                // 휴지통에 저장하기 위해 추가
                deletedGifticons.append(gifticon)
                // 모델 컨텍스트에서 삭제
                modelContext.delete(gifticon)
            }
        }
        
        try? modelContext.save()
        print("\(selectedCount)개의 기프티콘 삭제됨")
        
        // 삭제 후 선택 초기화
        selectedGifticons.removeAll()
    }
}

// 필터 버튼
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? (colorScheme == .dark ? Color.white : Color.black) : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? (colorScheme == .dark ? .black : .white) : (colorScheme == .dark ? .white : .black))
                .cornerRadius(20)
        }
    }
}

// 기프티콘 카드
struct GifticonCard: View {
    let gifticon: Gifticon
    var status: String? // 대홍 let을 var로 수정 3월10일 오후
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                if !gifticon.imagePath.isEmpty {
                    AsyncImage(url: URL(string: gifticon.imagePath)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                    .frame(height: 100)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 100)
                        .overlay(
                            Text(gifticon.brand)
                                .foregroundColor(.gray)
                        )
                }
                
                // "available"이 아닐 때만 상태 표시
                if let status = status, status != "available" && !status.isEmpty {
                    Text(status)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(status == "사용 완료" ? Color.blue.opacity(0.7) : Color.gray.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(8)
                        .position(x: 140, y: 10)
                }
            }
            
            // 브랜드를 메인 타이틀로 표시
            Text(gifticon.brand)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.primary)
            
            Text("\(gifticon.formattedExpiryDate) 까지")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

extension Int {
    var formattedWithComma: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

#Preview {
    ExpiredView(deletedGifticons: .constant([]), currentTab: .constant(1))
}
