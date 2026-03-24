# Godot Survivors Phase 2 Planning Document

> **Summary**: 뱀서류 게임 성장 시스템 — XP 보석, 레벨업 스킬 선택, 스탯 강화, HUD
>
> **Project**: chef-nightmare
> **Version**: 0.2.0
> **Author**: AI + User
> **Date**: 2026-03-24
> **Status**: Draft
> **Method**: Plan Plus (Brainstorming-Enhanced PDCA)
> **Prerequisite**: godot-survivors-mvp (Phase 1, Match Rate 99%)

---

## Executive Summary

| Perspective | Content |
|-------------|---------|
| **Problem** | Phase 1 MVP는 핵심 루프만 있고 성장 요소가 없어 리플레이 가치가 부족하다 |
| **Solution** | XP 보석 드랍/습득 → 레벨업 → 스킬 선택 UI로 클래식 뱀서류 성장 루프 구현 |
| **Function/UX Effect** | 적 처치마다 보석 드랍, XP 바 채움, 레벨업 시 3개 스킬 중 선택, HP/XP 바 HUD로 시각적 피드백 |
| **Core Value** | 성장과 선택이 있는 리플레이 가능한 서바이벌 루프로 게임성 완성 |

---

## 1. User Intent Discovery

### 1.1 Core Problem

Phase 1 MVP에는 이동→공격→생존 루프만 있고, 성장 시스템이 없어 반복 플레이 동기가 부족하다. 뱀서류 장르의 핵심인 "처치→보상→성장→더 강한 적" 루프를 추가해야 한다.

### 1.2 Target Users

| User Type | Usage Context | Key Need |
|-----------|---------------|----------|
| 게임 플레이어 | MVP를 반복 플레이 | 성장감, 선택의 재미, 시각적 피드백 |
| 개발자(본인) | Phase 3+ 확장 개발 기반 | 스킬 시스템 확장 가능 구조 |

### 1.3 Success Criteria

- [ ] 적 처치 시 초록색 XP 보석이 드랍되고 플레이어 접촉 시 습득
- [ ] XP 바가 가득 차면 레벨업 발생, 게임 일시정지
- [ ] 3개 스킬(공격력, 발사 속도, 이동 속도) 중 1개 선택 가능
- [ ] 선택 후 스탯이 즉시 적용되고 게임 재개
- [ ] HP 바, XP 바, 레벨 표시가 화면 상단에 항상 보임

### 1.4 Constraints

| Constraint | Details | Impact |
|------------|---------|--------|
| Phase 1 코드 유지 | 기존 9개 파일 구조를 유지하며 확장 | Medium |
| 외부 에셋 없음 | UI도 Godot 기본 노드(ProgressBar, Button, Label)만 사용 | Medium |
| 게임 일시정지 | 레벨업 시 get_tree().paused = true로 일시정지 필요 | Low |

---

## 2. Alternatives Explored

### 2.1 Approach A: 클래식 뱀서류 성장 시스템 — Selected

| Aspect | Details |
|--------|---------|
| **Summary** | 적 처치 → XP 보석 드랍 → 습득 → 레벨업 → 스킬 선택 UI |
| **Pros** | 뱀서류 핵심 루프 재현, 리플레이 가치 높음, 직관적 |
| **Cons** | CanvasLayer UI 구현 필요, 스킬 밸런싱 필요 |
| **Effort** | Medium |
| **Best For** | 뱀서류 장르 정체성 확보 |

### 2.2 Approach B: 자동 성장 (패시브)

| Aspect | Details |
|--------|---------|
| **Summary** | 시간/처치 수 기반 자동 스탯 강화 |
| **Pros** | UI 없이 간단 구현 |
| **Cons** | 플레이어 선택권 없음, 리플레이 가치 낮음 |
| **Effort** | Low |
| **Best For** | 최소 구현으로 성장감만 추가할 때 |

### 2.3 Decision Rationale

**Selected**: Approach A
**Reason**: 뱀서류 장르의 핵심은 "처치→보상→선택→성장" 루프. 플레이어 선택이 없으면 뱀서류가 아니라 단순 슈팅이 됨. UI 구현 비용보다 게임성 확보가 중요.

---

## 3. YAGNI Review

### 3.1 Included (v2 Must-Have)

- [x] XP 보석 드랍 (적 처치 시 초록색 보석 생성)
- [x] XP 보석 습득 (플레이어 접촉 시 XP 획득 + 보석 제거)
- [x] 레벨업 시스템 (XP 바 → 레벨업 → 게임 일시정지)
- [x] 스킬 선택 UI (CanvasLayer, 3개 버튼)
- [x] 스탯 3종 (공격력 증가, 발사 속도 증가, 이동 속도 증가)
- [x] HUD (HP 바, XP 바, 레벨 표시)

### 3.2 Deferred (v3+ Maybe)

| Feature | Reason for Deferral | Revisit When |
|---------|---------------------|--------------|
| 다양한 적 종류 | 현재 1종으로 충분, Phase 3에서 추가 | 성장 시스템 안정화 후 |
| 다양한 무기 종류 | 현재 자동 발사체 1종, Phase 3 | 스킬 시스템 확장 시 |
| PhysicsServer 최적화 | 성능 이슈 발생 시 | 적 100+ 테스트 후 |
| 게임오버/재시작 화면 | MVP 범위 유지 | UI 시스템 안정화 후 |

### 3.3 Removed (Won't Do)

| Feature | Reason for Removal |
|---------|-------------------|
| 스킬 트리 시스템 | Phase 2에 과도함, 단순 3선택으로 충분 |
| 보석 자석 효과 (자동 흡수) | 단순 접촉으로 충분, 과도한 기능 |
| 스킬 레벨 (스킬 중첩 강화) | Phase 3에서 검토, 현재는 1회 선택 |

---

## 4. Scope

### 4.1 In Scope

- [x] `xp_gem.tscn` + `xp_gem.gd` (경험치 보석 — Area2D, 초록색 10x10)
- [x] `hud.tscn` + `hud.gd` (HP 바, XP 바, 레벨 표시 — CanvasLayer)
- [x] `level_up_ui.tscn` + `level_up_ui.gd` (스킬 선택 UI — CanvasLayer)
- [x] `player.gd` 수정 (XP 로직, 레벨업 시그널, 스탯 적용)
- [x] `enemy.gd` 수정 (처치 시 보석 드랍)
- [x] `main.gd` 수정 (HUD/LevelUpUI 연동, 일시정지 처리)
- [x] `main.tscn` 수정 (HUD, LevelUpUI 인스턴스 추가)

### 4.2 Out of Scope

- 다양한 적/무기 종류 — (Phase 3)
- PhysicsServer 최적화 — (성능 이슈 시)
- 게임오버/재시작 화면 — (Phase 3)
- 스킬 중첩/레벨 시스템 — (Phase 3)
- 사운드/이펙트 — (에셋 필요)

---

## 5. Requirements

### 5.1 Functional Requirements

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-09 | 적 처치 시 적 위치에 XP 보석(초록색) 드랍 | High | Pending |
| FR-10 | 플레이어가 XP 보석 접촉 시 XP 획득 + 보석 제거 | High | Pending |
| FR-11 | XP가 레벨업 임계값 도달 시 레벨업 발생 | High | Pending |
| FR-12 | 레벨업 시 게임 일시정지 + 스킬 선택 UI 표시 | High | Pending |
| FR-13 | 3개 스킬(공격력/발사속도/이동속도) 중 1개 선택 | High | Pending |
| FR-14 | 스킬 선택 후 스탯 즉시 적용 + 게임 재개 | High | Pending |
| FR-15 | HP 바가 화면 상단에 실시간 표시 | High | Pending |
| FR-16 | XP 바 + 레벨 숫자가 화면 상단에 실시간 표시 | High | Pending |

### 5.2 Non-Functional Requirements

| Category | Criteria | Measurement Method |
|----------|----------|-------------------|
| 호환성 | Phase 1 기존 코드와 충돌 없이 동작 | F5 실행 테스트 |
| UX | 레벨업 UI가 직관적으로 이해 가능 | 즉시 스킬 선택 가능 여부 |
| 성능 | 보석 30개 이상 동시 존재 시 60fps 유지 | Godot 프로파일러 |

---

## 6. Success Criteria

### 6.1 Definition of Done

- [ ] 모든 Functional Requirements (FR-09 ~ FR-16) 구현
- [ ] 적 처치 → 보석 드랍 → 습득 → 레벨업 → 스킬 선택 루프 동작
- [ ] HP 바, XP 바가 실시간으로 변화
- [ ] 기존 Phase 1 기능이 정상 동작 유지

### 6.2 Quality Criteria

- [ ] 레벨업 시 게임이 정확히 일시정지/재개
- [ ] 보석이 적절히 queue_free() 되어 메모리 누수 없음
- [ ] UI가 게임 화면을 가리지 않음

---

## 7. Risks and Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| CanvasLayer UI 구현 복잡도 | Medium | Medium | Godot 기본 Control 노드만 사용, 최소 디자인 |
| 게임 일시정지 시 보석/적 동작 | Medium | Low | process_mode = PROCESS_MODE_WHEN_PAUSED 설정 |
| 기존 코드와의 충돌 | High | Low | 기존 파일은 최소 수정, 신규 기능은 별도 파일 |

---

## 8. Architecture Considerations

### 8.1 Project Level Selection

| Level | Selected |
|-------|:--------:|
| **Starter** | **v** |

### 8.2 Key Decisions

| Decision | Options | Selected | Rationale |
|----------|---------|----------|-----------|
| 보석 노드 | Area2D / RigidBody2D | Area2D | 충돌 감지만 필요, 물리 불필요 |
| HUD 방식 | CanvasLayer / Control | CanvasLayer | 게임 월드와 독립적 렌더링 |
| 레벨업 UI | CanvasLayer / PopupPanel | CanvasLayer | 일시정지 중에도 입력 처리 가능 |
| XP 공식 | 고정값 / 레벨비례 | 레벨비례 (level * 20) | 난이도 곡선 자연스러움 |

### 8.3 Component Overview

```
chef-nightmare/
├── project.godot           (기존 유지)
├── scenes/
│   ├── main.tscn           (수정: HUD, LevelUpUI 추가)
│   ├── player.tscn         (기존 유지)
│   ├── enemy.tscn          (기존 유지)
│   ├── projectile.tscn     (기존 유지)
│   ├── xp_gem.tscn         [신규] Area2D 경험치 보석
│   ├── hud.tscn            [신규] CanvasLayer HP/XP 바
│   └── level_up_ui.tscn    [신규] CanvasLayer 스킬 선택
├── scripts/
│   ├── main.gd             (수정: HUD/LevelUpUI 연동)
│   ├── player.gd           (수정: XP 로직, 레벨업, 스탯)
│   ├── enemy.gd            (수정: 보석 드랍)
│   ├── projectile.gd       (기존 유지)
│   ├── xp_gem.gd           [신규] 보석 습득 로직
│   ├── hud.gd              [신규] HP/XP 바 업데이트
│   └── level_up_ui.gd      [신규] 스킬 선택 처리
```

### 8.4 Data Flow

```
[적 처치] ──queue_free()──> [XP 보석 드랍 (적 위치)]
                                    │
                                    ▼
                        [플레이어 접촉 (Area2D)]
                                    │
                                    ▼
                        [XP += gem_value] ──> [HUD XP 바 업데이트]
                                    │
                                    ▼ (xp >= xp_to_next_level)
                        [레벨업! level += 1]
                                    │
                                    ▼
                        [get_tree().paused = true]
                                    │
                                    ▼
                        [LevelUpUI 표시 (3개 스킬)]
                                    │
                                    ▼
                        [버튼 클릭 → 스탯 적용]
                                    │
                                    ▼
                        [get_tree().paused = false]
                                    │
                                    ▼
                        [HUD 업데이트 (레벨, XP 리셋)]
```

### 8.5 충돌 레이어 확장

| Layer | Name | 용도 |
|-------|------|------|
| 1 | Player | 플레이어 (기존) |
| 2 | Enemy | 적 (기존) |
| 3 | Projectile | 발사체 (기존) |
| 4 | XPGem | 경험치 보석 (신규) |

| 노드 | collision_layer | collision_mask |
|------|----------------|----------------|
| XPGem | 4 (XPGem) | 1 (Player) |

---

## 9. Convention Prerequisites

### 9.1 Applicable Conventions

- [x] Phase 1 컨벤션 유지 (snake_case 파일, PascalCase 노드)
- [x] 신규 파일도 동일 패턴 (xp_gem.gd, hud.gd, level_up_ui.gd)
- [x] 모든 코드에 한국어 주석 포함
- [x] 시그널 핸들러: `_on_{NodeName}_{signal}` 패턴

---

## 10. Next Steps

1. [ ] 설계 문서 작성 (`/pdca design godot-survivors-phase2`)
2. [ ] 구현 시작 (`/pdca do godot-survivors-phase2`)
3. [ ] Gap 분석 (`/pdca analyze godot-survivors-phase2`)

---

## Appendix: Brainstorming Log

| Phase | Question | Answer | Decision |
|-------|----------|--------|----------|
| Intent | 핵심 목표 | 성장 시스템 | XP→레벨업→스킬 선택 루프에 집중 |
| Alternatives | 성장 방식 비교 | A: 클래식 뱀서류 성장 | 플레이어 선택권이 있는 뱀서류 정체성 확보 |
| YAGNI | MVP 기능 범위 | 4개 전체 포함 | 보석+레벨업+스킬+HUD 모두 포함 |
| Validation | 아키텍처 구조 | 적절함 | 기존 구조 유지하며 신규 파일 추가 방식 확정 |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-03-24 | Initial draft (Plan Plus) | AI + User |
