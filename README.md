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

Or specify which directory to show:
```bash
./pharo example-dir.image ./examples/src
```

### ExampleCounter
The ExampleCounter is an example that will print a counter value on the console (using /dev/stdout) on each run. The counter will be increased/decreased after being printed. The counter will go from 0 to 10 and back to 0 again (and repeat). This example shows the tiny image can be saved (more precisely, I snapshot can be made).

```bash
./tiny-bootstrap.sh -a 64 -s ./examples/src -t example-counter.image -c "ExampleCounter doIt"
```

If the tiny image is created correctly, you can execute it using the following (execute it repeatedly to see the counter change).
```bash
./pharo example-counter.image
```

### Dynamic image
The Dynamic image is an image which has a pre-installed code loader. This allows code to be added (or removed) dynamically from a tiny image. Code can also be executed from the command line (simple class method invocation). Once the image contains all required code, it can also be 'fused', removing the code needed for dynamic code loading. When fused, the image is fixated to a specified execution method.

To create the dynamic image:
```bash
./tiny-bootstrap.sh -a 64 -s ./dynamic/src -t dynamic.image -c "TtDynamic doIt"
```

For usage execute the following:
```bash
./pharo dynamic.image --help
```

Installing or uninstalling code is not permanent. Please add the `save` option to make it permanent. Not making it permanent by default allows to install code and try it out, before actually 'keeping' the change. Also the TtInspector from the TinyTools can be installed and executed, without having the change the image (permanently). 

For examples of usage (installing and executing code), please check out the [TinyTools](https://github.com/ErikOnBike/TinyTools).

## Origin
The bootstrapper is created to allow the tiny image for [CodeParadise](https://github.com/ErikOnBike/CodeParadise) to be bootstrapped. The source code for that tiny image can be found at [CP-Bootstrap](https://github.com/ErikOnBike/CP-Bootstrap).
