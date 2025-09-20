## Overview

You are in a NixOS config folder. This config uses flake, home manager and has some shells which
uses direnv to trigger specific environments depending on user needs.

Answer user requests based on the config files, read any file that you need and also run any command
which reads system information, but don't execute any change on system or in file withoout user permission
first.

Also you don't have sudo access, so if you need to run any sudo command, ask the user to run for you.
