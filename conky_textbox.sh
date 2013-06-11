#!/bin/bash

config_file="/home/ben/.config/conkyrc"

conky -c $config_file | while read line ;do echo $line | awesome-client; done
