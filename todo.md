# 프로젝트 개요: Godot 4 기반 뱀서류(Survivors-like) 게임 프로토타입

## 1. 프로젝트 목표
- **장르:** 2D 탑다운 서바이벌 (뱀서류)
- **엔진:** Godot 4.x (GDScript 사용)
- **전제 조건:** 외부 유료 에셋 없이 Godot 기본 노드와 AI 생성 코드로만 구동되는 MVP(최소 기능 제품) 제작

## 2. 핵심 구현 단계 (Phase 1)
Claude Code는 다음 구조를 순차적으로 생성한다.

### Step 1: 프로젝트 초기화
- `project.godot` 파일 생성 (기본 2D 설정, 창 크기 1280x720)
- 기본 에셋이 없을 경우를 대비해 `ColorRect` 또는 `Polygon2D`를 사용하여 임시 그래픽 구현

### Step 2: 플레이어(Player) 시스템
- **노드 구조:** `CharacterBody2D` > `Sprite2D` (또는 ColorRect) > `CollisionShape2D`
- **스크립트 기능 (`player.gd`):**
    - WASD 8방향 이동 (Vector2.normalized 사용)
    - 화면 밖으로 나가지 않도록 제한 (Clamping)
    - 기본 체력(HP) 및 경험치(XP) 변수 선언

### Step 3: 적(Enemy) 시스템
- **노드 구조:** `CharacterBody2D` > `ColorRect` (빨간색) > `CollisionShape2D`
- **스크립트 기능 (`enemy.gd`):**
    - 플레이어 위치를 실시간으로 추적하여 이동
    - 플레이어와 충돌 시 데미지 전달 로직 (기초)

### Step 4: 무기 및 발사체(Projectile)
- **노드 구조:** `Area2D` > `ColorRect` > `CollisionShape2D`
- **스크립트 기능:**
    - 가장 가까운 적을 자동으로 타겟팅하여 발사
    - 적과 충돌 시 적 제거(queue_free)

### Step 5: 메인 씬(Main Scene) 구성
- `Main.tscn` 생성 및 플레이어 배치
- `Timer` 노드를 활용한 적 스포너(Spawner) 구현 (플레이어 주변 랜덤 위치 생성)

## 3. Claude Code에게 내리는 첫 번째 명령 (Prompt)
"위 가이드라인을 바탕으로 Godot 4 프로젝트의 기초 파일들을 생성해줘. 
1. 별도의 이미지 파일이 없으니 플레이어는 파란색 사각형(ColorRect), 적은 빨간색 사각형으로 만들어줘.
2. 플레이어가 WASD로 움직이고, 적들이 플레이어를 따라오게 해줘.
3. 1초마다 적이 생성되는 스포너를 포함한 `main.tscn`을 만들어줘.
4. 모든 코드는 주석을 달아서 설명해줘."

---
## 4. 추후 확장 계획 (Phase 2)
- 경험치 보석 드랍 및 습득 시스템
- 레벨업 시 스킬 선택 UI (CanvasLayer)
- 대량의 적 처리를 위한 PhysicsServer 최적화
