#!/bin/bash

# 获取当前用户
USER=$(whoami)
# 设置 Nezha Agent 的工作目录
WORKDIR="/home/${USER}/.nezha-agent"
# 设置 Socks5 的配置文件路径
FILE_PATH="/home/${USER}/.s5"
# 设置 keepalive.sh 的路径
KEEPALIVE_PATH="/home/${USER}/serv00-play/keepalive.sh"

# 设置 Socks5 启动命令
CRON_S5="nohup ${FILE_PATH}/s5 -c ${FILE_PATH}/config.json >/dev/null 2>&1 &"
# 设置 Nezha Agent 启动命令
CRON_NEZHA="nohup ${WORKDIR}/start.sh >/dev/null 2>&1 &"
# 设置 keepalive.sh 启动命令
CRON_KEEPALIVE="nohup ${KEEPALIVE_PATH} >/dev/null 2>&1 &"
# 设置 pm2 重新加载的命令
PM2_PATH="/home/${USER}/.npm-global/lib/node_modules/pm2/bin/pm2"
# 设置 pm2 定时任务，每12分钟重新加载
CRON_JOB="*/12 * * * * $PM2_PATH resurrect >> /home/$(whoami)/pm2_resurrect.log 2>&1"
# 设置重启时重新加载 pm2 的命令
REBOOT_COMMAND="@reboot pkill -kill -u $(whoami) && $PM2_PATH resurrect >> /home/$(whoami)/pm2_resurrect.log 2>&1"

echo "检查并添加 crontab 任务"

# 检查是否安装了 pm2
if [ "$(command -v pm2)" == "/home/${USER}/.npm-global/bin/pm2" ]; then
  echo "已安装 pm2，并返回正确路径，启用 pm2 保活任务"
  # 如果 crontab 中不存在重启 pm2 的任务，则添加
  (crontab -l | grep -F "$REBOOT_COMMAND") || (crontab -l; echo "$REBOOT_COMMAND") | crontab -
  # 如果 crontab 中不存在 pm2 重新加载的定时任务，则添加
  (crontab -l | grep -F "$CRON_JOB") || (crontab -l; echo "$CRON_JOB") | crontab -
else
  # 检查 Nezha Agent 和 Socks5 的相关文件是否存在
  if [ -e "${WORKDIR}/start.sh" ] && [ -e "${FILE_PATH}/config.json" ]; then
    echo "添加 nezha & socks5 的 crontab 重启任务"
    # 如果 crontab 中不存在重启 Nezha Agent、Socks5 和 keepalive.sh 的任务，则添加
    (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_S5} && ${CRON_NEZHA} && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_S5} && ${CRON_NEZHA} && ${CRON_KEEPALIVE}") | crontab -
    # 如果 crontab 中不存在定时启动 Nezha Agent 的任务，则添加
    (crontab -l | grep -F "* * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") || (crontab -l; echo "*/12 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") | crontab -
    # 如果 crontab 中不存在定时启动 Socks5 的任务，则添加
    (crontab -l | grep -F "* * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") || (crontab -l; echo "*/12 * * * * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") | crontab -
    # 添加 keepalive.sh 的重启任务
    (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_KEEPALIVE}") | crontab -
    # 添加 keepalive.sh 的定时任务
    (crontab -l | grep -F "* * ${CRON_KEEPALIVE}") || (crontab -l; echo "*/12 * * * * ${CRON_KEEPALIVE}") | crontab -
  elif [ -e "${WORKDIR}/start.sh" ]; then
    echo "添加 nezha 的 crontab 重启任务"
    # 如果 crontab 中不存在重启 Nezha Agent 和 keepalive.sh 的任务，则添加
    (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_NEZHA} && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_NEZHA} && ${CRON_KEEPALIVE}") | crontab -
    # 如果 crontab 中不存在定时启动 Nezha Agent 的任务，则添加
    (crontab -l | grep -F "* * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") || (crontab -l; echo "*/12 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") | crontab -
    # 添加 keepalive.sh 的重启任务
    (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_KEEPALIVE}") | crontab -
    # 添加 keepalive.sh 的定时任务
    (crontab -l | grep -F "* * ${CRON_KEEPALIVE}") || (crontab -l; echo "*/12 * * * * ${CRON_KEEPALIVE}") | crontab -
  elif [ -e "${FILE_PATH}/config.json" ]; then
    echo "添加 socks5 的 crontab 重启任务"
    # 如果 crontab 中不存在重启 Socks5 和 keepalive.sh 的任务，则添加
    (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_S5} && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_S5} && ${CRON_KEEPALIVE}") | crontab -
    # 如果 crontab 中不存在定时启动 Socks5 的任务，则添加
    (crontab -l | grep -F "* * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") || (crontab -l; echo "*/12 * * * * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") | crontab -
    # 添加 keepalive.sh 的重启任务
    (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_KEEPALIVE}") | crontab -
    # 添加 keepalive.sh 的定时任务
    (crontab -l | grep -F "* * ${CRON_KEEPALIVE}") || (crontab -l; echo "*/12 * * * * ${CRON_KEEPALIVE}") | crontab -
  fi
fi
