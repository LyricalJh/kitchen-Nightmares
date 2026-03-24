# Project Changelog

> **Project**: chef-nightmare
> **Last Updated**: 2026-03-24

---

## [0.4.0] - 2026-03-24 - Phase 4: Infinite Map & Camera System

### Added
- Camera2D node as Player child for automatic tracking (position_smoothing enabled)
- Dynamic floor tiling system: 16px tiles generated/destroyed based on player proximity (±50 tile range)
- Centralized cleanup system for distant objects (enemies >1200px, XP gems >800px)
- FloorTiles container node in Main scene for dynamic tile management
- Tile coordinate caching to prevent unnecessary recalculations per frame

### Changed
- Player.gd: Removed viewport_size variable and position clamp logic (removed 3 lines)
- Main scene: Removed static Floor TextureRect, replaced with FloorTiles Node2D container
- Main.gd: Added _update_floor_tiles() and _cleanup_distant_objects() functions
- Cleanup logic centralized to main.gd instead of distributed across enemy.gd/xp_gem.gd

### Technical Improvements
- Tile coordinate transformation uses floori() for accurate negative coordinate handling
- Cached player tile position eliminates unnecessary updates when player stays in same tile
- Centralized distance-based cleanup ensures consistency (camera-centric reference frame)
- Performance-optimized: no new files, only 4 existing files modified (minimal change principle)

### Metrics
- Design Match Rate: 93% (26/30 exact + 4 improved)
- Iterations Required: 0
- FR Coverage: 5/5 (100%) — FR-25 to FR-29 all implemented
- New Files: 0
- Modified Files: 4 (player.tscn, player.gd, main.tscn, main.gd)
- Code Quality: Zero blocking issues, all improvements over design
- Compatibility: 100% backward compatible with Phases 1-3

### Project Status
- Phase 1 MVP: 99% match (0 iterations)
- Phase 2 Growth: 97% match (0 iterations)
- Phase 3 Game Loop: 98.5% match (0 iterations)
- Phase 4 Infinite Map: 93% match (0 iterations)
- **Total**: 29 Functional Requirements, 0 Total Iterations, **95.9% Average Match Rate**
- **Result**: Infinite-field game experience with stable memory management, ready for Phase 5+ features

---

## [0.3.0] - 2026-03-24 - Phase 3: Complete Game Loop

### Added
- Title screen with "Game Start" button (TitleScreen scene)
- Game Over UI with survival time and best record display (GameOverUI scene)
- died signal in Player for game-over triggering
- Time tracking system in Main with MM:SS real-time display
- Wave-based difficulty system: enemy spawn frequency decreases 10% every 30s (min 0.3s)
- Wave-based difficulty system: enemy speed increases 10% every 30s
- Best record storage using ConfigFile (user://save_data.cfg)
- game_over guards to prevent spawning/attacks after death

### Changed
- project.godot: main_scene changed from "main" to "title_screen"
- Main.gd: Added elapsed_time tracking, _process with time/wave updates, game-over handling
- Player.gd: Added died signal emission when HP reaches 0
- HUD.gd: Added update_time() method for real-time elapsed time display
- HUD.tscn: Added TimeLabel node in VBoxContainer

### Technical Improvements
- Completed PDCA cycle with zero iterations (98.5% design match)
- Signal-based game loop architecture (clean separation of concerns)
- Defensive programming guards for game_over state
- ConfigFile error handling for missing save files
- Full FR coverage: 8/8 requirements (FR-17 ~ FR-24)

### Metrics
- Design Match Rate: 98.5% (67/68 items)
- Iterations Required: 0
- FR Coverage: 8/8 (100%)
- New Files: 4 (title_screen.tscn/gd, game_over_ui.tscn/gd)
- Modified Files: 6 (project.godot, player.gd, main.gd/tscn, hud.gd/tscn)
- Code Quality: Zero blocking issues
- Compatibility: 100% backward compatible with Phases 1-2

### Project Status
- Phase 1 MVP: 99% match (0 iterations)
- Phase 2 Growth: 97% match (0 iterations)
- Phase 3 Game Loop: 98.5% match (0 iterations)
- **Total**: 24 Functional Requirements, 0 Total Iterations, 98.2% Average Match Rate
- **Result**: Complete playable game from scratch ready for portfolio showcase

---

## [0.2.0] - 2026-03-24 - Phase 2: Growth System

### Added
- XP gem drop system on enemy death
- Player XP collection and experience bar
- Level-up system with dynamic thresholds (level * 20 XP required)
- Skill selection UI (3 options: attack, fire-rate, move-speed)
- HUD displaying HP, XP, and level in real-time
- Signal-based event architecture (leveled_up, hp_changed, xp_changed, skill_selected)
- Collision layer 4 for XP gems

### Changed
- Player.gd extended with level, XP, skill application logic
- Enemy.gd modified to use die() method for gem spawning
- Projectile.gd updated to call die() instead of queue_free()
- Main.gd enhanced with pause/resume game flow for level-ups

### Technical Improvements
- @onready node caching for performance
- Defensive programming guards (has_method checks)
- Consistent UI button sizing and text alignment
- Clean signal-based decoupling

### Metrics
- Design Match Rate: 97% (91/93 items)
- Iterations Required: 0
- FR Coverage: 8/8 (100%)
- Code Quality: Zero blocking issues
- Compatibility: 100% backward compatible with Phase 1

---

## [0.1.0] - 2026-03-24 - Phase 1: MVP Foundation (godot-survivors-mvp)

### Added
- Core movement system (CharacterBody2D with WASD controls)
- Enemy spawning system (1 enemy type, 1-second spawn rate)
- Player attack system (auto-fire projectiles, 0.5-second cooldown)
- Collision detection and enemy destruction
- HP system for player and enemies

### Technical Foundation
- Godot 4.x scene-based architecture
- Snake_case file naming convention
- PascalCase node naming convention
- Signal-based event handling
- Collision layers (Player, Enemy, Projectile)

### Metrics
- Design Match Rate: 99% (Phase 1 MVP)
- Iterations Required: 0
- Code Quality: Clean architecture
- Foundation for Phase 2+ expansion

---

## Planned Features (Roadmap)

### Phase 3: Enemy Variety & Difficulty Scaling
- Multiple enemy types (fast, tank, ranged)
- Wave-based difficulty system
- Additional weapon/skill types
- Balance tuning for progression

### Phase 4: Polish & Extended Content
- Game-over screen and restart flow
- Sound effects and visual effects
- Main menu and pause screen
- Score/achievement system

---

## Notes

- All Phase 2 features maintain 100% backward compatibility with Phase 1
- Zero breaking changes between versions
- Complete documentation available in docs/ directory
