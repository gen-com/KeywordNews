# KeywordNews

관심있는 키워드에 대해 뉴스를 받아보세요 :)

## 개요

<img src="/ReadmeResources/main_screen.png" width="20%" height="40%" title="메인 화면" alt="메인 화면"></img>

[프로젝트 문서](https://gen-com.github.io/documentation/keywordnews)

관심있는 키워드에 대한 뉴스를 볼 수 있도록 합니다.

키워드로 네이버 검색을 수행하며, 키워드별 뉴스 요청은 병렬로 수행해 효율을 올립니다.

키워드와 뉴스는 기기(디스크)에 저장됩니다.

키워드와 뉴스는 중복을 허용하지 않아야 하며, 키워드는 그 자체로 뉴스는 원본 링크로 중복값을 구분합니다.

가로 방향으로 키워드를 전환하고 세로 스크롤해서 뉴스를 탐색합니다.

## 키워드와 사용자 정보

<img src="/ReadmeResources/keyword_editing.png" width="20%" height="40%" title="키워드 관리" alt="키워드 관리"></img>

키워드는 순서를 가집니다.

키워드는 삭제하거나 순서를 변경할 수 있습니다.

뉴스 보관 기간 값을 사용자 정보로 가지며, 애플리케이션 실행 때 기간을 넘은 뉴스는 삭제합니다.

뉴스의 기간을 변경하면 이를 적용합니다.

## 뉴스

<img src="/ReadmeResources/news_search.png" width="65%" height="40%" title="뉴스 검색" alt="뉴스 검색"></img>

키워드를 추가하기 위해서는 유효한 뉴스 검색 결과가 있어야 합니다.

저장한 키워드가 아닌 뉴스는 키워드를 추가하기 전까지는 디스크에 저장되지 않고 메모리에만 둡니다.

뉴스를 일관되게 사용자에게 제공하기 위해서 최초 요청 시간을 기준으로 순서를 부여합니다.

원하는 뉴스를 저장 기간 상관없이 영구적으로 보관할 수 있습니다.
