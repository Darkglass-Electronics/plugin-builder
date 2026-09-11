plugin-builder
==============

This repository contains the toolchain and libraries used in Darkglass Linux-based devices.

There are several dependencies:
 - gcc & g++
 - git
 - subversion
 - hg/mercurial
 - autoconf
 - automake
 - bzip2
 - lzma
 - binutils
 - libtool
 - ncurses
 - rsync
 - wget
 - bc
 - bison
 - flex
 - help2man
 - gawk
 - gperf
 - texinfo

If you're running a debian based system you can install all dependencies by running:
```
sudo apt install acl bc curl cvs git mercurial rsync subversion wget \
bison bzip2 flex gawk gperf gzip help2man nano perl patch tar texinfo unzip \
automake binutils build-essential cpio libtool libcrypt-dev libncurses-dev pkg-config python-is-python3 libtool-bin
```

To begin simply run:<br/>
```
./bootstrap.sh <platform>
```

Where `platform` is either `darkglass-anagram` or `darkglass-anagram-gcc15`.

The script will build the toolchain (ct-ng) and buildroot.<br/>
Depending on your machine it can take more than 1 hour.<br/>

All files will be installed in `~/darkglass-linux-workdir`.<br/>
Set the 'WORKDIR' environment variable before bootstraping if you wish to change that.

After the bootstrap process is complete, you can start building plugins.

### Building plugins and more

See [Plugin-Dev-Setup](https://github.com/Darkglass-Electronics/Plugin-Dev-Setup) for documentation and examples related to developing audio plugins for Darkglass Linux-based devices.

### History

This source code repository was forked from [mod-audio/mod-plugin-builder](https://github.com/mod-audio/mod-plugin-builder) on 2026-09-11.
Only things related to Darkglass remain here, please check the original for anything related to MOD Audio and their devices.
