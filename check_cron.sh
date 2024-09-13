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

echo "检查并添加 crontab 任务..."

if [ -e "${WORKDIR}/start.sh" ] && [ -e "${FILE_PATH}/config.json" ]; then
  echo "检测到 Nezha Agent 和 Socks5，设置相应的定时任务。"
  add_cron_job "@reboot pkill -kill -u ${USER} && ${CRON_S5} && ${CRON_NEZHA} && ${CRON_KEEPALIVE}"
  add_cron_job "*/5 * * * * pgrep -x 'nezha-agent' > /dev/null || ${CRON_NEZHA}"
  add_cron_job "*/5 * * * * pgrep -x 's5' > /dev/null || ${CRON_S5}"
  add_cron_job "*/5 * * * * pgrep -x 'keepalive.sh' > /dev/null || ${CRON_KEEPALIVE}"
elif [ -e "${WORKDIR}/start.sh" ]; then
  echo "检测到 Nezha Agent，设置相应的定时任务。"
  add_cron_job "@reboot pkill -kill -u ${USER} && ${CRON_NEZHA} && ${CRON_KEEPALIVE}"
  add_cron_job "*/5 * * * * pgrep -x 'nezha-agent' > /dev/null || ${CRON_NEZHA}"
  add_cron_job "*/5 * * * * pgrep -x 'keepalive.sh' > /dev/null || ${CRON_KEEPALIVE}"
elif [ -e "${FILE_PATH}/config.json" ]; then
  echo "检测到 Socks5，设置相应的定时任务。"
  add_cron_job "@reboot pkill -kill -u ${USER} && ${CRON_S5} && ${CRON_KEEPALIVE}"
  add_cron_job "*/5 * * * * pgrep -x 's5' > /dev/null || ${CRON_S5}"
  add_cron_job "*/5 * * * * pgrep -x 'keepalive.sh' > /dev/null || ${CRON_KEEPALIVE}"
else
  echo "未检测到 Nezha Agent 或 Socks5 配置文件，将只设置 keepalive.sh 的定时任务。"
  add_cron_job "@reboot ${CRON_KEEPALIVE}"
  add_cron_job "*/5 * * * * pgrep -x 'keepalive.sh' > /dev/null || ${CRON_KEEPALIVE}"
fi
