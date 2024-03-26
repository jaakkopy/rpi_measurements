#!/bin/bash

user=$1
host=$2

scp ./experiment2.py ${user}@${host}:/home/${user}/