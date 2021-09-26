# Win10 dev box setup

This is the repo storing scripts that used to setup my dev machine.

# Getting started

Running the boxstarter script requires admin access.

[One click Web URL to install using Boxstarter (Use Microsoft Edge)](http://boxstarter.org/package/url?https://raw.githubusercontent.com/dignite/win10-dev-box-setup/master/SetupDeveloperMachine.ps1)

# Built With

- Boxstarter
- Chocolatey
- PowerShell
- Scoop

# Developing

Testing the script is a bit cumbersome right now, what you can do is source the script without running it and invoke the individual functions.

As an example you can test "Open manual instructions" with

    . .\SetupDeveloperMachine.ps1 -RunScript $False
    OpenManualInstructions

# Contributing

This repo is for Win 10 dev box and mainly for a full stack developer. These scripts may not suit to your development environment setup requirements. But can be used as starting point to fork and customize.
