# App Vibe Coding 自评速查（对照 `SCORING.md`）

交付前自查四维度，每项 25 分。证据以 **可复现仓库** 为优先。

## 1）流程规范性
- [ ] 使用 app dev agent / 可追溯开发过程（会话、日志、或录屏片段）
- [ ] Git 提交信息可读、粒度合理（建议 `feat` / `fix` / `docs` 等前缀，见 `CONTRIBUTING.md`）
- [ ] PRD 与实现有映射（本仓库 `docs/PRD_IMPLEMENTATION.md`）

## 2）完成度
- [ ] 主流程：无档案 → 建档案 → 首页 → 记事件 → 大事记/提醒/我的
- [ ] 核心字段与事件类型与 PRD 一致；异常路径可恢复（如保存失败有提示）
- [ ] 本机构建：`flutter build apk --release` 可成功

## 3）工程质量
- [ ] `flutter test` 通过
- [ ] 仓储与 UI 分层清晰；业务校验集中在 `lib/models/validation/`
- [ ] 网络/非网络场景：本地 Hive，关键写操作有错误处理与用户反馈

## 4）体验 / 设计
- [ ] 全应用统一主题与间距（`ChongbanTokens`）
- [ ] 空态（大事记/提醒等）、保存中/失败有反馈
- [ ] 主导航与路由一致，不迷路
