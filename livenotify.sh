#!/bin/bash
#set -vx
. ./live.conf

community_url=''
community_html=''
live_title=''
live_url=''

function create_community_url(){
  if [ -z "$community_id" ] ; then
    echo 'コミュニティIDがない'
    exit 1
  fi

  community_url=`echo "https://com.nicovideo.jp/community/co$community_id"`
}

function check_update(){
  community_html=`curl -s $community_url`
  if [ ! $? = 0 ]; then
    echo 'コミュニティが取れてない'
    return 1
  fi

  current_live_url=`echo "$community_html" | grep -Po -e '(?<=class="now_live_inner" href=").*(?=")'`

  if [ $? = 0 ]; then
    if [ ! "$live_url" = "$current_live_url" ]; then
      return 0
    fi
  fi

  return 1
}

function live_notify(){
  live_title=`echo "$community_html" | grep -Po -e '(?<=class="now_live_title">).*(?=</h2>)'`
  live_url=`echo "$community_html" | grep -Po -e '(?<=class="now_live_inner" href=").*(?=")'`

  notify-send "生放送開始" "タイトル: $live_title\nURL: $live_url" || {
    echo '通知ができなかった'
  }

  echo $live_url
}

create_community_url

while true ; do
  check_update
  status=$?
  if [ $status = 0 ]; then
    live_notify
  fi

  sleep 60
done
