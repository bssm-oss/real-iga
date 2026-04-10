
# ㄹㅇ이가 (real-iga)

> 키보드 단축어 자동 치환 macOS 앱

`f` 또는 `ㄹ` 을 누르면 자동으로 **ㄹㅇ이가** 로 바뀝니다.

---

## 요구사항

- macOS 12 이상
- Xcode 15 이상
- 접근성 권한 (손쉬운 사용)

---

## 설치 방법

### 방법 1. 바로 다운로드해서 실행

1. GitHub **Releases** 에서 `real-iga.zip` 을 다운로드합니다.
2. 압축을 해제한 뒤 `real-iga.app` 을 실행합니다.
3. 처음 실행 시 접근성 권한 요청이 뜨면 허용합니다.

macOS에서 다운로드한 앱이 바로 열리지 않으면 다음 순서로 실행하세요.

```bash
xattr -cr /Applications/real-iga.app
open /Applications/real-iga.app
```

압축을 푼 뒤 `real-iga.app` 을 `Applications` 폴더로 옮긴 다음 위 명령을 실행하면 됩니다.

### 방법 2. 소스코드로 빌드

#### 1. 클론

```bash
git clone https://github.com/bssm-oss/real-iga.git
cd real-iga
```

#### 2. Xcode에서 열기

```bash
open real-iga.xcodeproj
```

#### 3. 빌드 및 실행

```text
Xcode → Product → Run (⌘R)
```

#### 4. 접근성 권한 부여

```text
시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용
→ real-iga 토글 ON
```

권한을 허용한 뒤 앱 팝오버에서 **권한 다시 확인** 버튼을 누르면 바로 다시 확인할 수 있습니다.

#### 5. 앱 파일로 보관해서 실행

```text
Xcode → Products → real-iga.app 우클릭 → Show in Finder
```

필요하면 `Applications` 폴더로 옮긴 뒤 일반 앱처럼 실행하면 됩니다.

---

## 작동 방식

1. macOS `CGEvent.tapCreate` 로 전역 키보드 이벤트 감지
2. `에프` (영문) 또는 `ㄹ` (한글) 입력 감지 시 이벤트 차단
3. 클립보드에 `ㄹㅇ이가` 저장 후 `Cmd+V` 로 붙여넣기
4. 메뉴 막대 팝오버에서 활성화/비활성화 상태와 접근성 권한 상태 확인

---

## 주의사항

- **App Sandbox 비활성화** 필요 (CGEventTap 사용을 위해)
- 접근성 권한을 준 뒤에도 동작하지 않으면 앱 팝오버에서 **권한 다시 확인**을 눌러주세요.
- 개ㅂㄹㅇ이가 하기 ㅂㄹㅇ이가 편ㅎㄹㅇ이가  수도 있으

## 혹시 몰라 남겨두는 종료 스크립트
- pkill real-iga
