# Session: DodgeGame 架构与职责拆分

## Learner Profile
- Level: beginner-plus
- Language: zh
- Started: 2026-09-11

## Concept Map
| # | Concept | Prerequisites | Status | Score | Last Reviewed | Review Interval |
|---|---------|---------------|--------|-------|---------------|-----------------|
| 1 | 属性数量与类职责的区别 | - | mastered | 100% | 2026-09-11 | 1d |
| 2 | 使用对象与承担职责的区别 | 1 | mastered | 100% | 2026-09-11 | 1d |
| 3 | 按变化原因判断内聚性 | 1, 2 | mastered | 100% | 2026-09-11 | 1d |
| 4 | 本局数据与流程状态的归组 | 2, 3 | mastered | 100% | 2026-09-11 | 1d |
| 5 | 主游戏类作为协调器的边界 | 3, 4 | mastered | 100% | 2026-09-11 | 1d |

## Misconceptions
| # | Concept | Misconception | Root Cause | Status | Counter-Example Used |
|---|---------|---------------|------------|--------|---------------------|
| 1 | 使用对象与承担职责 | 将保存方式归给 DodgeGame | 把调用某个方法误认为实现该方法的技术职责 | resolved | 对照 saveHighScore 的调用点与 SharedPreferences 实现位置；能说明 DodgeGame 只依赖保存能力而不关心实现方式 |
| 2 | 使用对象与承担职责 | 认为调用 AudioManager 的 A 才是职责塞入 DodgeGame | 在新场景中再次混淆能力调用与底层实现；与误解 #1 同类 | resolved | 能说明 B 真正处理音频，而 A 只是调用接口方法 |

## Session Log
- [2026-09-11] 能识别 UI Overlay 与设置/存储具有独立变化的可能，开始区分对象引用与职责归属。
- [2026-09-11] 正确判断保存时机属于游戏流程；保存实现的职责边界仍需辨析。
- [2026-09-11] 确认更换存档技术不应影响 Player、HUD 或 FallingItemSpawner。
- [2026-09-11] 仍把调用 storage.save... 的协调者判断成保存方式的实现者，开始对照调用点与实现点。
- [2026-09-11] 根据 SharedPreferences 的实现位置，正确识别 GameStorage 负责“怎么保存”；待解释调用与实现的区别。
- [2026-09-11] 能准确解释 DodgeGame 只关心保存能力，不关心具体保存方式；误解已纠正。
- [2026-09-11] 在新场景中正确判断音频加载、缓存和播放属于 AudioManager；待完成职责越界判断。
- [2026-09-11] 在 A/B 辨析中选择 A，同类误解在音频场景中复现，需要通过依赖变化进一步验证。
- [2026-09-11] 经“更换音频库”反例后改判 B，能够识别底层实现细节造成的职责归属。
- [2026-09-11] Mastery check 通过：准确、解释、迁移和辨析均满足；自评“基本明确”，校准良好。等待短代码练习。
- [2026-09-11] 代码练习通过：以 AudioManager 接口隔离实现，DodgeGame 仅在 onPlayerHit 中触发调用。Concept 2 mastered。
- [2026-09-11] 正确判断字段较少但直接处理四类实现的类 B 更重；能区分字段数量与职责重量，待深化“变化原因”标准。
- [2026-09-11] 能指出类 B 有四种独立变化原因，并说明类 A 的字段共同描述一个对象；Mastery check 达到 4/4，等待自评与实践。
- [2026-09-11] 实践中将 _state、_showSettings、_settingsReturnState 归为一组，分组合理；待给出对象命名与共同变化原因。
- [2026-09-11] 将流程状态对象命名为 GameFlow，并用“只描述阶段流动，不承诺其他职责”说明边界。Concept 1 实践通过并 mastered。
- [2026-09-11] 自评“很扎实”，与 4/4 的表现一致，元认知校准良好；进入当前工程实践。
- [2026-09-11] 判断 _syncOverlays 不应进入 GameFlow，因为 Flame UI API 是独立变化原因。Concept 3 mastered；更新三概念里程碑图。
- [2026-09-11] 判断 Overlay 出现大量状态和 UI 变化原因时应拆出独立协调对象，主游戏协调器边界基本明确。
- [2026-09-11] 将 score、lives、timeLeft、spawnInterval、wasNewBest 命名归组为 GameRound；待说明生命周期边界。
- [2026-09-11] 正确排除 highScore，因为它与本局可重置数据的生命周期不同；待由学习者明确表述原因。
- [2026-09-11] 能明确说明 score 属于单局生命周期、highScore 跨局并持久化，封装应顺着生命周期划分。Concept 4 mastered。
- [2026-09-11] 综合实践通过：能判断 DodgeGame 主要在协调职责清晰的对象，字段较多不等于过重。Concept 5 mastered；本次学习完成。
- [2026-09-11] 在当前小项目中选择将少量 Overlay 映射留给 DodgeGame 协调，避免过早引入 GameOverlayController。
