#!/bin/sh

while true; do
    sleep 5
    python killboard.py
    echo "Killboard script exited. Restarting in 5 seconds..."
    sleep 5
done