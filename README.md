





# Dabang Clone
>-Please check Develop Branch

패스트 캠퍼스 iOS School에서 진행했던 Backend School과의 협업 프로젝트 입니다.
## Video Link : https://youtu.be/demB9_7O5U4



## Description

- 기간 : 2020.03.20 ~ 2020.04.29
- 사용 기술
  - Language : Swift
  - Framework : UIKit, CoreLocation, RxSwift
  - Library : FBSDKCoreKit, FBSDKLoginKit, FBSDKShareKit, SnapKit, RxCocoa, RxViewController, Alamofire, Then, Kingfisher, SwiftSVG, SDWebImage, MultiSlider, SwiftyJSON, KeychainSwift, DKImagePickerController, Gedatsu, GoogleMaps
- 팀원 : 5명( iOS 4명 + Backend 1명)
- 맡은 역할 
  - 매물 비교하기 기능,
  - 최근 본 방 추가 및 삭제 기능,
  - 방 찜하기 및 찜하기 해제 기능, 
  - 최근 본 단지에 포함된 방들을 불러오는 기능을 RxSwift를 사용하여 비동기처리, 
  - 싱글톤으로 APIManager 클래스 구조 설계. 
- 성과
  + 개인적으로 처음 진행하는 Backend 개발자들과의 협업을 통해 서버와의 데이터 통신을 경험
  + Alamofire, SnapKit, SDWebImage, SwiftyJSON 등 다양한 라이브러리를 적용하여 프로젝트 생산성 향상 및 개인적인 라이브러리 사용능력 향상
  + 한가지 기능에만 부분적으로 짧게 적용하였지만 RxSwift를 이용하여 비동기처리를 경험한 최초의 프로젝트

## Design

- Flow chart : 초기 기획 단계에서 앱의 흐름과 주요 기능을 파악, UI 분석

![alt-text](https://github.com/IMSEONGJUN/iOS-DabangClone-200330/blob/develop/dabang_gif.gif)
## 협업

- Github : 최상위 Organization을 기반으로 각자 작업한 뒤 Solve Conflic -> 코드리뷰 -> 풀 리퀘스트 -> 병합 프로세스로 진행

![GitKraken.mov](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzuamg4n7g30dw0a41kz.gif)
## Implementation

### Feature

| 소셜 로그인 기능 구현 (Kakao, Apple, Facebook)               | 메인화면                                                     | 분양 정보관 구현                                             | 구글 맵 + 클러스터링,<br /> 위치 기반 매물 연동              |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| <img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzugw3665j30u01k9h81.jpg" alt="스크린샷 2020-07-22 오후 5.34.18" style="zoom:33%;" /> | <img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzug3slv7j30u01k9qv5.jpg" alt="스크린샷 2020-07-22 오후 5.34.46" style="zoom:33%;" /> | <img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzue0buygj30u01k9u0x.jpg" alt="스크린샷 2020-07-22 오후 5.37.02" style="zoom: 33%;" /> | <img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzuerp851j30u01k9hdt.jpg" alt="스크린샷 2020-07-22 오후 5.36.42" style="zoom:33%;" /> |
| 매물 비교하기 기능                                           | 분양 단지 정보                                               | 분양 단지 목록                                               | 관심 목록 기능                                               |
| <img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzuhe65ekj30u01k94qp.jpg" alt="스크린샷 2020-07-22 오후 5.36.08" style="zoom:33%;" /> | <img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzuhxaiozj30u01k9kjl.jpg" alt="스크린샷 2020-07-22 오후 5.37.54" style="zoom:33%;" /> | <img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzuj8ekjvj30u01k9kjl.jpg" alt="스크린샷 2020-07-22 오후 5.37.34" style="zoom:33%;" /> | <img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzuicluxej30u01k9e81.jpg" alt="스크린샷 2020-07-22 오후 5.36.00" style="zoom:33%;" /> |
| 프로필 관리                                                  | 주소검색                                                     | 방 내놓기 기능                                               | 방내놓기 완료                                                |
| <img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzuirhiguj30u01k9kff.jpg" alt="스크린샷 2020-07-22 오후 5.38.00" style="zoom:33%;" /> | ![스크린샷 2020-07-22 오후 6.04.55](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzv95bs17j30u01k91kx.jpg) | <img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzuleuik4j30u01k9h8w.jpg" alt="스크린샷 2020-07-22 오후 5.38.14" style="zoom:25%;" /> | ![스크린샷 2020-07-22 오후 6.05.14](https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzv8y55j4j30u01k9b29.jpg) |



- 소셜 로그인 기능 구현 (Kakao, Apple, Facebook)
<img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1ggzt8hhpwzg30dw07te08.gif" alt="login.mov" style="zoom:150%;" />





