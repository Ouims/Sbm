# Super Bomberman

A recreation of Super Bomberman 2 battle mode online for both mIRC and AdiIRC.

## Installation

Sets to install the project:

- Download the latest released version.
- Extract everything from dist folder to any location on your system.
- Load `sbm.mrc` from the location of the previous step onto your client.
- Enjoy!

## Development

### Process

Load `bundler.mrc` from the root folder onto your client, do your thing on the `src/` folder. When you make your client the active application the bundler will look up any changes, if there are any it will bundle the all the files then reload `dist\sbm.mrc`.
