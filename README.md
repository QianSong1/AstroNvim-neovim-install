# AstroNvim-neovim-install
AstroNvim-neovim-install autoinstall AstroNvim

# Usage

## For Linux

1.Clone this repo
```
git clone --depth=1 https://github.com/QianSong1/AstroNvim-neovim-install.git
```

2.Go to release page download tar.gz files
[Releases](https://github.com/QianSong1/AstroNvim-neovim-install/releases)

3.Download tar.gz files

```
cd AstroNvim-neovim-install
wget xxxxxx.tar.gz
```

4.Install
```
bash install.sh
```



## For Windows

**Requirement**

1.`neovim-0.9.2`

```
#Download the .zip installation package
wget xxxxxx.zip

#Extract to your favorite directory, such as
C:\soft\nvim-win64

#Renaming C:\soft\nvim-win64\bin\nvim.exe  C:\soft\nvim-win64\bin\vim.exe

#Configure user environment variable PATH
C:\soft\nvim-win64\bin
```

2.`gcc`

```
#Download the x86_64-posix-seh installation package
https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z
https://jaist.dl.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z

#Extract to your favorite directory, such as
C:\soft\mingw64

#Configure user environment variable PATH
C:\soft\mingw64\bin
```

3.`git`

```
#Installation reference
https://git-scm.com/download/win
```



**Configuration**

1.Go to release page download .zip files
[Releases](https://github.com/QianSong1/AstroNvim-neovim-install/releases)

2.Download .zip files

```
cd $env:LOCALAPPDATA
wget xxxxxx.zip
```

3.Install

```
cd $env:LOCALAPPDATA
unzip xxxxxx.zip
```

