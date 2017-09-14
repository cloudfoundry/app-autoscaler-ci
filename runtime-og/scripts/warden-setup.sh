#!/bin/bash

function permit_device_control() {
  local devices_mount_info=$(cat /proc/self/cgroup | grep devices)

  if [ -z "$devices_mount_info" ]; then
    # cgroups not set up; must not be in a container
    return
  fi

  local devices_subsytems=$(echo $devices_mount_info | cut -d: -f2)
  local devices_subdir=$(echo $devices_mount_info | cut -d: -f3)

  if [ "$devices_subdir" = "/" ]; then
    # we're in the root devices cgroup; must not be in a container
    return
  fi

  cgroup_dir=${RUN_DIR}/devices-cgroup

  if [ ! -e ${cgroup_dir} ]; then
    # mount our container's devices subsystem somewhere
    mkdir ${cgroup_dir}
  fi

  if ! mountpoint -q ${cgroup_dir}; then
    mount -t cgroup -o $devices_subsytems none ${cgroup_dir}
  fi

  # permit our cgroup to do everything with all devices
  echo a > ${cgroup_dir}${devices_subdir}/devices.allow || true
}

function create_loop_devices() {
  amt=$1
  for i in $(seq 0 $amt); do
    mknod -m 0660 /dev/loop$i b 7 $i || true
  done
}

function destroy_containers() {
  for i in /tmp/warden/containers/*; do
    if [ -f $i/destroy.sh ]; then
      echo "destroying" $i
      $i/destroy.sh
      rm -rf $i
    fi
  done
}

function setup_warden_infrastructure() {
  permit_device_control
  create_loop_devices 100

  mkdir -p /tmp/warden

  set +e
  let MOUNTED=$(mount | grep -c '\/tmp\/warden')
  if [ $MOUNTED -gt 0 ]; then
    umount /tmp/warden
    RC=$?
    if [ $RC != "0" ]; then
      echo "Unable to umount /tmp/warden, reusing existing tmp filesystem"
    else
      mount -o size=6G,rw -t tmpfs tmpfs /tmp/warden
    fi
  else
    mount -o size=6G,rw -t tmpfs tmpfs /tmp/warden
  fi
  set -e

  dd if=/dev/zero of=/tmp/warden/rootfs.img bs=1024 count=1572864
  rootfs_loopdev=$(losetup --show -f /tmp/warden/rootfs.img)
  mkfs -t ext4 -m 1 -v ${rootfs_loopdev}
  mkdir -p /tmp/warden/rootfs
  mount -t ext4 ${rootfs_loopdev} /tmp/warden/rootfs

  dd if=/dev/zero of=/tmp/warden/containers.img bs=1024 count=1572864
  containers_loopdev=$(losetup --show -f /tmp/warden/containers.img)
  mkfs -t ext4 -m 1 -v ${containers_loopdev}
  mkdir -p /tmp/warden/containers
  mount -t ext4 ${containers_loopdev} /tmp/warden/containers

  trap "destroy_containers; umount ${rootfs_loopdev} || true; umount ${containers_loopdev} || true; losetup -d ${rootfs_loopdev} || true; losetup -d ${containers_loopdev} || true" EXIT
}
