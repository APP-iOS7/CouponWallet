# CouponWallet  
![Swift](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift)
![Platform](https://img.shields.io/badge/Platforms-iOS%2018.0+-007AFF?logo=apple)

CouponWallet은 디지털 기프티콘을 관리하기 위한 종합적인 iOS 애플리케이션입니다. 이 앱을 통해 사용자는 디지털 쿠폰을 스캔하고, 저장하고, 정리하며, 한 곳에서 편리하게 관리할 수 있습니다.

## 개요

- 프로젝트 이름: CouponWallet
- 프로젝트 기간: 3월 7일 ~ 3월 11일
- 개발 언어: Swift
- 개발 프레임워크: SwiftUI, PhotosUI, Vision, VisionKit, SwiftData
- 멤버: 김대홍, 조영민, 홍석평

## 🌟 주요 기능
### 홈 탭
- **보유 쿠폰 보기**: 사용 가능한 유효한 쿠폰을 한눈에 볼 수 있습니다
- **쿠폰 필터링**: 브랜드별로 쉽게 필터링 가능 (스타벅스, 치킨, CU, GS25 등)
- **쿠폰 추가**: 다음 방법으로 새 기프티콘을 추가할 수 있습니다:
  - 카메라 직접 스캔
  - 사진 갤러리에서 가져오기
### 사용·만료 탭
- **사용/만료된 쿠폰 보기**: 사용 이력을 추적할 수 있습니다
- **필터 옵션**: "사용 완료" 또는 "만료" 상태별로 정렬
- **다중 선택**: 여러 쿠폰을 선택하여 휴지통으로 이동
- **정렬**: 날짜별 정렬 (최신순/오래된 순)
### 설정 탭
- **프로필 설정**: 사용자 프로필 정보 관리
- **알림 설정**: 앱 알림 구성
- **테마 설정**: 라이트 모드와 다크 모드 전환
- **휴지통 관리**: 쿠폰 복구 또는 영구 삭제
## 📱 핵심 기능
### 스마트 스캐닝
앱은 Vision 및 VisionKit 프레임워크를 사용하여:
- 기프티콘 이미지에서 텍스트를 자동으로 인식
- 다음과 같은 주요 정보 추출:
  - 브랜드명
  - 상품명
  - 유효기간
- 카메라 스캔과 갤러리 이미지 모두 처리
### 직관적인 UI
- 깔끔한 카드 기반 인터페이스
- 스와이프 가능한 쿠폰 상세 정보
- 탭 기반 네비게이션
- 쿠폰 상태에 따른 컨텍스트 액션
### SwiftData를 사용한 데이터 관리
- 쿠폰 정보의 영구 저장
- 효율적인 데이터베이스 쿼리 및 정렬
- 복원 옵션이 있는 휴지통 기능
## 🔧 기술적 구현
### 사용된 프레임워크
- **SwiftUI**: 현대적인 선언적 UI
- **SwiftData**: 데이터 영속성 레이어
- **Vision/VisionKit**: OCR 및 텍스트 인식
- **PhotosUI**: 사진 라이브러리 통합
### 주요 구성 요소
- **GifticonScanManager**: OCR 및 텍스트 추출 처리
- **TextAnalyzer**: 스캔된 텍스트에서 의미 있는 데이터 파싱 및 추출
- **Gifticon Model**: 쿠폰 정보 저장을 위한 SwiftData 모델
- **사용자 정의 뷰**: 다양한 쿠폰 상태 및 작업을 위한 특수 뷰
### 사용자 경험 기능
- 쿠폰 공유를 위한 스크린샷 기능
- 쿠폰 카드 애니메이션 전환 효과
- 앨범에 있는 쿠폰 자동 스캔
## 📷 스크린샷
<p align="center">
  <img src="https://github.com/user-attachments/assets/8227419b-acc9-4d09-bd8e-f984d44caf57" width="18%" alt="홈 화면" />
  <img src="https://github.com/user-attachments/assets/a5f0a14f-c17f-4cc5-94ca-bcf3648cb1db" width="18%" alt="상세 화면" />
  <img src="https://github.com/user-attachments/assets/6a3bb6c2-3338-49a8-a477-66631edae118" width="18%" alt="설정 화면" />
  <img src="https://github.com/user-attachments/assets/45043c37-2600-4c86-ba5b-d154bf16db15" width="18%" alt="만료 화면" />
  <img src="https://github.com/user-attachments/assets/9a48daca-54cd-4295-bfd0-6ceea373557b" width="18%" alt="스캔 화면" />
</p>

## 🚀 시작하기
### 요구 사항
- iOS 18.0 이상
- Xcode 16.0 이상
- Swift 6 이상
## 🔮 향후 개선 사항
- 바코드/QR 코드 스캐닝
- 유효기간 알림
- 인기 브랜드 API와의 통합
- 소셜 공유 기능
- 통계 및 사용 분석

## 👥 역할

### 김대홍
- 쿠폰 선택 화면
- 쿠폰 카드 슬라이드 애니메이션
- 쿠폰 사용 완료 및 수정 로직 구현

### 조영민
- 기본 틀 프로젝트 제작
- PhotoPicker로 이미지 가져오기
- vision 프레임워크로 쿠폰 이미지 스캔 기능 구현

### 홍석평
- 쿠폰 공유 기능
- 쿠폰 삭제 기능
- 라이트 모드 다크 모드 구현

## 느낀 점과 개선할 점

### 김대홍

### 조영민

### 홍석평
