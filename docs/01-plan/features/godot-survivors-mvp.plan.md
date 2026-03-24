# Godot Survivors MVP Planning Document

> **Summary**: Godot 4 기반 뱀서류(Survivors-like) 2D 탑다운 서바이벌 게임 MVP
>
> **Project**: chef-nightmare
> **Version**: 0.1.0
> **Author**: AI + User
> **Date**: 2026-03-24
> **Status**: Draft
> **Method**: Plan Plus (Brainstorming-Enhanced PDCA)

---

## Executive Summary

| Perspective | Content |
|-------------|---------|
| **Problem** | 외부 유료 에셋 없이 Godot 4 기본 노드만으로 플레이 가능한 뱀서류 게임을 만들어야 한다 |
| **Solution** | ColorRect 기반 임시 그래픽 + CharacterBody2D 물리 시스템으로 5단계 순차 구현 |
| **Function/UX Effect** | WASD 이동, 적 자동 스폰/추적, 자동 발사체로 즉시 플레이 가능한 서바이벌 루프 완성 |
| **Core Value** | 최소 리소스로 핵심 게임플레이 루프(이동→생존→공격)를 체험할 수 있는 완성된 프로토타입 |

---

## 1. User Intent Discovery

### 1.1 Core Problem

외부 에셋이나 디자이너 없이, Godot 4와 GDScript만으로 실제 플레이 가능한 뱀서류 게임 MVP를 제작해야 한다. 코드 생성만으로 Godot 에디터에서 바로 실행 가능한 완성된 프로젝트를 만드는 것이 목표.

### 1.2 Target Users

| User Type | Usage Context | Key Need |
|-----------|---------------|----------|
| 게임 플레이어 | Godot 에디터에서 프로젝트를 열어 직접 플레이 | 즉시 플레이 가능한 게임 루프 |
| 개발자(본인) | MVP를 기반으로 Phase 2 확장 개발 | 확장 가능한 깔끔한 코드 구조 |

### 1.3 Success Criteria

- [ ] Godot 4 에디터에서 프로젝트를 열고 F5로 바로 실행 가능
- [ ] WASD로 플레이어가 8방향 이동하며 화면 밖으로 나가지 않음
- [ ] 적이 1초마다 스폰되어 플레이어를 추적
- [ ] 자동 발사체가 가장 가까운 적을 타겟팅하여 제거
- [ ] 충돌 시 플레이어 HP 감소 로직 동작

### 1.4 Constraints

| Constraint | Details | Impact |
|------------|---------|--------|
| 외부 에셋 없음 | 이미지/사운드 없이 ColorRect, Polygon2D 등 기본 노드만 사용 | High |
| Godot 4.x 전용 | GDScript 2.0 문법 사용 (Godot 3.x 비호환) | Medium |
| 텍스트 파일 생성 | .tscn/.gd 파일을 텍스트로 직접 생성 (에디터 없이) | Medium |

---

## 2. Alternatives Explored

### 2.1 Approach A: 순수 씬 파일 직접 생성 — Selected

| Aspect | Details |
|--------|---------|
| **Summary** | .tscn과 .gd 파일을 Godot 텍스트 포맷으로 직접 생성 |
| **Pros** | Godot 에디터에서 바로 열기 가능, 씬 트리 시각화 가능, Godot 관례 준수 |
| **Cons** | .tscn 포맷의 정확한 구조를 맞춰야 함 |
| **Effort** | Medium |
| **Best For** | 최종 산출물이 Godot 프로젝트로 직접 사용될 때 |

### 2.2 Approach B: GDScript 코드 중심 + 최소 씬

| Aspect | Details |
|--------|---------|
| **Summary** | 최소 .tscn만 생성하고 노드를 _ready()에서 코드로 동적 생성 |
| **Pros** | 씬 파일 포맷 오류 위험 감소 |
| **Cons** | Godot 관례와 다름, 씬 트리 시각화 어려움, 에디터에서 수정 불편 |
| **Effort** | Low |
| **Best For** | 씬 파일 호환성이 불확실할 때 |

### 2.3 Decision Rationale

**Selected**: Approach A
**Reason**: Godot 에디터에서 바로 열어 실행할 수 있어야 하며, 씬 트리 구조가 시각적으로 보여야 이후 확장 개발이 용이. .tscn 텍스트 포맷은 잘 문서화되어 있어 직접 생성 가능.

---

## 3. YAGNI Review

### 3.1 Included (v1 Must-Have)

- [x] 플레이어 WASD 8방향 이동 + 화면 바운드 제한
- [x] 적 스폰 (1초 간격) + 플레이어 추적 이동
- [x] 적-플레이어 충돌 시 데미지 전달
- [x] 자동 발사체 (가장 가까운 적 타겟팅, 충돌 시 적 제거)
- [x] HP/XP 변수 선언 (로직 없이 변수만)

### 3.2 Deferred (v2+ Maybe)

| Feature | Reason for Deferral | Revisit When |
|---------|---------------------|--------------|
| 경험치 보석 드랍/습득 | XP 시스템은 Phase 2 | 기본 게임플레이 루프 완성 후 |
| 레벨업 스킬 선택 UI | CanvasLayer UI는 Phase 2 | XP 시스템 구현 후 |
| PhysicsServer 최적화 | 대량 적 처리 최적화는 성능 이슈 발생 시 | 적 100+ 이상 테스트 후 |

### 3.3 Removed (Won't Do)

| Feature | Reason for Removal |
|---------|-------------------|
| 사운드/BGM | 외부 에셋 없이 구현 불가, MVP에 불필요 |
| 타이틀/게임오버 화면 | MVP 범위 초과, 핵심 게임플레이에 집중 |

---

## 4. Scope

### 4.1 In Scope

- [x] `project.godot` 생성 (2D 설정, 1280x720, 입력 맵)
- [x] `player.tscn` + `player.gd` (CharacterBody2D, WASD 이동, 화면 제한, HP/XP 변수)
- [x] `enemy.tscn` + `enemy.gd` (CharacterBody2D, 플레이어 추적, 충돌 데미지)
- [x] `projectile.tscn` + `projectile.gd` (Area2D, 자동 타겟팅, 충돌 시 적 제거)
- [x] `main.tscn` + `main.gd` (메인 씬, 적 스포너 Timer, 발사체 Timer)

### 4.2 Out of Scope

- 경험치 보석 드랍/습득 시스템 — (Phase 2)
- 레벨업 스킬 선택 UI — (Phase 2)
- PhysicsServer 최적화 — (성능 이슈 시)
- 사운드/BGM — (에셋 필요)
- 타이틀/게임오버 화면 — (MVP 범위 초과)

---

## 5. Requirements

### 5.1 Functional Requirements

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-01 | 플레이어가 WASD 키로 8방향 이동 (Vector2.normalized) | High | Pending |
| FR-02 | 플레이어가 화면 밖으로 나가지 않도록 Clamping | High | Pending |
| FR-03 | 적이 1초 간격으로 플레이어 주변 랜덤 위치에 스폰 | High | Pending |
| FR-04 | 적이 플레이어 위치를 실시간 추적하여 이동 | High | Pending |
| FR-05 | 적-플레이어 충돌 시 플레이어 HP 감소 | High | Pending |
| FR-06 | 자동 발사체가 가장 가까운 적을 타겟팅하여 발사 | High | Pending |
| FR-07 | 발사체-적 충돌 시 적 제거 (queue_free) | High | Pending |
| FR-08 | HP/XP 변수 선언 (추후 확장용) | Low | Pending |

### 5.2 Non-Functional Requirements

| Category | Criteria | Measurement Method |
|----------|----------|-------------------|
| 호환성 | Godot 4.x에서 정상 실행 | F5 실행 테스트 |
| 성능 | 적 30개 이상 동시 존재 시 60fps 유지 | Godot 프로파일러 |
| 코드 품질 | 모든 코드에 한국어 주석 포함 | 코드 리뷰 |

---

## 6. Success Criteria

### 6.1 Definition of Done

- [ ] 모든 Functional Requirements 구현
- [ ] Godot 4 에디터에서 F5로 바로 실행 가능
- [ ] 게임 루프 동작 확인 (이동→적 스폰→자동 공격→적 제거)
- [ ] 코드에 한국어 주석 포함

### 6.2 Quality Criteria

- [ ] .tscn 파일이 Godot 4 포맷에 정확히 일치
- [ ] 충돌 레이어/마스크 설정 정확
- [ ] 메모리 누수 없음 (queue_free 적절 사용)

---

## 7. Risks and Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| .tscn 텍스트 포맷 불일치 | High | Medium | Godot 4 공식 포맷 참조, 최소 구조로 시작 |
| 충돌 레이어 설정 오류 | Medium | Medium | 레이어 1=Player, 2=Enemy, 3=Projectile 명확 분리 |
| GDScript 2.0 문법 오류 | Medium | Low | Godot 4 공식 문서 기준 코드 작성 |

---

## 8. Architecture Considerations

### 8.1 Project Level Selection

| Level | Characteristics | Recommended For | Selected |
|-------|-----------------|-----------------|:--------:|
| **Starter** | 단순 구조, 기본 노드 활용 | 게임 프로토타입, MVP | **v** |
| **Dynamic** | 모듈화, 상태 관리 | 완성도 높은 게임 | |
| **Enterprise** | 복잡한 아키텍처 | 대규모 게임 | |

### 8.2 Key Decisions

| Decision | Options | Selected | Rationale |
|----------|---------|----------|-----------|
| 그래픽 방식 | ColorRect / Polygon2D / Sprite2D | ColorRect | 가장 단순, 별도 리소스 불필요 |
| 물리 시스템 | CharacterBody2D / RigidBody2D | CharacterBody2D | 직접 이동 제어에 적합 |
| 발사체 노드 | Area2D / CharacterBody2D | Area2D | 충돌 감지만 필요, 물리 불필요 |
| 적 스폰 방식 | Timer + 코드 / Path2D | Timer + 코드 | 단순하고 제어 용이 |

### 8.3 Component Overview

```
project.godot
├── scenes/
│   ├── main.tscn        (Node2D - 메인 씬)
│   ├── player.tscn       (CharacterBody2D - 플레이어)
│   ├── enemy.tscn        (CharacterBody2D - 적)
│   └── projectile.tscn   (Area2D - 발사체)
├── scripts/
│   ├── main.gd           (적 스포너, 발사체 타이머)
│   ├── player.gd         (WASD 이동, HP/XP)
│   ├── enemy.gd          (플레이어 추적, 충돌 데미지)
│   └── projectile.gd     (자동 타겟팅, 충돌 처리)
```

### 8.4 Data Flow

```
[EnemySpawner Timer] ──1초마다──> [Enemy 인스턴스 생성]
                                      │
                                      ▼
                              [플레이어 추적 이동]
                                      │
                                      ▼
                            [충돌 감지] ──> [플레이어 HP 감소]

[WeaponTimer] ──0.5초마다──> [가장 가까운 적 탐색]
                                      │
                                      ▼
                            [Projectile 생성 및 발사]
                                      │
                                      ▼
                            [적과 충돌] ──> [적 queue_free]
```

---

## 9. Convention Prerequisites

### 9.1 Applicable Conventions

- [x] 파일 구조: `scenes/`, `scripts/` 폴더 분리
- [x] 스크립트 명명: snake_case (player.gd, enemy.gd)
- [x] 노드 명명: PascalCase (Player, Enemy, Projectile)
- [x] 모든 코드에 한국어 주석 포함

---

## 10. Next Steps

1. [ ] 설계 문서 작성 (`/pdca design godot-survivors-mvp`)
2. [ ] 구현 시작 (`/pdca do godot-survivors-mvp`)
3. [ ] Gap 분석 (`/pdca analyze godot-survivors-mvp`)

---

## Appendix: Brainstorming Log

> Plan Plus Phases 1-4에서의 주요 결정 사항.

| Phase | Question | Answer | Decision |
|-------|----------|--------|----------|
| Intent | 핵심 목적 | 플레이 가능한 게임 MVP | 완성도 있는 게임 루프 구현에 집중 |
| Intent | Plan 범위 | Phase 1 전체를 하나의 Plan으로 | 5개 Step을 하나의 PDCA 사이클로 관리 |
| Alternatives | 구현 방식 비교 | A: 순수 씬 파일 직접 생성 | Godot 관례 준수 + 에디터 호환성 |
| YAGNI | MVP 기능 범위 | 4개 전체 포함 | Phase 1 범위 그대로 진행 |
| Validation | 아키텍처 구조 | 적절함 | 별도 씬/스크립트 분리 구조 확정 |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-03-24 | Initial draft (Plan Plus) | AI + User |
