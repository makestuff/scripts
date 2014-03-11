#!/bin/sh
export ZADIG=${HOME}/3rd/zadig.exe
if [ ! -e ${ZADIG} ]; then
    export URL=http://zadig.akeo.ie/downloads/zadig_v2.0.1.161.exe
    echo "Downloading zadig.exe from ${URL}..."
    wget -qO ${ZADIG} ${URL}
fi
echo "Launching zadig.exe..."
cmd //c ${ZADIG}
echo "Done!"
