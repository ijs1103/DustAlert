
# 😷 미세먼지 알리미

## 🧩 개요

`한국환경공단_에어코리아_대기오염정보` api를 활용한 미세먼지의 오염도를 조회할 수 있는 알림앱입니다.


## 🛠 주요 특징 

- MVC 패턴을 적용하여 관심사를 분리하였습니다. 

- 클라이언트에서 생기는 상태들을 `UserDefaults`로 저장하였습니다.

- HTML의 `<select>, <option> 태그 ui`를 Swift의 `UIPickerView`와 `UITextField`로 구현하였습니다.

- 사용 라이브러리 : `Alamofire, SnapKit, UserDefaults`

## 📕 기능 목록

|                                  기능                                                                                          |
| :----------------------------------------------------------------------: |
|               내 지역 미세먼지 조회               | 
전국 미세먼지 조회 | 
즐겨찾기한 미세먼지 조회 | 
위험지역 조회 | 

## ✨ 시연 화면

### 내 지역 미세먼지 조회

![Simulator Screen Recording - iPhone 13 mini - 2023-02-24 at 00 50 05](https://user-images.githubusercontent.com/42196410/220959152-2cc145f0-6bac-4f7b-898c-e402aa0d867a.gif)

### 전국 미세먼지 조회

![Simulator Screen Recording - iPhone 13 mini - 2023-02-24 at 00 51 15](https://user-images.githubusercontent.com/42196410/220959403-9dd00156-1f2d-430c-bd6e-4d3ef73ce0ce.gif)

### 즐겨찾기한 미세먼지 조회
![Simulator Screen Recording - iPhone 13 mini - 2023-02-24 at 01 00 09](https://user-images.githubusercontent.com/42196410/220963861-dbeb0be4-7cf6-4c4c-88c5-0188c269f4b6.gif)

### 위험지역 조회
![Simulator Screen Recording - iPhone 13 mini - 2023-02-24 at 00 59 14](https://user-images.githubusercontent.com/42196410/220961661-fa70c2e7-87c6-42c6-8166-cd88ee942df5.gif)

## 🤔 고민한 내용

✅ XIB를 UITableViewCell로 사용한 이유 

1. 재사용성이 좋습니다. 
2. 필요할 때 로드되고, 그 외에는 메모리를 사용하지 않는 lazy 속성을 가지고 있습니다. 다만, 로드시 지연이 생길 수 있습니다.
3. 모듈로 사용되니 테스트, 디버그시에 유리합니다.

✅ 데이터 및 서버 통신을 관리하는 클래스는 싱글톤 패턴을 적용한 이유

해당 클래스는 앱이 실행되는 동안, 하나의 객체로써 메모리에 존재해야하고 다양한 클래스에서 호출되기 때문입니다. 

✅ UINavigationBar 커스터마이징 및 전역적으로 적용하기

[공식문서: Customizing the appearance of UINavigationBar](https://developer.apple.com/documentation/technotes/tn3106-customizing-uinavigationbar-appearance)를 참고하였습니다.

✅ UIActivityIndicatorView와 UIRefreshControl 적용하기

데이터를 fetch, re-fetch 할 때 `UIActivityIndicatorView`와 `UIRefreshControl`를 적용하여 유저경험을 향상시켰습니다. 

✅ Api key 은닉

Api key가 담긴 파일은 `.gitignore`로 숨겨두었습니다

## 🔗 링크

[앱스토어](https://nextjs-twiiter.vercel.app/)

[트러블 슈팅](https://github.com/ijs1103/DustAlert/wiki)





