# Chef Nightmare

Godot 4 기반 뱀서류(Vampire Survivors-like) 2D 탑다운 서바이벌 게임

셰프가 되어 끝없이 몰려오는 화난 식재료 몬스터들로부터 살아남으세요!

---

## 게임 소개

- **장르**: 2D 탑다운 서바이벌 (뱀서류)
- **엔진**: Godot 4.x (GDScript)
- **조작**: WASD 이동, 공격은 자동

### 게임 플레이

- 셰프 캐릭터가 WASD로 무한 맵을 자유롭게 이동
- 화난 토마토 몬스터가 끊임없이 몰려옴
- 칼 발사체가 자동으로 가장 가까운 적을 공격
- 적을 처치하면 녹색 경험치 슬라임 드랍
- 경험치를 모으면 레벨업! 3가지 스킬 중 선택
  - 공격력 증가
  - 발사 속도 증가
  - 이동 속도 증가
- 30초마다 난이도 증가 (적 속도, 스폰 빈도)
- HP가 0이 되면 게임오버 + 최고 기록 저장

---

## 실행 방법 (초보자 가이드)

### 1단계: Godot 4 다운로드

1. https://godotengine.org/download 에 접속합니다
2. **Godot Engine - Standard** 버전을 다운로드합니다
   - Windows: `Godot_v4.x-stable_win64.exe`
   - Mac: `Godot_v4.x-stable_macos.universal.zip`
3. 다운받은 파일의 압축을 풀어줍니다 (설치 과정 없음)

### 2단계: 프로젝트 다운로드

**방법 A: Git으로 클론 (추천)**

```bash
git clone https://github.com/YOUR_USERNAME/chef-nightmare.git
```

**방법 B: ZIP 다운로드**

1. 이 저장소 페이지에서 초록색 **Code** 버튼 클릭
2. **Download ZIP** 클릭
3. 다운받은 ZIP 파일의 압축을 원하는 폴더에 풀기

### 3단계: Godot에서 프로젝트 열기

1. Godot 엔진을 실행합니다
2. **프로젝트 관리자** 창이 뜨면 **가져오기(Import)** 버튼을 클릭합니다
3. 다운받은 폴더 안의 `project.godot` 파일을 선택합니다
4. **가져오기 후 편집(Import & Edit)** 버튼을 클릭합니다

### 4단계: 게임 실행

1. Godot 에디터가 열리면 키보드에서 **F5** 키를 누릅니다
   - 또는 우측 상단의 **▶ (재생)** 버튼을 클릭합니다
2. 타이틀 화면에서 **"게임 시작"** 버튼을 클릭합니다
3. WASD로 이동하며 플레이!

### 게임 종료

- 게임 창의 **X** 버튼을 클릭합니다
- 또는 Godot 에디터에서 **F8** 키 (정지 버튼)를 누릅니다

---

## 같이 작업하는 방법 (Git 협업 가이드)

### 사전 준비

1. [Git](https://git-scm.com/downloads) 설치
2. [GitHub](https://github.com) 계정 생성
3. 이 저장소를 **Fork** 하거나 **Collaborator**로 초대 받기

### 처음 시작할 때

```bash
# 1. 저장소 클론
git clone https://github.com/YOUR_USERNAME/chef-nightmare.git

# 2. 프로젝트 폴더로 이동
cd chef-nightmare

# 3. 본인 이름과 이메일 설정 (처음 한 번만)
git config user.name "내 이름"
git config user.email "내이메일@example.com"
```

### 작업 흐름 (매번 반복)

```bash
# 1. 최신 코드 가져오기 (작업 시작 전 항상 실행)
git pull origin main

# 2. 새 브랜치 만들기 (기능별로 브랜치 분리)
git checkout -b feature/새기능이름

# 3. Godot에서 작업하기
#    (파일 수정, 새 씬 추가 등...)

# 4. 변경된 파일 확인
git status

# 5. 변경 파일 스테이징 (추가)
git add scenes/새파일.tscn scripts/새파일.gd

# 6. 커밋 (변경 내용 저장)
git commit -m "기능: 새 기능 설명"

# 7. 원격 저장소에 업로드
git push origin feature/새기능이름

# 8. GitHub에서 Pull Request 생성
#    (브라우저에서 저장소 페이지 → "Compare & pull request" 클릭)
```

### 커밋 메시지 규칙

```
기능: 새로운 기능 추가
수정: 버그 수정
개선: 기존 기능 개선
에셋: 이미지/사운드 추가
문서: README 등 문서 수정
```

### 충돌 해결

다른 사람과 같은 파일을 동시에 수정했을 때:

```bash
# 1. 최신 코드 가져오기
git pull origin main

# 2. 충돌이 발생하면 해당 파일을 열어서 수동으로 수정
#    <<<<<<< HEAD
#    내 코드
#    =======
#    상대방 코드
#    >>>>>>> main

# 3. 충돌 해결 후 커밋
git add .
git commit -m "수정: 충돌 해결"
```

### 주의사항

- `.godot/` 폴더는 Git에 올리지 않습니다 (자동 생성 파일)
- 큰 이미지/사운드 파일은 [Git LFS](https://git-lfs.github.com/) 사용을 권장합니다
- 작업 전 항상 `git pull`로 최신 코드를 받으세요

---

## 프로젝트 구조

```
chef-nightmare/
├── project.godot          # Godot 프로젝트 설정
├── assets/sprites/        # 게임 이미지 에셋
├── scenes/                # 씬 파일 (.tscn)
│   ├── title_screen.tscn  # 타이틀 화면
│   ├── main.tscn          # 메인 게임 씬
│   ├── player.tscn        # 플레이어 (셰프)
│   ├── enemy.tscn         # 적 (화난 토마토)
│   ├── projectile.tscn    # 발사체 (칼)
│   ├── xp_gem.tscn        # 경험치 보석 (슬라임)
│   ├── hud.tscn           # HUD (HP/XP/시간)
│   ├── level_up_ui.tscn   # 레벨업 스킬 선택
│   └── game_over_ui.tscn  # 게임오버 화면
├── scripts/               # GDScript 파일 (.gd)
│   ├── title_screen.gd
│   ├── main.gd
│   ├── player.gd
│   ├── enemy.gd
│   ├── projectile.gd
│   ├── xp_gem.gd
│   ├── hud.gd
│   ├── level_up_ui.gd
│   └── game_over_ui.gd
└── docs/                  # 기획/설계 문서
```

---

## 기술 스택

- **엔진**: Godot 4.x
- **언어**: GDScript 2.0
- **그래픽**: 커스텀 픽셀아트 에셋
- **저장**: ConfigFile (로컬 최고 기록)

---

## 라이선스

이 프로젝트는 학습 및 포트폴리오 목적으로 제작되었습니다.
