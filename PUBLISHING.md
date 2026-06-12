# 📦 发布到 pub.dev 完整指南

## ✅ 发布前检查清单

### 1. 必需文件检查

- [x] `README.md` - 详细的插件说明文档
- [x] `LICENSE` - 开源许可证（MIT）
- [x] `CHANGELOG.md` - 版本更新日志
- [x] `pubspec.yaml` - 包含完整的 description、homepage 等信息
- [ ] 确保代码质量（运行测试和分析）

### 2. pubspec.yaml 检查

确保以下字段已填写：
- [x] `name` - 插件名称
- [x] `description` - 清晰的描述（60-180 字符）
- [x] `version` - 语义化版本号
- [x] `homepage` - 项目主页 URL
- [ ] `repository` - 源码仓库 URL（需要更新为你的实际地址）
- [ ] `issue_tracker` - 问题追踪 URL

**⚠️ 重要：** 请将 `pubspec.yaml` 中的 URL 替换为你的实际 GitHub 地址！

```yaml
homepage: https://github.com/你的用户名/gromore_flutter_plugin
repository: https://github.com/你的用户名/gromore_flutter_plugin
issue_tracker: https://github.com/你的用户名/gromore_flutter_plugin/issues
```

---

## 🚀 发布步骤

### 步骤 1：登录 pub.dev

如果是第一次发布，需要先登录：

```bash
flutter pub login
```

这会打开浏览器，使用你的 Google 账号登录 pub.dev。

### 步骤 2：运行发布前检查

```bash
# 进入插件根目录
cd c:\Users\k64158289\Documents\worker\gromore_flutter_plugin

# 运行 pub.dev 验证
flutter pub publish --dry-run
```

这个命令会：
- ✅ 检查所有必需文件是否存在
- ✅ 验证 pubspec.yaml 格式
- ✅ 检查文件大小限制
- ✅ 分析包结构
- ✅ 显示哪些文件会被发布

**注意事项：**
- 确保没有错误和警告
- 检查会被发布的文件列表
- 确认版本号正确

### 步骤 3：正式发布

确认 dry-run 没有问题后，执行正式发布：

```bash
flutter pub publish
```

系统会提示：
```
Publishing gromore_flutter_plugin 0.0.1 to https://pub.dev:
│ .gitignore
│ CHANGELOG.md
│ LICENSE
│ README.md
│ pubspec.yaml
└── ...

Do you want to publish gromore_flutter_plugin 0.0.1 to pub.dev? (y/N)
```

输入 `y` 确认发布。

### 步骤 4：验证发布

发布成功后：
1. 访问 https://pub.dev/packages/gromore_flutter_plugin
2. 检查页面显示是否正常
3. 确认 README、CHANGELOG、API 文档等都正确显示

---

## 🔧 常见问题

### Q1: 发布时提示 "description too short"

**A:** `pubspec.yaml` 中的 description 必须在 60-180 字符之间。

### Q2: 发布时提示 "Invalid homepage URL"

**A:** 确保 homepage URL 是有效的，建议使用 GitHub 仓库地址。

### Q3: 发布时提示 "Package name already exists"

**A:** 包名已被占用，需要修改 `pubspec.yaml` 中的 `name` 字段。可以尝试：
- `gromore_flutter`
- `flutter_gromore_ads`
- `gromore_ad_plugin`

### Q4: 如何撤回已发布的版本？

**A:** pub.dev 不支持删除已发布的版本，但可以：
1. 立即发布一个修复版本（如 0.0.1+1）
2. 使用 `discontinued` 标记废弃包

### Q5: 如何更新包？

**A:** 
1. 修改代码
2. 更新 `pubspec.yaml` 中的 version（如 0.0.2）
3. 更新 `CHANGELOG.md` 添加新版本说明
4. 重新执行 `flutter pub publish`

---

## 📋 版本号规范

遵循语义化版本（Semantic Versioning）：

```
MAJOR.MINOR.PATCH

例如：1.2.3
```

- **MAJOR（主版本）**: 不兼容的 API 修改
- **MINOR（次版本）**: 向下兼容的功能性新增
- **PATCH（修订版本）**: 向下兼容的问题修正

示例：
- `0.0.1` - 初始开发版本
- `0.1.0` - 第一个功能版本
- `1.0.0` - 第一个稳定版本
- `1.1.0` - 添加新功能
- `1.1.1` - 修复 bug

---

## 🎯 发布后的工作

### 1. 添加徽章到 README

更新 README.md 中的版本徽章：

```markdown
[![pub package](https://img.shields.io/pub/v/gromore_flutter_plugin.svg)](https://pub.dev/packages/gromore_flutter_plugin)
```

### 2. 推送到 GitHub

```bash
git add .
git commit -m "chore: publish version 0.0.1 to pub.dev"
git tag v0.0.1
git push origin main --tags
```

### 3. 创建 GitHub Release

1. 访问你的 GitHub 仓库
2. 点击 "Releases" → "Create a new release"
3. 选择 tag `v0.0.1`
4. 填写 Release notes（从 CHANGELOG.md 复制）
5. 发布 Release

### 4. 宣传推广

- 在 Flutter 社区分享
- 发布技术博客
- 更新项目文档
- 回应用户反馈

---

## 🛡️ 包维护最佳实践

### 持续维护

- ✅ 及时回复 Issues
- ✅ 审核 Pull Requests
- ✅ 定期更新依赖
- ✅ 保持文档同步
- ✅ 添加更多示例

### 质量保证

- ✅ 添加单元测试
- ✅ 设置 CI/CD（GitHub Actions）
- ✅ 定期检查依赖安全性
- ✅ 遵循 Flutter 最佳实践

### 社区建设

- ✅ 编写详细文档
- ✅ 提供示例代码
- ✅ 创建 FAQ
- ✅ 收集用户反馈
- ✅ 建立社区渠道（Discord、Telegram 等）

---

## 📚 相关资源

- [pub.dev 官方文档](https://dart.dev/tools/pub/publishing)
- [Flutter 包开发指南](https://flutter.dev/docs/development/packages-and-plugins/developing-packages)
- [语义化版本规范](https://semver.org/lang/zh-CN/)
- [Markdown 语法指南](https://www.markdownguide.org/)

---

## ✨ 快速命令参考

```bash
# 检查包是否可以发布
flutter pub publish --dry-run

# 登录 pub.dev
flutter pub login

# 发布包
flutter pub publish

# 查看包信息
flutter pub deps

# 运行代码分析
flutter analyze

# 运行测试
flutter test
```

---

**祝你发布顺利！如有问题，欢迎在 Issues 中提问。** 🎉
