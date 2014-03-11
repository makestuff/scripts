#!/bin/sh

if [ ! -e /bin/zadig.exe ]; then
    export URL=http://zadig.akeo.ie/downloads/zadig_v2.0.1.161.exe
    echo "Downloading zadig.exe from ${URL}..."
    wget -qO /bin/zadig.exe ${URL}
fi
echo "Launching zadig.exe..."
cmd //c /bin/zadig.exe
echo "Done!"
