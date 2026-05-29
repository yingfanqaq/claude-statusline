# claude-statusline

我的 Claude Code statusline 配置备份。

## 显示内容

- 模型名（紫色）
- 思考强度 effort level（low/med/high/xhigh/max）+ thinking 指示
- 上下文进度条（绿/黄/红随用量变色）
- 当前目录

## 安装

每次 Claude Code 升级后 `settings.json` 里的 `statusLine` 字段会被清掉，跑一下安装脚本即可恢复：

```bash
cd ~/claude-statusline
git pull
bash install.sh
```

然后重启 Claude Code。

## 文件

- `statusline.sh` — 状态栏脚本
- `install.sh` — 安装/恢复脚本
