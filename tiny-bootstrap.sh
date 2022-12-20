#!/usr/bin/env bash

# Create a Tiny Smalltalk image using Pharo bootstrap.
#
# Arguments:
#     <directory>        Directory where Tiny Smalltalk source code is present (in Tonel format)
#
#
# Example usage:
# ./tiny-bootstrap.sh ../my-image
#

# Bootstrap parameters
DEFAULT_WORD_SIZE="32"
WORD_SIZE="$DEFAULT_WORD_SIZE"
DEFAULT_SOURCE_LOCATION="./bootstrap-source"
SOURCE_LOCATION="$DEFAULT_SOURCE_LOCATION"
DEFAULT_TARGET_FILE_NAME="./tiny.image"
TARGET_FILE_NAME="$DEFAULT_TARGET_FILE_NAME"
DEFAULT_START_UP="Smalltalk startUp"
START_UP="$DEFAULT_START_UP"
DEFAULT_VERSION="1.0"
VERSION="$DEFAULT_VERSION"
DEFAULT_BUILD_NUMBER="42"
BUILD_NUMBER="$DEFAULT_BUILD_NUMBER"

# Run parameters for Pharo environment
VM="./pharo --headless"
RUN_PHARO="$VM Pharo.image"
LOCAL_PHARO_DIR="./pharo-local/iceberg/pharo-project"


# Download the specified file
#
# First arguments specifies which file to download (URL).
function download() {
	if [[ `which curl 2> /dev/null` ]] ; then
		DOWNLOAD="curl --silent --location --compressed $1"
	elif [[ `which wget 2> /dev/null` ]] ; then
		DOWNLOAD="wget --quiet --output-document=- $1"
	else
		echo "Please install curl or wget on your machine"
		exit 1
	fi
	$DOWNLOAD
}

# Download Pharo 10 image and VM
#
# Only download if the image and VM do not seem present (by presence of files 'Pharo.image', 'pharo' and directory 'pharo-vm').
function download_image_and_vm() {
	if [[ -f './Pharo.image' && -f "./pharo" && -d "./pharo-vm" ]] ; then
		echo "Image and VM already installed"
		return
	fi

	echo "Downloading and installing image and VM"
	(download get.pharo.org/64/100+vm | bash)

	# Validate presence of image and VM
	if [[ -f './Pharo.image' && -f "./pharo" && -d "./pharo-vm" ]] ; then
		return
	fi

	echo "The Pharo10 image and VM did not install correctly"
	exit 1
}

# Create local environment
function create_local_environment() {
	mkdir -p $LOCAL_PHARO_DIR
}

# Clone the Pharo repository (and checkout the Pharo10 branch) for bootstrap process
function clone_pharo() {
	if [[ -d "$LOCAL_PHARO_DIR/pharo" && -d "$LOCAL_PHARO_DIR/pharo/bootstrap" ]] ; then
		echo "Pharo repository already cloned (using the current branch)"
		return
	fi

	echo "Cloning Pharo repository (checking out Pharo10 branch)"
	rm -rf "$LOCAL_PHARO_DIR/pharo"
	git clone --branch Pharo10 https://github.com/pharo-project/pharo.git "$LOCAL_PHARO_DIR/pharo"
	if [[ ! -d "$LOCAL_PHARO_DIR/pharo" || ! -d "$LOCAL_PHARO_DIR/pharo/bootstrap" ]] ; then
		echo "Failed to clone the Pharo repository"
		exit 1
	fi
}

# Execute a Smalltalk script (on image and save it)
function smalltalk_execute() {
	RESULT="$($RUN_PHARO eval --save $1 2>&1 > /dev/null)"

	[[ "$RESULT" != "FAILURE" ]]
	return
}

# Install the specified baseline (using given repo URL)
#
# First argument specifies baseline name (excluding prefix BaselineOf)
# second argument specifies the repo location as URL.
function install_baseline() {
	echo "Hoi"
}

# Fix location of Pharo repository (by default Pharo is loaded ;-)
function fix_location_pharo_repository() {
	SCRIPT="
		| pharoRepository |
		pharoRepository := IceLibgitRepository allInstances
			detect: [ :each | each name = 'pharo' ]
			ifNone: [ nil ].
		pharoRepository
			ifNotNil: [
				pharoRepository location ifNil: [
					pharoRepository
						location: IceLibgitRepository repositoriesLocation / 'pharo-project' / 'pharo' ;
						postFetch ;
						discardChanges ] ]
			ifNil: [ VTermOutputDriver stderr << 'FAILURE' ]."

	echo "Setup Pharo repository (connect to git clone source)"
	if ! smalltalk_execute "$SCRIPT" ; then
		echo "Failed to setup Pharo repository"
		exit 1
	fi
}

# Load Pharo bootstrap process
function load_pharo_bootstrap_process_baseline() {
	SCRIPT="
		(Smalltalk classNamed: 'PBImageBuilderSpur5032bit') ifNil: [
			Metacello new 
				baseline: 'PharoBootstrapProcess' ;
				repository: 'tonel://./pharo-local/iceberg/pharo-project/pharo/bootstrap/src' ;
				onConflictUseIncoming ;
				load.

			(Smalltalk classNamed: 'PBImageBuilderSpur5032bit')
				ifNil: [ VTermOutputDriver stderr << 'FAILURE' ] ]."

	echo "Loading baseline PharoBootstrapProcess (part of Pharo repository)"
	if ! smalltalk_execute "$SCRIPT" ; then
		echo "Failed to load PharoBootstrapProcess repository (which is part of Pharo repository)"
		exit 1
	fi
}

# Load Espell
function load_espell() {
	SCRIPT="
		(Smalltalk classNamed: 'EPASTInterpreter') ifNil: [
			Metacello new 
				baseline: 'Espell';
				repository: 'github://guillep/espell:v1.6.1/src';
				onConflictUseIncoming ;
				load.

			(Smalltalk classNamed: 'EPASTInterpreter')
				ifNil: [ VTermOutputDriver stderr << 'FAILURE' ] ]."

	echo "Loading baseline espell (for runtime interaction)"
	if ! smalltalk_execute "$SCRIPT" ; then
		echo "Failed to load espell repository"
		exit 1
	fi
}

# Load Tiny Bootstrap
function load_tiny_bootstrap() {
	SCRIPT="
		(Smalltalk classNamed: 'PBTinyBootstrap') ifNil: [
			Metacello new 
				baseline: 'TinyBootstrap';
				repository: 'github://ErikOnBike/TinyBootstrap:main';
				onConflictUseIncoming ;
				load.

			(Smalltalk classNamed: 'PBTinyBootstrap')
				ifNil: [ VTermOutputDriver stderr << 'FAILURE' ] ]."

	echo "Loading baseline TinyBootstrap (for creating tiny images)"
	if ! smalltalk_execute "$SCRIPT" ; then
		echo "Failed to load TinyBootstrap repository"
		exit 1
	fi
}

# Load prerequisites
function load_prerequisites() {
	fix_location_pharo_repository
	load_pharo_bootstrap_process_baseline
	load_espell
	load_tiny_bootstrap
}

# Execute bootstrap process
function perform_bootstrap() {
	echo "Perform bootstrap process"
	echo "    architecture:  $WORD_SIZE (bits)"
	echo "    source:        $SOURCE_LOCATION"
	echo "    start up:      $START_UP"
	echo "    target:        $TARGET_FILE_NAME"
	echo "    version:       $VERSION"
	echo "    build:         $BUILD_NUMBER"

	# Create Smalltalk code to evaluate presence of Class
	RUN_COMMAND="[
		PBTinyBootstrap
			bootstrapArchitecture: 'TinyImage$WORD_SIZE'
			fromSource: '$SOURCE_LOCATION'
			into: '$TARGET_FILE_NAME'
			startUp: '${START_UP//\'/''}'
			version: '$VERSION'
			buildNumber: $BUILD_NUMBER.
		VTermOutputDriver stderr << 'SUCCESS'.
	] on: Error do: [ :error |
		VTermOutputDriver stderr << 'ERROR' << Character lf.
		error signalerContext errorReportOn: VTermOutputDriver stderr.
		VTermOutputDriver stderr
			<< Character lf
			<< Character lf
			<< 'The following error occurred (stack trace above):' << Character lf
			<< error printString << Character lf ]."

	# Perform evaluation, not saving the image and assuming stderr contains relevant result (stdout is ignored)
	CHECK="$($RUN_PHARO eval "$RUN_COMMAND" 2>&1 > /dev/null)"

	# Show error (or success) and removing some escaping that makes noice ruins your prompt
	echo "$CHECK" |  sed 's/\x1b[\[]//g'

	[[ "$CHECK" = "SUCCESS" ]]
	return
}

# Show help/usage
function show_help() {
	echo "Use: ${0##*/} [<options>]"
	echo ""
	echo "Where options can be:"
	echo "    -a|--architecture <bits>"
	echo "        word size in bits, either 32 or 64 (default value: $DEFAULT_WORD_SIZE)"
	echo "    -s|--source <directory>"
	echo "        directory containing the bootstrap source code (default value: $DEFAULT_SOURCE_LOCATION)"
	echo "    -t|--target <filename>"
	echo "        filename for the final tiny image (default value: $DEFAULT_TARGET_FILE_NAME)"
	echo "    -c|--start-up <start up code>"
	echo "        Smalltalk code to start up the image (default value: $DEFAULT_START_UP)"
	echo "    -v|--version <string>"
	echo "        version info (default value: $DEFAULT_VERSION)"
	echo "    -b|--build <number>"
	echo "        build number (default value: $DEFAULT_BUILD_NUMBER)"
	echo "    -h|--help"
	echo "        show this help text"
	exit 0
}

# Set options (ie extract arguments from command line or choose defaults)
function set_options() {
	UNKNOWN_OPTIONS=""
	while [[ $# -gt 0 ]] ; do
		case $1 in
			-a|--architecture)
				WORD_SIZE="$2"
				shift
				shift
				;;
			-s|--source)
				SOURCE_LOCATION="$2"
				shift
				shift
				;;
			-t|--target)
				TARGET_FILE_NAME="$2"
				shift
				shift
				;;
			-c|--start-up)
				START_UP="$2"
				shift
				shift
				;;
			-v|--version)
				VERSION="$2"
				shift
				shift
				;;
			-b|--build)
				BUILD_NUMBER="$2"
				shift
				shift
				;;
			-h|--help)
				UNKNOWN_OPTIONS="HELP"
				shift
				;;
			*)
				UNKNOWN_OPTIONS="#$UNKNOWN_OPTIONS"
				echo "Unknown option $1 (ignoring)"
				shift
				;;
		esac
	done

	if [[ "$UNKNOWN_OPTIONS" != "" ]] ; then
		echo ""
		show_help
	fi
}

##############################################################################
# Perform the steps for the bootstrap process

# Retrieve options from command line
set_options "$@"

# First download VM
download_image_and_vm

# Create local environment (to store Pharo repository in)
create_local_environment

# Clone Pharo 10 image (containing bootstrap process code)
clone_pharo

# Setup image
load_prerequisites

# Perform bootstrap process (now that everything is setup and loaded)
perform_bootstrap
