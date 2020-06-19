#!/bin/bash

###############################################################################
#   Launch garbage proprietary programs like Zoom or i686 only applications   #
#  like Steam in a systemd-nspawn container to keep the main system nice and  #
#     clean. The container is assumed to be on an encrypted block device.     #
###############################################################################

user=steam
block_device=/dev/sda1
container_name=garbage
mount_path=/mnt/$container_name
export SUDO_ASKPASS=/usr/lib/git-core/git-gui--askpass

function unlock_device(){
  if [[ ! -b /dev/mapper/$container_name ]]; then
    if [[ -t 0 ]]; then
      sudo cryptsetup open $block_device $container_name || exit
    else
      local message="Enter passphrase for $block_device:"
      sudo cryptsetup open $block_device $container_name <<<"$($SUDO_ASKPASS $message)" || exit
    fi
  fi
}

function mount_device(){
  if ! mountpoint -q $mount_path; then
    # sudo timeout probably lasts long enough
    sudo mkdir -p $mount_path || return
    sudo mount /dev/mapper/$container_name $mount_path
  fi
}

function umount_device(){
  if mountpoint -q $mount_path; then
    sudo umount $mount_path || return
    sudo rmdir $mount_path
  fi
}

function is_running(){
  if [[ ! $(machinectl --property=State show $container_name 2> /dev/null) = "State=running" ]]; then
    return 1
  fi
}

function notify_status(){
  if is_running; then
    message="The garbage container is still running!"
  else
    message="The garbage container is offline!"
  fi
  if [[ -t 1 ]]; then
    echo $message
  else
    notify-send "$message"
  fi
}

function kill_container(){
  if is_running; then
    sudo machinectl -q terminate $container_name
    # wait for other session to properly shut down
    while [[ $(pgrep -cf $0) -gt 1 ]]; do
      sleep 1
    done
  fi
}

function launch_container(){
  # if a garbage program didn't terminate like it should in a previous session, kill it
  kill_container
  # allow container X11 applications to connect to host instance
  xhost +local:

  # https://www.reddit.com/r/linux_gaming/comments/c50vsb/howto_run_steam_in_a_container_without_32bit/
  # https://patrickskiba.com/sysytemd-nspawn/2019/03/21/graphical-applications-in-systemd-nspawn.html
  sudo systemd-nspawn \
    --quiet \
    --private-users-chown \
    --user=$user \
    --volatile=no \
    --setenv=DISPLAY=$DISPLAY \
    --setenv=DRI_PRIME=$DRI_PRIME \
    --setenv=PULSE_SERVER=unix:/run/user/host/pulse/native \
    --bind=/run/user/1000/pulse:/run/user/host/pulse \
    --bind=/run/user/1000/ \
    --bind=/tmp/.X11-unix \
    --bind=/dev/shm \
    --bind=/dev/dri \
    --bind=/dev/kvm \
    --bind=/dev/input \
    --bind=/dev/video0 \
    --property="DeviceAllow=/dev/tty1 rwm" \
    --property="DeviceAllow=/dev/dri rwm" \
    --property="DeviceAllow=/dev/shm rwm" \
    --property="DeviceAllow=/dev/kvm rwm" \
    --property="DeviceAllow=/dev/input rwm" \
    --property="DeviceAllow=/dev/dri/renderD128 rwm" \
    --property="DeviceAllow=char-usb_device rwm" \
    --property="DeviceAllow=char-input rwm" \
    --property="DeviceAllow=char-drm rwm" \
    --image=/dev/mapper/$container_name "$@"

  xhost -local:
}

case "$1" in
  --mount|-m)
    unlock_device
    mount_device
    ;;
  --umount|-u)
    umount_device
    ;;
  --notify|-n)
    notify_status
    ;;
  --kill|-k)
    kill_container
    ;;
  *)
    unlock_device
    launch_container "$@"
    ;;
esac
