1. 每次更新变更规则，都要考虑，是否需要更新install.sh ，AI_INSTANCE.md, README.md , .
2. 每次更新变更规则，都要考虑codex，opencode，cursor，claude，gemini，antigravity，agent的更新
3. 用户自己的关键文件，不能被修改，我们的只能追加，修改也只能修改我们自己的内容

需要自己运行脚本进行检测,可以去/tmp/test-dev-skills-kit-<时间>，看看是否客户端按照符合预期:
dev-skills-kit 是一个 AI Agent 能力标准化分发工具包——它从多个优秀的开源项目中提纯最佳实践，去掉教条，补上缺失，然后通过一条安装命令，自动适配并注入到你的任意项目中，同时支持 6 个主流 AI 编程平台，用户使用 /go 才激活完整规则