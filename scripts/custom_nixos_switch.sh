#!/usr/bin/env bash

read -p "Enter custom part of profile name: " custom_input
if [[ -z "$custom_input" ]]; then
  echo "Custom input cannot be empty."
  sleep 2
  exit 1
fi

kernel_version=$(uname -r)
os_version=$(nixos-version | cut -d' ' -f1)
current_date=$(date +%Y-%m-%d)
current_time=$(date +%H-%M-%S)

profile_name="${os_version}_${kernel_version}_${current_date}_${current_time} - ${custom_input}"

sudo nixos-rebuild switch --flake ~/nixos --profile-name "$profile_name"
