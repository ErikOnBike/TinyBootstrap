# TinyBootstrap
Bootstrapper for Tiny Smalltalk images using Pharo. The tiny images generated are Sista bytecode compatible and should be able to run using a recent [Pharo VM](https://github.com/pharo-project/pharo-vm) or [OpenSmalltalk VM](https://github.com/OpenSmalltalk/opensmalltalk-vm) or using the [SqueakJS VM](https://github.com/codefrau/SqueakJS).

Tiny images are headless images with a small subset of a regular Smalltalk implementation/library.

## Purposes
The tiny image has little default functionality, but can be extended to have some file or network handling. This allows small tools to be created using Smalltalk scripts. A tiny image can also be run inside a webbrowser using the [SqueakJS VM](https://github.com/codefrau/SqueakJS) or from the command line using nodejs using the headless bundle.

## Usage
The bootstrapper can be run from a regular Pharo 10 image or using the provided shell script (which will download, install and execute all relevant code). The script accepts a number of parameters. Use `./tiny-bootstrap.sh -h` for help.

## Examples
The source code for some example images is provided. The final image size should be around 150Kb to 300Kb for these examples (64 bit versions are around 50% larger than 32 bit versions).

Use the following script to create a working directory and bootstrap a tiny image for one of the examples. The bootstrap process will take some time on the first run since it will import quite some code. After the first run, the bootstrap source code (the example code) can be changed and re-running the (last line of the) script will be a lot faster. Only the actual bootstrap process will be executed then.

```bash
git clone https://github.com/ErikOnBike/TinyBootstrap
cd TinyBootstrap
./tiny-bootstrap.sh -a 64 -s ./examples/src -t test.image -c "Example42 doIt"
```

### Example42
The Example42 is an example that will simply show `Answer: 42` on the console (using /dev/stdout).

```bash
./tiny-bootstrap.sh -a 64 -s ./examples/src -t example42.image -c "Example42 doIt"
```

If the tiny image is created correctly, you can execute it using:
```bash
./pharo example42.image
```

### ExampleDir
The ExampleDir is an example that will print all the entries (printString of directory entry which is Array of values) in the current directory on the console (using /dev/stdout).

```bash
./tiny-bootstrap.sh -a 64 -s ./examples/src -t example-dir.image -c "ExampleDir doIt"
```

If the tiny image is created correctly, you can execute it using:
```bash
./pharo example-dir.image
```

## Origin
The bootstrapper is created to allow the tiny image for [CodeParadise](https://github.com/ErikOnBike/CodeParadise) to be bootstrapped. The source code for that tiny image can be found at [CP-Bootstrap](https://github.com/ErikOnBike/CP-Bootstrap).
