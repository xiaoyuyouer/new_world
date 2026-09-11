# New World

一个使用 Flutter + Flame 编写的躲避下落物小游戏，项目名称为 New World。

项目用于学习 Flame 的游戏循环、组件、碰撞检测、Flutter Overlay、游戏状态
和本地数据保存。

## 操作

- `←` `→` `↑` `↓` 或 `W` `A` `S` `D`：移动
- `Shift`：加速
- `P`：暂停或继续
- `空格` / `Enter`：开始游戏
- `R`：游戏结束后重新开始

躲开下落物可以得分，随着分数增加，下落物会越来越密。
被击中后会损失生命，并获得短暂无敌时间。

游戏还包含难度、玩家速度、回合时间、生命数量和最高分设置。

## 目录结构

```text
lib/
├── app/                 Flutter 应用入口
├── components/          游戏中的实体和 HUD
├── game/                游戏主控、状态、存储和生成器
├── models/              游戏数据模型
└── ui/overlays/         Flutter 菜单和界面
```

## 运行

```bash
flutter run -d macos
```
