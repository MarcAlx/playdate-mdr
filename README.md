# playdate-mdr

Macrodata Refinement terminal for play.date

![](./gif/demo.gif)

@see https://severance.wiki/macrodata_refinement

_n.b - please note that this is a current work in progress with no ETA, no gameplay planned and code all over the place._

_n.b 2 - further testing on device may be required_

## Getting started

### Pre-requisite

- Download Playdate sdk here : https://play.date/dev/ 

- Install it, on `macOS` Playdate sdk installation is located here: `~/Developer/PlaydateSDK`

### Start

1. Build/Compile game :

       pdc source dist/mdr-terminal.pdx

    or

        run and build in vscode

2. Run it on emulator :

    1. (macOS) launch `~/Developer/PlaydateSDK/bin/Playdate Simulator.app`

    2. In the simulator use file menu to load `dist/mdr-terminal.pdx`
    
3. While developping :

    1. Re build

    2. Restart simulator (cmd-r on macOS)

4. Sideload on real-device

    https://help.play.date/games/sideloading/

## Building for release

    pdc -s source dist/mdr-terminal.pdx

## Usefull links

https://www.gingerbeardman.com/canvas-dither/