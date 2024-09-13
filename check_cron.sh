#!/bin/bash

# 获取当前用户
USER=$(whoami)

# 定义路径
WORKDIR="/home/${USER}/.nezha-agent"
FILE_PATH="/home/${USER}/.s5"
KEEPALIVE_PATH="/home/${USER}/serv00-play/keepalive.sh"
CRONTAB_FILE="/tmp/crontab_$USER"

# 定义程序的处理逻辑
process_program() {
  local PROGRAM=$1
  local PATH=$2
  local CHECK_COMMAND=$3
  local CRON_COMMAND=$4
  local CRON_ENTRY=$5

  echo "检查并添加 ${PROGRAM} 的 crontab 任务..."

  if [ ! -z "$PATH" ] && [ -e "$PATH" ]; then
    if ! $CHECK_COMMAND > /dev/null; then
      echo "检测到 ${PROGRAM} 不在运行，添加 crontab 任务并运行一次 ${PROGRAM}。"
      crontab -l > "$CRONTAB_FILE" 2>/dev/null
      if ! grep -Fxq "$CRON_ENTRY" "$CRONTAB_FILE"; then
        echo "$CRON_ENTRY" >> "$CRONTAB_FILE"
        crontab "$CRONTAB_FILE"
      fi
      rm "$CRONTAB_FILE"
      eval $CRON_COMMAND
    else
      echo "${PROGRAM} 已经在运行或 crontab 任务已存在。"
    fi
  else
    echo "未检测到 ${PROGRAM} 的必要文件或路径。"
  fi
}

# 处理 S5
S5_CHECK_COMMAND="pgrep -x 's5'"
S5_CRON_COMMAND="nohup ${FILE_PATH}/s5 -c ${FILE_PATH}/config.json >/dev/null 2>&1 &"
S5_CRON_ENTRY="@reboot pkill -kill -u ${USER} && ${S5_CRON_COMMAND}"

# 处理 Nezha Agent
NEZHA_CHECK_COMMAND="pgrep -x 'nezha-agent'"
NEZHA_CRON_COMMAND="nohup ${WORKDIR}/start.sh >/dev/null 2>&1 &"
NEZHA_CRON_ENTRY="@reboot pkill -kill -u ${USER} && ${NEZHA_CRON_COMMAND}"

# 处理 Keepalive
KEEPALIVE_CHECK_COMMAND="pgrep -x 'keepalive.sh'"
KEEPALIVE_CRON_COMMAND="nohup ${KEEPALIVE_PATH} >/dev/null 2>&1 &"
KEEPALIVE_CRON_ENTRY="@reboot ${KEEPALIVE_CRON_COMMAND}"

# 调用处理函数
process_program "s5" "$FILE_PATH" "$S5_CHECK_COMMAND" "$S5_CRON_COMMAND" "$S5_CRON_ENTRY"
process_program "nezha-agent" "$WORKDIR" "$NEZHA_CHECK_COMMAND" "$NEZHA_CRON_COMMAND" "$NEZHA_CRON_ENTRY"
process_program "keepalive" "$KEEPALIVE_PATH" "$KEEPALIVE_CHECK_COMMAND" "$KEEPALIVE_CRON_COMMAND" "$KEEPALIVE_CRON_ENTRY"
