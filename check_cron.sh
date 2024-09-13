#!/bin/bash

# 获取当前用户
USER=$(whoami)
# 定义路径
WORKDIR="/home/${USER}/.nezha-agent"
FILE_PATH="/home/${USER}/.s5"
KEEPALIVE_PATH="/home/${USER}/serv00-play/keepalive.sh"
CRONTAB_FILE="/tmp/crontab_$USER"

# 定义命令
CRON_S5="nohup ${FILE_PATH}/s5 -c ${FILE_PATH}/config.json >/dev/null 2>&1 &"
CRON_NEZHA="nohup ${WORKDIR}/start.sh >/dev/null 2>&1 &"
CRON_KEEPALIVE="nohup ${KEEPALIVE_PATH} >/dev/null 2>&1 &"

# 检查 crontab 中是否存在某个任务
check_cron_job() {
  local job="$1"
  crontab -l 2>/dev/null | grep -Fxq "$job"
}

# 添加 crontab 任务的函数
add_cron_job() {
  local job="$1"
  crontab -l > "$CRONTAB_FILE" 2>/dev/null
  if ! grep -Fxq "$job" "$CRONTAB_FILE"; then
    echo "$job" >> "$CRONTAB_FILE"
    crontab "$CRONTAB_FILE"
  fi
  rm "$CRONTAB_FILE"
}

# 处理 Nezha Agent 的函数
setup_nezha_agent() {
  echo "检测到 Nezha Agent，设置相应的定时任务。"
  if ! check_cron_job "@daily ${CRON_NEZHA}"; then
    add_cron_job "@daily ${CRON_NEZHA}"
  fi
  if ! check_cron_job "*/5 * * * * pgrep -x 'nezha-agent' > /dev/null || ${CRON_NEZHA}"; then
    add_cron_job "*/5 * * * * pgrep -x 'nezha-agent' > /dev/null || ${CRON_NEZHA}"
  fi
  if ! check_cron_job "*/5 * * * * pgrep -x 'keepalive.sh' > /dev/null || ${CRON_KEEPALIVE}"; then
    add_cron_job "*/5 * * * * pgrep -x 'keepalive.sh' > /dev/null || ${CRON_KEEPALIVE}"
  fi
  ${CRON_NEZHA}  # 运行一次
}

# 处理 Keepalive 的函数
setup_keepalive() {
  echo "设置 Keepalive 的定时任务。"
  if ! check_cron_job "@daily ${CRON_KEEPALIVE}"; then
    add_cron_job "@daily ${CRON_KEEPALIVE}"
  fi
  if ! check_cron_job "*/5 * * * * pgrep -x 'keepalive.sh' > /dev/null || ${CRON_KEEPALIVE}"; then
    add_cron_job "*/5 * * * * pgrep -x 'keepalive.sh' > /dev/null || ${CRON_KEEPALIVE}"
  fi
  ${CRON_KEEPALIVE}  # 运行一次
}

# 处理 Socks5 的函数
setup_socks5() {
  echo "检测到 Socks5，设置相应的定时任务。"
  if ! check_cron_job "@daily ${CRON_S5}"; then
    add_cron_job "@daily ${CRON_S5}"
  fi
  if ! check_cron_job "*/5 * * * * pgrep -x 's5' > /dev/null || ${CRON_S5}"; then
    add_cron_job "*/5 * * * * pgrep -x 's5' > /dev/null || ${CRON_S5}"
  fi
  if ! check_cron_job "*/5 * * * * pgrep -x 'keepalive.sh' > /dev/null || ${CRON_KEEPALIVE}"; then
    add_cron_job "*/5 * * * * pgrep -x 'keepalive.sh' > /dev/null || ${CRON_KEEPALIVE}"
  fi
  ${CRON_S5}  # 运行一次
}

# 主脚本逻辑
echo "检查并添加 crontab 任务..."

if [ -e "${WORKDIR}/start.sh" ] && [ -e "${FILE_PATH}/config.json" ]; then
  setup_nezha_agent
  setup_socks5
elif [ -e "${WORKDIR}/start.sh" ]; then
  setup_nezha_agent
elif [ -e "${FILE_PATH}/config.json" ]; then
  setup_socks5
else
  setup_keepalive
fi
