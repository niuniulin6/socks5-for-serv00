#!/bin/bash

# 获取当前用户的用户名
USER=$(whoami)

# 定义工作目录和其他文件路径
WORKDIR="/home/${USER}/.nezha-agent"           # nezha-agent 的工作目录
FILE_PATH="/home/${USER}/.s5"                  # socks5 的配置文件目录
KEEPALIVE_SCRIPT="/home/${USER}/serv00-play/keepalive.sh" # keepalive 脚本的路径

# 定义 crontab 任务的命令
CRON_S5="nohup ${FILE_PATH}/s5 -c ${FILE_PATH}/config.json >/dev/null 2>&1 &" # socks5 服务启动命令
CRON_NEZHA="nohup ${WORKDIR}/start.sh >/dev/null 2>&1 &"                      # nezha-agent 启动命令
CRON_KEEPALIVE="nohup ${KEEPALIVE_SCRIPT} >/dev/null 2>&1 &"                 # keepalive 脚本启动命令

echo "检查并添加 crontab 任务"

# 检查并添加其他任务
if [ -e "${WORKDIR}/start.sh" ] && [ -e "${FILE_PATH}/config.json" ]; then
  # 如果 nezha-agent 和 socks5 的配置文件都存在
  echo "添加 nezha & socks5 的 crontab 重启任务"

  # @reboot 任务：系统重启时，杀掉所有当前用户的进程并重启 socks5、nezha-agent 和 keepalive
  (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_S5} && ${CRON_NEZHA} && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_S5} && ${CRON_NEZHA} && ${CRON_KEEPALIVE}") | crontab -

  # 每分钟检查 nezha-agent 是否运行，不运行则启动
  (crontab -l | grep -F "* * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") || (crontab -l; echo "*/5 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") | crontab -

  # 每分钟检查 socks5 是否运行，不运行则启动
  (crontab -l | grep -F "* * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") || (crontab -l; echo "*/5 * * * * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") | crontab -

  # 每分钟检查 keepalive.sh 是否运行，不运行则启动
  (crontab -l | grep -F "* * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") || (crontab -l; echo "*/5 * * * * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") | crontab -

elif [ -e "${WORKDIR}/start.sh" ]; then
  # 如果只有 nezha-agent 的工作目录存在
  echo "添加 nezha 的 crontab 重启任务"

  # @reboot 任务：系统重启时，杀掉所有当前用户的进程并重启 nezha-agent 和 keepalive
  (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_NEZHA} && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_NEZHA} && ${CRON_KEEPALIVE}") | crontab -

  # 每分钟检查 nezha-agent 是否运行，不运行则启动
  (crontab -l | grep -F "* * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") || (crontab -l; echo "*/5 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") | crontab -

  # 每分钟检查 keepalive.sh 是否运行，不运行则启动
  (crontab -l | grep -F "* * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") || (crontab -l; echo "*/5 * * * * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") | crontab -

elif [ -e "${FILE_PATH}/config.json" ]; then
  # 如果只有 socks5 的配置文件存在
  echo "添加 socks5 的 crontab 重启任务"

  # @reboot 任务：系统重启时，杀掉所有当前用户的进程并重启 socks5 和 keepalive
  (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_S5} && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_S5} && ${CRON_KEEPALIVE}") | crontab -

  # 每分钟检查 socks5 是否运行，不运行则启动
  (crontab -l | grep -F "* * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") || (crontab -l; echo "*/5 * * * * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") | crontab -

  # 每分钟检查 keepalive.sh 是否运行，不运行则启动
  (crontab -l | grep -F "* * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") || (crontab -l; echo "*/5 * * * * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") | crontab -

else
  # 如果只有 keepalive 脚本存在
  echo "添加 keepalive 的 crontab 重启任务"

  # @reboot 任务：系统重启时，杀掉所有当前用户的进程并重启 keepalive
  (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_KEEPALIVE}") | crontab -

  # 每分钟检查 keepalive.sh 是否运行，不运行则启动
  (crontab -l | grep -F "* * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") || (crontab -l; echo "*/5 * * * * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") | crontab -
fi
