# Godot Survivors Phase 3 Planning Document

> **Summary**: 게임 루프 완성 — 타이틀, 게임오버/재시작, 생존 시간/최고 기록, 웨이브 난이도
>
> **Project**: chef-nightmare
> **Version**: 0.3.0
> **Author**: AI + User
> **Date**: 2026-03-24
> **Status**: Draft
> **Method**: Plan Plus (Brainstorming-Enhanced PDCA)
> **Prerequisite**: Phase 1 (99%), Phase 2 (97%) 완료

---

## Executive Summary

| Perspective | Content |
|-------------|---------|
| **Problem** | Phase 2까지 성장 시스템은 있지만 게임의 시작과 끝이 없어 완성된 게임이라 할 수 없다 |
| **Solution** | 타이틀 화면, 게임오버/재시작, 생존 시간 + 최고 기록, 웨이브 난이도 증가 구현 |
| **Function/UX Effect** | 타이틀→플레이→성장→난이도 증가→게임오버→최고 기록→재시작의 완전한 게임 루프 |
| **Core Value** | "한 판 더"를 유도하는 완성된 서바이벌 게임으로, 누구에게나 보여줄 수 있는 프로토타입 |

---

## 1. User Intent Discovery

### 1.1 Core Problem

Phase 1~2까지 이동, 공격, 성장 시스템은 갖추었지만 게임의 시작 화면도 끝 화면도 없다. HP가 0이 되어도 아무 일이 일어나지 않고, 난이도 변화가 없어 긴장감이 부족하다. 완성된 게임이라 부르기 어렵다.

### 1.2 Target Users

| User Type | Usage Context | Key Need |
|-----------|---------------|----------|
| 게임 플레이어 | 처음부터 끝까지 플레이 | 명확한 시작, 목표, 결과 |
| 개발자(본인) | 완성작으로 공유/포트폴리오 | 누구나 이해할 수 있는 게임 흐름 |

### 1.3 Success Criteria

- [ ] 타이틀 화면에서 "게임 시작" 버튼으로 게임 진입
- [ ] HP 0 시 게임오버 화면 표시 + 생존 시간 + 최고 기록
- [ ] 재시작 버튼으로 게임을 처음부터 다시 시작 가능
- [ ] 시간 경과에 따라 적 스폰 빈도와 속도가 증가
- [ ] HUD에 경과 시간 실시간 표시

---

## 2. Alternatives Explored

### 2.1 Approach A: 게임 루프 완성 — Selected

| Aspect | Details |
|--------|---------|
| **Summary** | 타이틀→플레이→게임오버→재시작 루프 + 웨이브 난이도 + 기록 시스템 |
| **Pros** | 최소 구현으로 완성된 게임 경험, 리플레이 동기 부여 |
| **Cons** | 콘텐츠 양 자체는 변하지 않음 |
| **Effort** | Medium |

### 2.2 Approach B: 콘텐츠 확장 우선

| Aspect | Details |
|--------|---------|
| **Summary** | 다양한 적/무기/보스 추가 |
| **Pros** | 게임 볼륨 증가 |
| **Cons** | 게임오버/재시작 없이는 완성도 부족 |
| **Effort** | High |

### 2.3 Decision Rationale

**Selected**: Approach A
**Reason**: 게임 루프 완성이 없으면 콘텐츠를 아무리 추가해도 "완성된 게임"이 되지 않음.

---

## 3. YAGNI Review

### 3.1 Included (v3 Must-Have)

- [x] 타이틀 화면 (게임명 + 시작 버튼)
- [x] 게임오버 화면 (HP 0 시, 생존 시간 표시, 재시작 버튼)
- [x] 생존 시간 표시 (HUD 실시간 + 게임오버 시 결과)
- [x] 최고 기록 저장/표시 (ConfigFile 로컬 저장)
- [x] 웨이브 난이도 증가 (30초마다 스폰 빈도↑, 적 속도↑)

### 3.2 Deferred (v4+ Maybe)

| Feature | Reason for Deferral | Revisit When |
|---------|---------------------|--------------|
| 다양한 적 종류 | 현재 1종으로 충분 | 게임 루프 완성 후 |
| 보스전 | 웨이브 시스템 안정화 후 | Phase 4 |
| 사운드/이펙트 | 에셋 필요 | 비주얼 폴리싱 단계 |
| 스킬 중첩/레벨 시스템 | 성장 시스템 확장 | Phase 4 |
| 리더보드 (온라인) | 로컬 기록으로 충분 | 네트워크 연동 시 |

### 3.3 Removed (Won't Do)

| Feature | Reason for Removal |
|---------|-------------------|
| 설정 메뉴 (옵션) | Phase 3 범위 초과 |
| 튜토리얼 화면 | 게임이 단순하여 불필요 |
| 일시정지 메뉴 | Phase 3에서는 레벨업 UI가 사실상 일시정지 역할 |

---

## 4. Scope

### 4.1 In Scope

- [x] `title_screen.tscn` + `title_screen.gd` (타이틀 화면)
- [x] `game_over_ui.tscn` + `game_over_ui.gd` (게임오버 UI)
- [x] `project.godot` 수정 (main_scene → title_screen)
- [x] `player.gd` 수정 (died 시그널 추가)
- [x] `main.gd` 수정 (시간 추적, 웨이브, 게임오버 연동)
- [x] `hud.tscn` + `hud.gd` 수정 (TimeLabel 추가)
- [x] `main.tscn` 수정 (GameOverUI 인스턴스 추가)

### 4.2 Out of Scope

- 다양한 적/무기 종류 — (Phase 4)
- 보스전 — (Phase 4)
- 사운드/이펙트 — (에셋 필요)
- 온라인 리더보드 — (네트워크 연동)
- 설정/튜토리얼/일시정지 메뉴 — (범위 초과)

---

## 5. Requirements

### 5.1 Functional Requirements

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-17 | 타이틀 화면에서 "게임 시작" 버튼 클릭 시 Main 씬 로드 | High | Pending |
| FR-18 | HP 0 시 "died" 시그널 발생 + 게임오버 UI 표시 | High | Pending |
| FR-19 | 게임오버 UI에 생존 시간, 최고 기록 표시 | High | Pending |
| FR-20 | 재시작 버튼 클릭 시 Main 씬 리로드 (전체 초기화) | High | Pending |
| FR-21 | 최고 기록을 ConfigFile로 로컬 저장/불러오기 | Medium | Pending |
| FR-22 | HUD에 경과 시간(분:초) 실시간 표시 | High | Pending |
| FR-23 | 30초마다 적 스폰 간격 10% 감소 (최소 0.3초) | High | Pending |
| FR-24 | 30초마다 적 이동 속도 10% 증가 | High | Pending |

---

## 6. Success Criteria

### 6.1 Definition of Done

- [ ] 타이틀→플레이→게임오버→재시작 루프가 완전히 동작
- [ ] 최고 기록이 게임 종료 후에도 유지 (파일 저장)
- [ ] 웨이브 난이도가 체감 가능하게 증가
- [ ] 기존 Phase 1/2 기능이 정상 동작 유지

---

## 7. Risks and Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| 씬 전환 시 메모리 누수 | Medium | Medium | get_tree().change_scene_to_file() 사용 |
| 재시작 시 상태 잔류 | High | Medium | 씬 리로드로 완전 초기화 |
| ConfigFile 경로 이슈 | Low | Low | user:// 경로 사용 |

---

## 8. Architecture Considerations

### 8.1 Key Decisions

| Decision | Options | Selected | Rationale |
|----------|---------|----------|-----------|
| 씬 전환 방식 | change_scene / 수동 교체 | change_scene_to_file | 완전한 씬 교체로 상태 초기화 보장 |
| 기록 저장 | ConfigFile / JSON | ConfigFile | Godot 네이티브, 간단 |
| 웨이브 방식 | Timer / _process 시간 체크 | _process 시간 체크 | Timer 추가 없이 기존 delta 활용 |
| 게임오버 트리거 | player에서 직접 / 시그널 | died 시그널 | 시그널 기반 분리, 기존 패턴 유지 |

### 8.2 Component Overview

```
chef-nightmare/
├── project.godot              (수정: main_scene → title_screen)
├── scenes/
│   ├── title_screen.tscn       [신규]
│   ├── game_over_ui.tscn       [신규]
│   ├── main.tscn               (수정: GameOverUI 인스턴스)
│   ├── hud.tscn                (수정: TimeLabel 추가)
│   └── (기존 유지: player, enemy, projectile, xp_gem, level_up_ui)
├── scripts/
│   ├── title_screen.gd         [신규]
│   ├── game_over_ui.gd         [신규]
│   ├── main.gd                 (수정: 시간, 웨이브, 게임오버)
│   ├── player.gd               (수정: died 시그널)
│   ├── hud.gd                  (수정: update_time)
│   └── (기존 유지: enemy, projectile, xp_gem, level_up_ui)
```

### 8.3 Data Flow

```
[TitleScreen] ──"게임 시작"──> change_scene_to_file("main.tscn")

[Main._process] ──매 프레임──> elapsed_time += delta
                                    │
                                    ├──> HUD.update_time(elapsed_time)
                                    └──> 30초마다 웨이브 레벨 증가
                                              │
                                              ├── EnemySpawnTimer.wait_time *= 0.9
                                              └── enemy_speed_multiplier *= 1.1

[Player HP 0] ──died 시그널──> Main._on_player_died()
                                    │
                                    ├── get_tree().paused = true
                                    ├── 최고 기록 비교/저장
                                    └── GameOverUI.show_results(time, best)

[GameOverUI 재시작] ──> get_tree().paused = false
                        get_tree().reload_current_scene()
[GameOverUI 타이틀] ──> get_tree().paused = false
                        change_scene_to_file("title_screen.tscn")
```

---

## 9. Convention Prerequisites

- [x] Phase 1/2 컨벤션 유지
- [x] 신규 파일: snake_case (title_screen.gd, game_over_ui.gd)
- [x] 노드 이름: PascalCase (TitleScreen, GameOverUI)
- [x] 모든 코드에 한국어 주석 + FR 매핑

---

## 10. Next Steps

1. [ ] 설계 문서 작성 (`/pdca design godot-survivors-phase3`)
2. [ ] 구현 시작 (`/pdca do godot-survivors-phase3`)
3. [ ] Gap 분석 (`/pdca analyze godot-survivors-phase3`)

---

## Appendix: Brainstorming Log

| Phase | Question | Answer | Decision |
|-------|----------|--------|----------|
| Intent | 핵심 목표 | 완성도 있는 게임 | 게임 루프 완성에 집중 |
| Alternatives | 방식 비교 | A: 게임 루프 완성 | 루프 없이는 완성된 게임이 아님 |
| YAGNI | MVP 기능 범위 | 4개 전체 포함 | 타이틀+게임오버+시간/기록+웨이브 |
| Validation | 아키텍처 | 적절함 | 씬 전환 + ConfigFile + 시그널 패턴 |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-03-24 | Initial draft (Plan Plus) | AI + User |
