#!/usr/bin/env bash

# Install script to create all of the symlinks for this directory

function safe_link {
  FROM_FILE=$1
  TO_FILE=$2

  if [[ -e "${TO_FILE}" && ! -L "${TO_FILE}" ]]; then
    echo "Moving ${TO_FILE} to ${TO_FILE}_bak"
    mv "${TO_FILE}" "${TO_FILE}_bak"
  elif [[ -e "${TO_FILE}" ]]; then
    echo "Removing symlink to ${FROM_FILE}"
    rm "${TO_FILE}"
  fi
  ln -sfv "${FROM_FILE}" "${TO_FILE}"
}

function setup_scm_breeze {
  THIS_DIR=`pwd`
  scmbDir="$THIS_DIR/submodules/scm_breeze"
  SCM_BREEZE_INSTALL_DIR="$HOME/.scm_breeze"

  if [[ ! -e "$HOME/.scm_breeze" ]]; then
    echo "Installing scm_breeze: Symlinking $SCM_BREEZE_INSTALL_DIR to $scmbDir"
    ln -fs "$scmbDir" "$SCM_BREEZE_INSTALL_DIR"
    source "$scmbDir/lib/scm_breeze.sh"
    echo "Installing scm_breeze: Creating .scmbrc"
    _create_or_patch_scmbrc
    echo "Installing scm_breeze: Completed."
  else
    echo "Installing scm_breeze: Extant symlink $SCM_BREEZE_INSTALL_DIR, skipping install."
  fi
}

function install_files {
  FROM_DIR=$1
  TO_DIR=$2
  PREFIX_WITH_DOT=$3

  if [[ -z "${FROM_DIR}" ]]; then
    echo "Cannot copy files from an empty directory!"
    return 1
  fi

  if [[ ! -e "${TO_DIR}" ]]; then
    echo "Making directory ${TO_DIR}"
    mkdir "${TO_DIR}" 2>/dev/null
    if [[ ! -d "${TO_DIR}" ]]; then
      echo "Directory ${TO_DIR} does not exist after attempting to make it. Skipping."
      return 1
    fi
  elif [[ ! -d "${TO_DIR}" ]]; then
    echo "${TO_DIR} exists and is not a directory. Skipping installation from ${FROM_DIR}"
    return 1
  fi

  echo "Installing files from ${FROM_DIR} to ${TO_DIR}"

  if [[ -d "${FROM_DIR}" ]]; then
    for file in "${FROM_DIR}"/*
    do
      if [[ -e "$file" ]]; then
        file_name=`basename "${file}"`

        if [[ -z "$PREFIX_WITH_DOT" ]]; then
          safe_link "${FROM_DIR}"/${file_name} "${TO_DIR}/${file_name}"
        else
          safe_link "${FROM_DIR}"/${file_name} "${TO_DIR}/.${file_name}"
        fi
      fi
    done
  else
    echo "${FROM_DIR} does not exist. Skipping."
  fi
}

function link_bash_profile_includes {
  FROM_DIR=$1
  if [[ -z "${FROM_DIR}" ]]; then
    echo "Cannot copy files from an empty directory!"
    return 1
  fi

  pushd "$HOME"

  if [[ -e ".bash_profile_includes" && ! -L ".bash_profile_includes" ]]; then
    echo "${HOME}/.bash_profile_includes already exists and is not symlink\'ed. Not modifying."
  elif [[ -L ".bash_profile_includes" ]]; then
    echo "${HOME}/.bash_profile_includes is a symlink already. Removing it and pointing it here."
    rm ~/.bash_profile_includes
    ln -sfv "${START_PWD}/bash_profile_includes" .bash_profile_includes
  else
    ln -sfv "${START_PWD}/bash_profile_includes" .bash_profile_includes
  fi

  popd
}

function backup_vim_files {
  pushd "${HOME}" > /dev/null

  if [[ -e ".vim" && -e ".vim/janus" ]]; then
    mv .vim .vim_bak
  fi

  popd > /dev/null
}

function get_tmux_vs {
  TMUX_VS=$(tmux -V)
  echo ${TMUX_VS} | cut -d " " -f 2
}

function download_tmux_linux {
  local VERSION=2.6
  sudo apt-get -y remove tmux
  sudo apt-get -y install wget tar libevent-dev libncurses-dev
  wget https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz
  tar xf tmux-${VERSION}.tar.gz
  rm -f tmux-${VERSION}.tar.gz
  cd tmux-${VERSION}
  ./configure
  make
  sudo make install
  cd -
  sudo rm -rf /usr/local/src/tmux-*
  sudo mv tmux-${VERSION} /usr/local/src
}

function download_tmux_darwin {
  brew install tmux
  brew cleanup tmux
}

function install_tmux {
  if [[ $(get_tmux_vs) < 2.6 ]]; then
    OS=`uname -s`
    # Download tmux for linux
    if [[ "Linux" == "$OS" ]]; then
      download_tmux_linux
    else
      download_tmux_darwin
    return 0
    fi
    echo "Logout and login to shell again to get updated tmux"
  fi
}

########## MAIN ###########
if [[ $0 == ./* ]]; then
  START_PWD=`pwd`
else
  START_PWD=`dirname $0`
fi

echo "First, ensuring submodules are up-to-date."
git submodule init
git submodule update --recursive


# if the directory doesn't exist, create dir and download tpm. (needed for tmux-resurrect)
if [ ! -d ~/.tmux/plugins/tpm ]; then
  mkdir -p ~/.tmux/plugins/tpm
  git clone https://github.com/tmux-plugins/tpm.git ~/.tmux/plugins/tpm
fi

if [[ -d "${HOME}/Google Drive/dotfiles" ]]; then
  PRIVATE_FILE_PATH="${HOME}/Google Drive/dotfiles"
fi

link_bash_profile_includes "$START_PWD"
install_files "${START_PWD}"/bin "${HOME}"/bin
install_files "${START_PWD}"/dotfiles "${HOME}" true

if [[ -n "${PRIVATE_FILE_PATH}" ]]; then
  install_files "${PRIVATE_FILE_PATH}"/bin "${HOME}"/bin
  install_files "${PRIVATE_FILE_PATH}"/ssh "${HOME}/.ssh"
  install_files "${PRIVATE_FILE_PATH}"/dotfiles "${HOME}" true
fi

echo
setup_scm_breeze
echo
install_tmux
echo

if [[ $1 != '--no-vim' ]]; then
  echo "Running VIM file installation."
  echo "Backing up old VIM files as necessary."
  backup_vim_files

  if [[ ! -d "${HOME}"/.vim/autoload ]]; then
    mkdir -p ~/.vim/autoload
  fi
  safe_link "${START_PWD}/submodules/vim-plug/plug.vim" "${HOME}/.vim/autoload/plug.vim"

  echo "Installing VIM plugins via vim-plug"
  vim -s vim_startup_commands
fi
