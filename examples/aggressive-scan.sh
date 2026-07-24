#!/bin/bash
# Aggressive scan with output
sudo KNOCK --ai -A -T4 -oA "scan_$(date +%Y%m%d)" "$1"
