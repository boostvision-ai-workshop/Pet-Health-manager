# PRD → 实现映射

便于评审对照 **《宠物健康记录App-PRD-MVP》**（与仓库外 PRD 文档一致，提交时将完整 PRD 与仓库一同交付即可）。

| PRD 章节 / 能力 | 主要实现位置 |
|------------------|--------------|
| 单宠档案（§7.5、§8.1） | `lib/features/pet_profile/pet_profile_screen.dart` |
| 无档案进创建、有档案进 Tab（§8.1） | `lib/app/app_router.dart`（`redirect`） |
| 首页主卡、里程碑、体重趋势、提醒条（§7.1、§7.2） | `lib/features/home/`、`lib/services/*` |
| 大事记、筛选、绝育不在默认列表、删除动效（§7.2、§8.3） | `lib/features/timeline/timeline_screen.dart` |
| 新增五类健康事件、校验（§7.4） | `lib/features/events/add_health_event_screen.dart`、`lib/models/validation/health_event_rules.dart` |
| 提醒与通知（应用内 + 系统） | `lib/features/reminders/`、`lib/services/local_notification_service.dart` |
| 我的页、编辑入口（§7.3） | `lib/features/profile/profile_screen.dart` |
| 健康状态、里程碑数据（§8.7、服务层） | `lib/services/home_health_status.dart`、`milestone_service.dart` |
| 本地持久化（§8.6、§9） | `lib/data/pet_repository_hive.dart` |
| 设计 Token、主题 | `lib/app/app_theme.dart`、`chongban_app.dart` |
| 状态与数据刷新 | `lib/app/providers.dart`、`router_refresh.dart` |

**单元测试**：`test/models/`、`test/data/`、`test/services/` 覆盖模型校验与部分服务；运行 `flutter test`。
