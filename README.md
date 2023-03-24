# 🎬 BoxOffice

## 🪧 목차
- [📜 프로젝트 및 개발자 소개](#-프로젝트-및-개발자-소개)
- [🕹️ 주요 기능](#%EF%B8%8F-주요-기능)
- [💡 키워드](#-키워드)
- [📱 구현 화면](#-구현-화면)
- [🚀 트러블슈팅](#-트러블슈팅)
- [📁 폴더 구조](#-폴더-구조)
<br>

## 📜 프로젝트 및 개발자 소개
> **소개** : 박스오피스와 영화 상세정보를 보고, 리뷰를 남길 수 있는 iOS 앱<br> **프로젝트 기간** : 23.01.02 ~ 23.01.06 / 23.01.20 ~ 개인 리팩토링 진행 중
<br>👉 [리팩토링 전 & 협업 기록이 담긴 repo 보러가기](https://github.com/Judy-999/ios-wanted-BoxOffice)

|[Judy](https://github.com/Judy-999)|[웡빙](https://github.com/wongbingg)|
|:---:|:---:|
|<img src = "https://i.imgur.com/n304TQO.jpg" width="250" height="250"> | <img src = "https://i.imgur.com/fQDo8rV.jpg" width="250" height="250">|
|`Firestore`,`리뷰화면`, `상세화면`|`async-await`, `API`, `홈화면`| 


<br>

## 🕹️ 주요 기능
- 박스오피스 보기
	- 일일 박스오피스 & 주간/주말 박스오피스 선택
	- 보고싶은 날짜 선택
- 영화 상세정보 보기
- 영화 리뷰 남기기

<br>

## 💡 키워드
- [x] **RxSwift**
- [x] **MVVM**
- [x] **Clean Architecture**
- [x] **Firebase-Firestore**
- [x] **Custom Modal View**
- [x] **UICollectionView**
<br>

## 📱 구현 화면
### UI in Figma
> 앱을 구현하기 전 Figma를 통해 다음과 같이 디자인 계획을 세운 후 작업하였습니다.

<img src="https://user-images.githubusercontent.com/95671495/211021565-f15fbc77-67d6-4618-b177-8d1b36bb22be.png" width="500" />

<br>

### 실행 예시
	
#### 홈화면
|일별 박스오피스 화면|주간/주말 박스오피스 화면|날짜 선택|
|:---:|:---:|:---:|
|![](https://i.imgur.com/a9PLuGL.gif)|![](https://i.imgur.com/n1GLtSd.gif)|![](https://i.imgur.com/iZxXRuo.gif)|


#### 상세화면 + 리뷰화면 
|상세화면 | 리뷰 쓰기 |리뷰보기 및 삭제|
|:---:|:---:|:---:|
|![](https://i.imgur.com/BcNzkZ1.gif)|![](https://i.imgur.com/62T1Mcx.gif)|![](https://i.imgur.com/9mclOTj.gif)|

<br>

## 🚀 트러블슈팅
### 1. API Request 코드 단순화
**BoxOffice** 앱은 박스오피스와 영화 상세정보를 위한 영화진흥위원회(KOBIS)와 영화 포스터를 위한 OBDb 두 가지 API를 사용하고 있습니다. 하나의 영화 데이터(`MovieData`)를 만들기 위해서는 아래와 같이 3번의 API request가 필요합니다.

| 박스오피스 정보를 받아오는 요청 과정 |
| :--------: |
| <img src="https://i.imgur.com/ft6U0DX.png" width="400" />     |

<br>

**Observable**을 직접 구현해 MVVM 구조를 적용했을 때에는 비동기 처리르 위한 escaping closure가 이중 삼중으로 depth가 쌓여 길고 복잡한 요청 코드가 만들어졌습니다.

|하나의 메서드로 영화 정보를 받아오던 코드의 예시 |
| :--------: |
|<img src="https://i.imgur.com/eYaZ6KB.png" width="300" />|

<br>

이후 비동기처리와 효과적인 MVVM 구조를 위해 **RxSwift**를 적용한 버전으로 리팩토링하면서 **Observable** 객체를 이용해 쉽게 비동기처리를 할 수 있게 됐습니다. 우선 공통적인 작업을 하는 코드를 메서드로 분리하고 **Observable** 객체를 매개변수와 반환값으로 주고 받으며 간결하고 가독성 좋은 코드를 얻을 수 있었습니다. 
<br><br>

### 2. 복합 API 요청에 따른 영화 정보와 포스터의 일관성 유지 
 영화 데이터를 생성하기 위해서는 `박스오피스 요청 -> 영화 상세정보 요청 -> 영화 포스터 요청` 이렇게 여러 번의 API 요청이 필요합니다. 문제는 요청에 대한 응답이 비동기이기 때문에 요청한 영화 정보의 순서대로 받을 수 있다는 보장이 없어 영화와 상세정보 또는 포스터가 일치하지 않는 문제가 발생했습니다. 

| 영화와 포스터가 일치하지 않는 예시 | 
| :--------: | 
| <img src="https://i.imgur.com/pwAG2cC.jpg" width="250" />     | 

<br>각각의 요청이 독립적일 수 있도록 요청 별로 별개의 타입 (`ex. Movie, MovieInfo, Poster`)을 생성하는 구조를 고민했습니다. 하지만 메인 화면에서 박스오피스와 함께 포스터가 바로 필요하고, 포스터를 얻기 위해서는 영화 상세 정보가 필요하기 때문에 결국 복합적인 API 요청 후 데이터를 생성해야 했습니다.
<br>

```swift 
let movieInfoList = list.flatMap { boxOffice in
    MovieInfoAPI(movieCode: boxOffice.movieCd).execute()
        .compactMap { movieInfoResponseDTO in
            movieInfoResponseDTO.movieInfoResult.movieInfo
        }
}
```
문제를 해결하기 위해 연속적인 요청을 동기적으로 처리해야 하는지 고민했지만 Observable 연산자만 변경하여 해결했습니다. 영화 상세 정보를 받아오는 일부 코드를 보면 박스오피스 Observable인 `list`에 따라 영화상세정보를 요청한 결과도 Observable이기 때문에 하나의 squence로 만들기 위해 `flatMap`을 사용했습니다. 
<br>

| FlatMap Marble | ConcatMap Marble | 
| :--------: | :--------: | 
| ![](https://i.imgur.com/IPZWexu.png) | ![](https://i.imgur.com/5mlbCus.png) | 

<br>그러다 RxSwift 스터디를 통해 `concatMap` 연산자를 알게 되었습니다. `flatMap` 연산자와 유사하지만 자체 시퀀스를 생성하기 위해 결과 Observable을 병합하는 대신 연결하기 때문에 순서를 보장할 수 있습니다. 따라서 위 코드에서 `flatMap -> concatMap`으로 연산자만 변경해주니 해결되었습니다.
<br><br>

### 3. URLCache를 사용해 네트워크 요청 회수 최소화 및 로딩 속도 향상 
네트워크 요청은 고비용의 작업으로 동일한 데이터에 대해 매번 요청과 응답을 수행하면 시간과 자원이 낭비됩니다. 이전에도 요청한 이미지를 캐시한 경험이 있어 포스터의 이미지 요청에 대해서 `URLcache`를 적용했습니다. 

그럼에도 박스오피스를 요청하고 화면에 나타나기까지 로딩되는 시간이 상당히 소요되는 문제가 있었습니다. 이를 해결하기 위해 박스오피스와 영화 상세정보 요청에도 Cache를 적용했습니다.

`URLcache`에 저장할 때 `URLRequest`, `HTTPURLResponse`, `Data`가 모두 필요하므로 `URLSession`을 rx로 extension하여 세 타입을 반환하는 메서드를 구현하고, `ObservableType`을 extension하여 캐시 연산자를 구현해 모든 요청에 대해 캐시를 수행하도록 했습니다. 
<br>

| cache 적용 전 | cache 적용 후| 
| :--------: | :--------: | 
| ![](https://i.imgur.com/wnQWxDv.png)     | ![](https://i.imgur.com/5mhEOW7.png)     | 

결과적으로 네트워크 요청 횟수를 최소화하고 반복적으로 요청할 경우 박스오피스 로딩 속도가 향상되었습니다.
<br><br>

### 4. Custom Modal View 구현 
사용자에게 입력 또는 선택을 받는 화면이나 한 화면으로 한 번에 표현하지 못하는 UI 요소에 대해서는 새로운 뷰가 필요합니다. 하지만 계속 새로운 뷰를 전체 모달 뷰로 띄우면 잦은 화면 이동처럼 느껴져 피로감이 들고 좋은 UX가 아니라고 생각했습니다. 
<br>
| 모든 출연진 정보를 볼 수 있는 화면 | 날짜 선택을 위한 캘린더 화면| 일별/주간-주말 보기를 선택하는 화면 |
| :--------: | :--------: | :--------: |
|     ![](https://i.imgur.com/iuYtBek.jpg)|    ![](https://i.imgur.com/hqfrScW.jpg)|    ![](https://i.imgur.com/28ZvPKo.jpg)|

<br>

전체 화면 대신 화면 일부를 모달 형식으로 띄우기 위해 **UIPresentationController**와 **UIViewControllerTransitioningDelegate**을 이용해 Custom Modal View를 구현했습니다. 다양한 크기와 위치의 뷰를 사용해 시각적인 효과와 깔끔한 UX를 제공할 수 있었습니다.

또한 (x) 버튼을 통해 모달 화면 밖으로 나가는 방법 외에도 자연스러운 동작을 위해 **UIPanGestureRecognizer**, **UITapGestureRecognizer**를 적용했습니다. 이후 입력한 값이나 선택한 내용을 전달하기 위해 Delegate 패턴 사용했습니다.
<br><br>

### 5. 자주 쓰는 UI component를 사용자화 해서 재사용
BoxOffice는 총 3개의 주 화면을 가지고 있습니다. 코드로 UI를 구성하면서 화면마다 동일하게 사용되는 Label, Button 등이 있어 중복되는 코드가 자주 발생했습니다. 

반복적으로 사용되는 공통 UI를 Custom해서 사용했습니다. 뷰에 걸쳐 `MovieLabel`, `MovieButton`, `PosterImageView` 등을 구현해  공통적인 속성을 설정하고 AutoLayout을 적용하기 위해 `translatesAutoresizingMaskIntoConstraints = false` 로 설정 하고 인스턴스마다 다르게 가져야 할 속성은 초기화 시 받거나 메서드로 설정하도록 구현했습니다.
<br>

```swift
final class MovieLabel: UILabel {
    init(font: UIFont.TextStyle, isBold: Bool = false, frame: CGRect = .zero) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = .preferredFont(forTextStyle: font)
        
        if isBold {
            self.font = .boldSystemFont(ofSize: self.font.pointSize)
        }
    }
    // 생략
}
```

커스텀한 UI 요소를 재사용하여 코드의 길이가 줄어들고 중복을 제거해 가독성이 향상했습니다. 예시로 **GridCell** 의 경우 UI 선언 코드가 `94`줄 분량에서 `64`줄로 감소하는 효과를 얻었습니다.
<br><br>

### 6. Hugging을 조절해 UI 간격 조절
뷰를 구성할 때 비어있는 공간이 필요한 경우도 있습니다. 예를 들어 메인화면에 일별 박스오피스의 `ListCell`에서는 관람객 수와 개봉일은 상대적으로 덜 중요한 정보라 생각해 하단에 위치시키고 싶었습니다.

<br><img src="https://i.imgur.com/zx2U7Z5.png" height="200"/> 

<br>처음에는 **UIStackView**의 `alignment`나 `distribution`을 변경해도 원하는 배치가 되지 않아 결국 빈 공간을 차지하는 `fakeView`를 넣었습니다.

하지만 의미 없는 뷰를 가지는 것은 비효율적이라 생각하여 고민한 결과 Autolayout의 **Hugging Priority**를 조절하는 방법을 찾았습니다. **Hugging Priority**는 사이즈에 맞게 줄어드려는 우선순위로 즉 늘어나지 않으려고 하는 정도입니다. 원하는 배치를 위해서는 순위 변동을 표시하느 부분이 늘어나 빈 공간을 차지하면 되므로 상대적으로 priority를 낮게 설정해 해결했습니다
<br>

| Fake View 사용 방법 | Hugging Priority 조절 방법 |
| :--------: | :--------: |
| <img src="https://i.imgur.com/fEPsrv7.png" width="200" /> | <img src="https://i.imgur.com/4KsZW1w.png" width="200" /> |   

<br>

## 📁 폴더 구조
❕일부 파일은 생략되어 있습니다.
```swift
.
├── Application
│	├── AppDelegate.swift
│	└── SceneDelegate.swift
├── Data
│	├── APIs
│	│	├── DailyBoxOfficeAPI.swift
│	│	├── MovieInfoAPI.swift
│	│	├── MoviePosterAPI.swift
│	│	└── WeeklyBoxOfficeAPI.swift
│	├── DTO
│	│	├── DailyBoxOfficeDTO.swift
│	│	├── MovieInfoDTO.swift
│	│	└── MoviePosterDTO.swift
│	└── Repository
│		├── BoxOfficeRepository.swift
│		└── PosterRepository.swift
├── Domain
│	├── Entities
│	│	├── MovieData.swift
│	│	└── Review.swift
│	└── UseCase
│	 	├── BoxOffice
│	 	│	├── DailyBoxOfficeUseCase.swift
│	 	│	├── WeekendBoxOfficeUseCase.swift
│	 	│	└── WeeklyBoxOfficeUseCase.swift
│	 	└── Review
│	 	    └── ReviewFirebaseUseCase.swift
├── GoogleService-Info.plist
├── Info.plist
├── MovieInfo.plist
├── Resource
│	├── Assets.xcassets
│	└── Base.lproj
│	    └── LaunchScreen.storyboard
├── Scene
│	├── Common
│	│	├── Namespace
│	│	├── MovieButton.swift
│	│	├── MovieLabel.swift
│	│	├── PosterImageView.swift
│	│	└── RankBadgeLabel.swift
│	├── Detail
│	│	├── ActorListModalView
│	│	├── MovieDetailViewController.swift
│	│	└── SubViews
│	├── Home
│	│	├── HomeViewController.swift
│	│	├── HomeViewModel.swift
│	│	├── ModalView
│	│	│	├── CalendarModalView
│	│	│	└── ModeSelectModalView
│	│	└── SubViews
│	│		├── Cells
│	│		├── HeaderView.swift
│	│		└── HomeCollectionView.swift
│	└── Review
│	    ├── ReviewListViewController.swift
│	    ├── ReviewViewModel.swift
│	    ├── SubViews
│	    │	├── ReviewTableViewCell.swift
│	    │	└── StarRating
│	    └── WriteReviewViewController.swift
├── Service
│	├── Firebase
│	├── Network
│	└── URLCache
└── Utils
	└── Extension
```
<br>

## 🔮 개선하고 싶은 점
### 리뷰 테이블 뷰 셀 동적 크기 조절
- 현재 리뷰에 긴 글을 적었을 경우 나머지 글자가 `...`로 잘리고 있습니다. 리뷰 리스트를 보여주는 화면에서 셀의 크기를 다이나믹하게 조절할 수 있도록 개선할 예정입니다.

### 리뷰 이미지
- 현재 리뷰 이미지를 선택할 순 있지만 저장하지 않고 기본 이미지만 띄우고 있습니다. FireStorage를 통해 리뷰 이미지도 저장할 수 있도록 변경할 예정입니다.
<br><br> 

