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

> **핵심 규칙: `main` 브랜치에서 직접 작업하지 않습니다!**
> 각자 본인 브랜치를 만들어서 작업하고, 완성되면 Pull Request로 합칩니다.

### 왜 브랜치를 나눠서 작업하나요?

```
나쁜 예 (전부 main에서 작업):
  철수가 player.gd 수정 중... 영희도 player.gd 수정 중...
  → 둘 다 push하면 코드가 꼬임! 💥

좋은 예 (각자 브랜치):
  철수: feature/new-enemy 브랜치에서 작업
  영희: feature/boss-system 브랜치에서 작업
  → 각자 완성 후 Pull Request로 합치기 ✅
```

---

### STEP 0: 사전 준비 (처음 한 번만)

#### Git 설치

1. https://git-scm.com/downloads 에서 Git을 다운로드합니다
2. 설치할 때 모든 옵션은 기본값(Next)으로 진행합니다
3. 설치 완료 후 터미널(명령 프롬프트)을 엽니다
4. 아래 명령어로 설치를 확인합니다:

```bash
git --version
# git version 2.xx.x 처럼 나오면 성공!
```

#### GitHub 계정

1. https://github.com 에서 계정을 만듭니다
2. 팀원에게 GitHub 아이디를 알려줍니다
3. 저장소 관리자가 **Settings → Collaborators → Add people**에서 초대합니다
4. 이메일로 온 초대를 **Accept** 합니다

---

### STEP 1: 프로젝트 처음 받기 (처음 한 번만)

터미널(명령 프롬프트)을 열고 아래를 순서대로 입력합니다:

```bash
# 1. 원하는 폴더로 이동 (예: 바탕화면)
cd Desktop

# 2. 프로젝트 다운로드
git clone https://github.com/YOUR_USERNAME/chef-nightmare.git

# 3. 프로젝트 폴더로 이동
cd chef-nightmare

# 4. 내 이름과 이메일 설정 (GitHub 계정과 동일하게)
git config user.name "내이름"
git config user.email "내이메일@example.com"
```

> 여기까지 하면 초기 설정 끝! 다음부터는 STEP 2부터 반복합니다.

---

### STEP 2: 작업 시작하기 (매번 반복)

#### 2-1. 최신 코드 받기

작업을 시작하기 전에 **반드시** 최신 코드를 받습니다:

```bash
# main 브랜치로 이동
git checkout main

# 최신 코드 다운로드
git pull origin main
```

#### 2-2. 내 브랜치 만들기

**절대 main에서 바로 작업하지 마세요!** 반드시 새 브랜치를 만듭니다:

```bash
# 새 브랜치 만들기 (이름 규칙: feature/기능이름)
git checkout -b feature/내가만들기능

# 예시:
git checkout -b feature/new-enemy-type
git checkout -b feature/sound-effects
git checkout -b feature/boss-system
git checkout -b fix/player-speed-bug
```

> `git checkout -b`는 "새 브랜치를 만들고 그 브랜치로 이동해줘"라는 뜻입니다.

#### 2-3. 내가 어떤 브랜치에 있는지 확인

```bash
git branch
# * feature/new-enemy-type   ← 별표(*)가 현재 브랜치
#   main
```

> 별표(*)가 main이 아닌 내 브랜치를 가리키고 있으면 OK!

---

### STEP 3: 작업하기

Godot 에디터에서 자유롭게 작업합니다. (씬 수정, 스크립트 수정, 에셋 추가 등)

작업 중간중간에 저장(커밋)하는 습관을 들이세요:

```bash
# 1. 어떤 파일이 변경됐는지 확인
git status

# 2-A. 변경된 파일 전체 추가 (간편한 방법)
git add .

# 2-B. 또는 특정 파일만 추가 (신중한 방법)
git add scripts/enemy.gd
git add scenes/enemy.tscn

# 3. 커밋 (저장)
git commit -m "기능: 새로운 적 타입 추가"
```

> 커밋은 "세이브 포인트"라고 생각하세요. 자주 할수록 좋습니다!

#### 커밋 메시지 쓰는 법

```
기능: 새로운 기능을 추가했을 때     예) "기능: 보스 몬스터 추가"
수정: 버그를 고쳤을 때             예) "수정: 플레이어 벽 통과 버그 해결"
개선: 기존 기능을 더 좋게 만들 때   예) "개선: 적 이동 속도 밸런스 조정"
에셋: 이미지나 사운드를 추가할 때   예) "에셋: 보스 스프라이트 추가"
문서: 문서를 수정할 때             예) "문서: README 업데이트"
```

---

### STEP 4: 내 작업을 GitHub에 올리기

작업이 완성되면 (또는 중간 백업하고 싶으면) GitHub에 올립니다:

```bash
# 내 브랜치를 GitHub에 업로드
git push origin feature/내가만들기능

# 예시:
git push origin feature/new-enemy-type
```

> 처음 push할 때 GitHub 로그인 창이 뜰 수 있습니다. 로그인하면 됩니다.

---

### STEP 5: Pull Request 만들기 (코드 합치기 요청)

내 작업이 완성되면, main에 합쳐달라고 **Pull Request(PR)**를 만듭니다:

1. 브라우저에서 GitHub 저장소 페이지에 접속합니다
2. 상단에 **"Compare & pull request"** 노란 버튼이 보입니다 → 클릭!
3. 아래 내용을 작성합니다:

```
제목: 기능: 새로운 적 타입 추가

설명:
- 빠른 적(FastEnemy) 추가
- 기존 적보다 2배 빠르지만 HP가 낮음
- enemy_fast.tscn, enemy_fast.gd 파일 추가
```

4. **"Create pull request"** 버튼을 클릭합니다
5. 팀원들이 코드를 확인(리뷰)합니다
6. 문제 없으면 **"Merge pull request"** 버튼으로 main에 합칩니다

```
[ 내 브랜치 ] ──PR 생성──> [ 팀원 리뷰 ] ──승인──> [ main에 합침 ] ✅
```

---

### STEP 6: 합친 후 정리

PR이 합쳐진(Merged) 후에는:

```bash
# 1. main 브랜치로 돌아가기
git checkout main

# 2. 합쳐진 최신 코드 받기
git pull origin main

# 3. 다 쓴 내 브랜치 삭제 (선택사항, 정리용)
git branch -d feature/new-enemy-type

# 4. 다음 작업을 위해 새 브랜치 만들기 (STEP 2로 돌아감)
git checkout -b feature/다음기능이름
```

---

### 자주 하는 실수와 해결법

#### "실수로 main에서 작업해버렸어요!"

```bash
# 아직 커밋 안 했으면:
git stash                           # 변경 내용 임시 저장
git checkout -b feature/새브랜치      # 새 브랜치 만들기
git stash pop                       # 임시 저장한 내용 복원
# → 이제 새 브랜치에서 작업이 계속됩니다!
```

#### "다른 사람 브랜치를 받아보고 싶어요"

```bash
git fetch origin
git checkout feature/팀원브랜치이름
```

#### "push했는데 에러가 나요!"

```bash
# 보통 원인: 다른 사람이 같은 브랜치에 먼저 push한 경우
git pull origin feature/내브랜치이름
# 충돌이 있으면 해결 후:
git add .
git commit -m "수정: 충돌 해결"
git push origin feature/내브랜치이름
```

#### "충돌(Conflict)이 발생했어요!"

파일을 열면 이런 표시가 보입니다:

```
<<<<<<< HEAD
var speed = 200    ← 내가 수정한 코드
=======
var speed = 150    ← 상대방이 수정한 코드
>>>>>>> main
```

해결 방법:
1. 둘 중 맞는 코드를 남기고 나머지를 지웁니다 (<<<, ===, >>> 표시도 모두 삭제)
2. 저장합니다
3. 아래 명령어를 실행합니다:

```bash
git add .
git commit -m "수정: 충돌 해결"
```

---

### 브랜치 이름 규칙

| 접두사 | 용도 | 예시 |
|--------|------|------|
| `feature/` | 새 기능 추가 | `feature/boss-monster` |
| `fix/` | 버그 수정 | `fix/collision-bug` |
| `asset/` | 에셋 추가 | `asset/new-sprites` |
| `docs/` | 문서 수정 | `docs/readme-update` |

---

### 전체 흐름 요약

```
1. git checkout main              ← main으로 이동
2. git pull origin main           ← 최신 코드 받기
3. git checkout -b feature/xxx    ← 내 브랜치 만들기
4. (Godot에서 작업)               ← 코드 수정
5. git add .                      ← 변경 파일 추가
6. git commit -m "기능: xxx"      ← 저장 (세이브)
7. git push origin feature/xxx    ← GitHub에 올리기
8. GitHub에서 Pull Request 생성    ← 합치기 요청
9. 팀원 리뷰 → Merge              ← main에 합침
10. 처음으로 돌아가기 (1번부터)      ← 다음 작업 시작
```

---

### 주의사항

- **`main` 브랜치에서 직접 코드를 수정하지 마세요** (가장 중요!)
- `.godot/` 폴더는 Git에 올리지 않습니다 (`.gitignore`에서 자동 제외)
- 작업 전 항상 `git pull`로 최신 코드를 받으세요
- 커밋은 자주, 작은 단위로 하세요 (한 번에 너무 많이 바꾸지 않기)
- 큰 이미지/사운드 파일은 [Git LFS](https://git-lfs.github.com/) 사용을 권장합니다

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
