#!/usr/bin/env bash

set -e

USER="$(whoami)" 

jq -n --arg user "$USER" '{"user":$user}'

