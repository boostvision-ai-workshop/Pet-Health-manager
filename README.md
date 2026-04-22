# Pet-Health-manager（宠伴健康）

Flutter **Android** 单宠健康记录 MVP：本地存储（Hive）、三 Tab 导航、健康事件、提醒与里程碑。

与产品文档 **《宠物健康记录App-PRD-MVP》** 对齐；代码与 **PRD → 实现映射** 见 [`docs/PRD_IMPLEMENTATION.md`](docs/PRD_IMPLEMENTATION.md)。赛题交付请将 **完整 PRD** 与本仓库一同提交，或把 PRD 另存为仓库内 `docs/PRD_MVP.md` 便于评审。

**赛题自评**可对照：[`docs/SCORING_CHECKLIST.md`](docs/SCORING_CHECKLIST.md)（与 `SCORING.md` 四维度一致）。

## 环境

- Flutter SDK 3.5+（`sdk` 约束见 `pubspec.yaml`）
- Android Studio / Android SDK，用于真机或模拟器
- 仅含 **Android** 子工程，无 `ios/`

## 开发

```bash
cd Pet-Health-manager
flutter pub get
flutter run -d <设备ID>   # flutter devices 查看
```

## 测试与分析

```bash
flutter test
flutter analyze
```

## Release APK

```bash
flutter build apk --release
# 输出：build/app/outputs/flutter-apk/app-release.apk
# 可拷贝到本仓库 output/ 目录作分发（已加入 .gitignore）
```

当前 `android/app/build.gradle.kts` 的 release 使用 **debug 签名** 仅便于本地/演示安装；若上架应用商店，请配置正式 keystore。

## 目录概览

| 路径 | 说明 |
|------|------|
| `lib/app/` | 主题、路由、`Provider` |
| `lib/data/` | 仓储实现 `PetRepositoryHive` |
| `lib/features/` | 各页面（首页/大事记/我的/档案/事件/提醒） |
| `lib/models/` 与 `validation/` | 领域模型与校验 |
| `lib/services/` | 里程碑、健康状态、系统通知等 |
| `test/` | 单测 |
| `docs/` | PRD 映射、赛题自查清单 |

更多协作约定见 [`CONTRIBUTING.md`](CONTRIBUTING.md)。
