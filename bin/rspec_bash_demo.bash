#!/bin/bash

# rspec_bash_demo.bash

# This command should fail unless I am root:
echo hello world > /bloom.txt

# This command should succeed:
echo hello world > /tmp/bikle.txt
