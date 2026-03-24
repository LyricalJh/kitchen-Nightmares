# Infinite Map & Camera Planning Document

> **Summary**: 무한 맵 이동 — Camera2D 추적, 화면 제한 제거, 동적 바닥 타일링, 원거리 오브젝트 정리
>
> **Project**: chef-nightmare
> **Version**: 0.4.0
> **Author**: AI + User
> **Date**: 2026-03-24
> **Status**: Draft
> **Method**: Plan Plus (Brainstorming-Enhanced PDCA)
> **Prerequisite**: Phase 1~3 완료

---

## Executive Summary

| Perspective | Content |
|-------------|---------|
| **Problem** | 플레이어가 1280x720 고정 화면 안에서만 이동 가능하여 뱀서류 특유의 넓은 필드 느낌이 없다 |
| **Solution** | Camera2D를 Player에 추가하고 화면 제한을 제거, 동적 바닥 타일링으로 무한 맵 구현 |
| **Function/UX Effect** | 플레이어가 어디든 자유롭게 이동하며 카메라가 부드럽게 따라가고, 바닥이 끊김 없이 표현됨 |
| **Core Value** | Vampire Survivors와 동일한 무한 필드 경험으로 게임의 스케일감과 탐험 재미 확보 |

---

## 1. User Intent Discovery

### 1.1 Core Problem

현재 플레이어는 뷰포트 크기(1280x720) 내에서만 이동 가능하다. 화면 바운드 clamp가 걸려 있어 한정된 공간에서만 전투가 이루어지며, 뱀서류 장르의 핵심인 "넓은 필드를 자유롭게 돌아다니며 적을 피하고 상대하는" 경험이 없다.

### 1.2 Target Users

| User Type | Usage Context | Key Need |
|-----------|---------------|----------|
| 게임 플레이어 | 필드를 자유롭게 이동하며 생존 | 답답하지 않은 넓은 이동 공간 |

### 1.3 Success Criteria

- [ ] 플레이어가 상하좌우 어디든 무한히 이동 가능
- [ ] 카메라가 플레이어를 부드럽게 추적
- [ ] 바닥 타일이 끊김 없이 무한으로 표현
- [ ] 화면 밖으로 멀리 벗어난 적/보석이 자동 정리 (메모리 관리)

---

## 2. Alternatives Explored

### 2.1 Approach A: Camera2D + 화면 제한 제거 — Selected

| Aspect | Details |
|--------|---------|
| **Summary** | Player에 Camera2D 추가, clamp 제거, 동적 바닥 타일링 |
| **Pros** | Godot 내장 기능, 간단, 뱀서류 표준 방식 |
| **Cons** | 동적 타일 생성 로직 필요 |
| **Effort** | Low-Medium |

### 2.2 Approach B: 플레이어 고정 + 월드 이동

| Aspect | Details |
|--------|---------|
| **Summary** | 플레이어 중앙 고정, 세계가 반대로 이동 |
| **Pros** | 카메라 불필요 |
| **Cons** | 모든 오브젝트 로직 변경, 비직관적, 확장 어려움 |
| **Effort** | High |

### 2.3 Decision Rationale

**Selected**: Approach A — Godot Camera2D는 이 용도에 최적화됨. 코드 변경 최소.

---

## 3. YAGNI Review

### 3.1 Included (Must-Have)

- [x] Camera2D 추가 (Player 자식, position_smoothing 활성화)
- [x] 화면 바운드 제한(clamp) 제거
- [x] 동적 바닥 타일링 (청크 기반, 플레이어 주변)
- [x] 카메라 부드러운 추적 (position_smoothing)
- [x] 화면 밖 적/보석 자동 제거 (1200px 이상)

### 3.2 Deferred

| Feature | Reason | Revisit When |
|---------|--------|--------------|
| 미니맵 | 현재 불필요 | 맵이 복잡해질 때 |
| 맵 장식물 (나무, 돌) | 비주얼 폴리싱 단계 | Phase 5+ |
| 지형 변화 (물, 벽) | 게임 디자인 복잡도 증가 | Phase 5+ |

### 3.3 Removed

| Feature | Reason |
|---------|--------|
| 맵 경계/울타리 | 무한 맵이므로 경계 불필요 |
| 카메라 줌 인/아웃 | 과도한 기능, 고정 줌으로 충분 |

---

## 4. Scope

### 4.1 In Scope

- [x] `player.tscn` 수정 — Camera2D 자식 노드 추가
- [x] `player.gd` 수정 — position clamp 제거
- [x] `main.tscn` 수정 — 고정 Floor TextureRect 제거
- [x] `main.gd` 수정 — 동적 바닥 타일링 + 원거리 오브젝트 정리 로직 추가
- [x] `enemy.gd` 수정 — 플레이어 원거리 자동 제거
- [x] `xp_gem.gd` 수정 — 플레이어 원거리 자동 제거

### 4.2 Out of Scope

- 미니맵, 맵 장식물, 지형 변화, 카메라 줌

---

## 5. Requirements

### 5.1 Functional Requirements

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-25 | Camera2D가 플레이어를 자동 추적 (position_smoothing) | High | Pending |
| FR-26 | 플레이어가 상하좌우 무한히 이동 가능 (clamp 제거) | High | Pending |
| FR-27 | 바닥 타일이 플레이어 주변에 동적으로 생성/제거 | High | Pending |
| FR-28 | 플레이어로부터 1200px 이상 떨어진 적 자동 제거 | Medium | Pending |
| FR-29 | 플레이어로부터 800px 이상 떨어진 XP 보석 자동 제거 | Medium | Pending |

---

## 6. Success Criteria

### 6.1 Definition of Done

- [ ] 플레이어가 어디든 자유롭게 이동 가능
- [ ] 카메라가 부드럽게 따라감
- [ ] 바닥이 끊김 없이 보임
- [ ] 장시간 플레이 시 메모리 안정적 (원거리 정리)
- [ ] 기존 Phase 1~3 기능 정상 동작

---

## 7. Risks and Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| 동적 타일 생성 시 프레임 드랍 | Medium | Low | 청크 단위(256px)로 관리, 한 프레임에 소량만 처리 |
| 오브젝트 정리 시 보이는 적 제거 | High | Low | 정리 거리를 화면 밖 충분히 멀게 설정 (1200px) |
| 적 스폰 위치가 카메라 시야에 보임 | Low | Medium | spawn_radius를 화면 밖으로 유지 (기존 500px 충분) |

---

## 8. Architecture Considerations

### 8.1 Key Decisions

| Decision | Options | Selected | Rationale |
|----------|---------|----------|-----------|
| 카메라 방식 | Camera2D / 수동 이동 | Camera2D | Godot 네이티브, smoothing 내장 |
| 바닥 타일링 | TextureRect 반복 / 동적 Sprite2D | 동적 Sprite2D | 무한 확장 가능 |
| 청크 크기 | 16px / 256px / 512px | 256px (16x16타일) | 적절한 관리 단위 |
| 정리 거리 | 화면 크기 기준 / 고정값 | 고정값 1200px/800px | 단순하고 예측 가능 |

### 8.2 변경 파일 목록

```
수정:
- scenes/player.tscn   (Camera2D 추가)
- scripts/player.gd    (clamp 제거)
- scenes/main.tscn     (Floor 제거)
- scripts/main.gd      (동적 타일링 + 정리 로직)
- scripts/enemy.gd     (원거리 자동 제거)
- scripts/xp_gem.gd    (원거리 자동 제거)

신규: 없음
```

---

## 9. Convention Prerequisites

- [x] 기존 컨벤션 유지
- [x] 한국어 주석 + FR 매핑

---

## 10. Next Steps

1. [ ] 설계 문서 작성 (`/pdca design infinite-map-camera`)
2. [ ] 구현 시작 (`/pdca do infinite-map-camera`)
3. [ ] Gap 분석 (`/pdca analyze infinite-map-camera`)

---

## Appendix: Brainstorming Log

| Phase | Question | Answer | Decision |
|-------|----------|--------|----------|
| Intent | 맵 이동 방식 | 무한 맵 | 화면 제한 없이 자유 이동 |
| Alternatives | 구현 방식 | A: Camera2D + 제한 제거 | Godot 네이티브 활용, 최소 변경 |
| YAGNI | 기능 범위 | 4개 전체 | 카메라+바닥+스무딩+정리 |
| Validation | 아키텍처 | 적절함 | 기존 파일 수정만, 신규 파일 없음 |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-03-24 | Initial draft (Plan Plus) | AI + User |
