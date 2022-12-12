# TinyBootstrap
Bootstrapper for Tiny Smalltalk images using Pharo. The tiny images generated are Sista bytecode compatible and should be able to run using a recent [Pharo VM](https://github.com/pharo-project/pharo-vm) or [OpenSmalltalk VM](https://github.com/OpenSmalltalk/opensmalltalk-vm) or using the [SqueakJS VM](https://github.com/codefrau/SqueakJS).

*The bootstrapper in this repo is working, but making it publicly available is WIP ;-). Documentation and examples should arrive the coming days...stay tuned!*

Tiny images are headless images with a small subset of a regular Smalltalk implementation/library.

## Purposes
A tiny image can be run inside a webbrowser using the [SqueakJS VM](https://github.com/codefrau/SqueakJS) or from the command line using nodejs using the headless bundle.

## Examples
The source code for some example images is provided. The final image size should be around 150Kb to 300Kb for these examples (64 bit versions are around 50% larger than 32 bit versions).

## Origin
The bootstrapper is created to allow the tiny image for [CodeParadise](https://github.com/ErikOnBike/CodeParadise) to be bootstrapped. The source code for that tiny image can be found at [CP-Bootstrap](https://github.com/ErikOnBike/CP-Bootstrap).
