dotfiles
========

## Install

```
git clone git@github.com:caro5/dotfiles.git && cd dotfiles && ./install.sh
```

### Google Drive configuration

To allow me to have files that are private, and to allow you to override
any of the files that are present in this repository, the installation
script will attempt to link things from `${HOME}/Google Drive/dotfiles`
in the corresponding directories.

Likewise, the `.bash_profile` that is included here will look to source
any files in `${HOME}/Google Drive/dotfiles/bash_profile_includes`.

### VIM Configuration

Currently using [vim-plug](https://github.com/junegunn/vim-plug) to manage VIM plugins.
During installation, it will briefly open VIM to run the plugin installation process.
Edit plugin list at the bottom of the `.vimrc` file.
