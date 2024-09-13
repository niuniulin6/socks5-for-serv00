#!/bin/bash

USER=$(whoami)
WORKDIR="/home/${USER}/.nezha-agent"
FILE_PATH="/home/${USER}/.s5"
KEEPALIVE_SCRIPT="/home/${USER}/serv00-play/keepalive.sh"
CRON_S5="nohup ${FILE_PATH}/s5 -c ${FILE_PATH}/config.json >/dev/null 2>&1 &"
CRON_NEZHA="nohup ${WORKDIR}/start.sh >/dev/null 2>&1 &"
CRON_KEEPALIVE="nohup ${KEEPALIVE_SCRIPT} >/dev/null 2>&1 &"

echo "检查并添加 crontab 任务"

# 删除所有与 PM2 相关的 crontab 任务
(crontab -l | grep -v '@reboot pkill -kill -u $(whoami) && $PM2_PATH resurrect') | crontab -
(crontab -l | grep -v '*/5 * * * * $PM2_PATH resurrect') | crontab -

# 检查并添加其他任务
if [ -e "${WORKDIR}/start.sh" ] && [ -e "${FILE_PATH}/config.json" ]; then
  echo "添加 nezha & socks5 的 crontab 重启任务"
  (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_S5} && ${CRON_NEZHA} && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_S5} && ${CRON_NEZHA} && ${CRON_KEEPALIVE}") | crontab -
  (crontab -l | grep -F "* * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") || (crontab -l; echo "*/5 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") | crontab -
  (crontab -l | grep -F "* * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") || (crontab -l; echo "*/5 * * * * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") | crontab -
  (crontab -l | grep -F "* * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") || (crontab -l; echo "*/5 * * * * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") | crontab -
elif [ -e "${WORKDIR}/start.sh" ]; then
  echo "添加 nezha 的 crontab 重启任务"
  (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_NEZHA} && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_NEZHA} && ${CRON_KEEPALIVE}") | crontab -
  (crontab -l | grep -F "* * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") || (crontab -l; echo "*/5 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") | crontab -
  (crontab -l | grep -F "* * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") || (crontab -l; echo "*/5 * * * * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") | crontab -
elif [ -e "${FILE_PATH}/config.json" ]; then
  echo "添加 socks5 的 crontab 重启任务"
  (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_S5} && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_S5} && ${CRON_KEEPALIVE}") | crontab -
  (crontab -l | grep -F "* * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") || (crontab -l; echo "*/5 * * * * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") | crontab -
  (crontab -l | grep -F "* * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") || (crontab -l; echo "*/5 * * * * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") | crontab -
else
  echo "添加 keepalive 的 crontab 重启任务"
  (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_KEEPALIVE}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_KEEPALIVE}") | crontab -
  (crontab -l | grep -F "* * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") || (crontab -l; echo "*/5 * * * * pgrep -x \"keepalive.sh\" > /dev/null || ${CRON_KEEPALIVE}") | crontab -
fi
