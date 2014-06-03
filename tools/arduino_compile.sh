#!/bin/bash

# Make sure to download MPIDE and place .app in Applications folder.
# https://github.com/chipKIT32/chipKIT32-MAX/downloads

# Check proper usage
if [ $# -ne 1 ]
then
	echo "Usage: `basename $0` [file.s]"
	oldmodes=`stty -g`
	stty -echo
    read -n1 -r -p "Press any key to continue . . ." key
    echo -e "\n"
	stty $oldmodes
	exit 65
fi

# Get file info
FILE="${1##*/}"
NAME="${FILE%.*}"
DIR=`dirname $1`

# Set the path so we can run MPIDE programs
MPIDE_PATH=/Applications/mpide.app/Contents/Resources/Java
export PATH=$PATH:$MPIDE_PATH/hardware/pic32/compiler/pic32-tools/bin

pic32-g++ -c -mprocessor=32MX320F128H -I. "-I$MPIDE_PATH/hardware/pic32/cores/pic32" "-I$MPIDE_PATH/hardware/pic32/variants/Uno32" -O0 $DIR/main.cpp -o $DIR/main.o

pic32-as -march=pic32mx -I. $DIR/$FILE -o $DIR/$NAME.o

pic32-g++ -Os -Wl,--gc-sections -mdebugger -mprocessor=32MX320F128H  -o $DIR/$NAME.elf  $DIR/main.o $DIR/$NAME.o $DIR/core.a -T  "$MPIDE_PATH/hardware/pic32/cores/pic32/chipKIT-UNO32-application-32MX320F128L.ld"

pic32-bin2hex -a $DIR/$NAME.elf

pic32-objdump -h -S $DIR/$NAME.elf > $DIR/$NAME.lss

pic32-nm -n $DIR/$NAME.elf > $DIR/$NAME.sym

echo "Done! (Were there any errors or warnings?)"
oldmodes=`stty -g`
stty -echo
read -n1 -r -p "Press any key to continue . . ." key
echo -e "\n"
stty $oldmodes

