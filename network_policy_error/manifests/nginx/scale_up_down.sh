#!/bin/bash

while true;do
  echo "scale down"
  kubectl scale deployment nginx --replicas=6 -n nginx
  sleep 20

  echo "scale up"
  kubectl scale deployment nginx --replicas=40 -n nginx
  sleep 20
done
