
# ㄹㅇ이가 (real-iga)

> 키보드 단축어 자동 치환 macOS 앱

`f` 또는 `ㄹ` 을 누르면 자동으로 **ㄹㅇ이가** 로 바뀝니다.

---

## 요구사항

- macOS 12 이상
- Xcode 14 이상
- 접근성 권한 (손쉬운 사용)

---

## 설치 방법

### 1. 클론

```bash
git clone https://github.com/YOUR_USERNAME/real-iga.git
cd real-iga
```

### 2. Xcode에서 열기

```bash
open real-iga.xcodeproj
```

### 3. 빌드

```
Xcode → Product → Build (⌘B)
```

### 4. 접근성 권한 부여

```
시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용
→ real-iga 토글 ON
```

### 5. 실행

```bash
/Users/YOUR_USERNAME/Library/Developer/Xcode/DerivedData/real-iga-xxxx/Build/Products/Debug/real-iga.app/Contents/MacOS/real-iga
```

편하게 실행하려면 alias 등록:

```bash
echo 'alias real-iga="nohup /Users/YOUR_USERNAME/Library/Developer/Xcode/DerivedData/real-iga-xxxx/Build/Products/Debug/real-iga.app/Contents/MacOS/real-iga > /dev/null 2>&1 &"' >> ~/.zshrc && source ~/.zshrc
```

이후 터미널에서:

```bash
real-iga
```

---

## 작동 방식

1. macOS `CGEvent.tapCreate` 로 전역 키보드 이벤트 감지
2. `에프` (영문) 또는 `ㄹ` (한글) 입력 감지 시 이벤트 차단
3. 클립보드에 `ㄹㅇ이가` 저장 후 `Cmd+V` 로 붙여넣기
4. 

---

## 주의사항

- **App Sandbox 비활성화** 필요 (CGEventTap 사용을 위해)
- Xcode가 아닌 **빌드된 .app을 직접 실행**해야 정상 작동
- 개ㅂㄹㅇ이가 하기 ㅂㄹㅇ이가 편ㅎㄹㅇ이가  수도 있으

## 혹시 몰라 남겨두는 종료 스크립트
- pkill real-iga
