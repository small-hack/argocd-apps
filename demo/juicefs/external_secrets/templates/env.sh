export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_HOME="$HOME/.local"

# iptables on debian is here
export PATH=$PATH:/usr/sbin:/usr/share

# pip packages with command line tools install here by default with apt installed python
export PATH=$PATH:$XDG_DATA_HOME/bin

# this relative is used for both macOS and Debian based distros
pip_path_suffix="lib/python$PYTHON_VERSION/site-packages"

# apt installed location of pip installed python3.x packages
pip_packages="$HOME/.local/$pip_path_suffix"

# make python do it's cache in ~/.cache/python
export PYTHONPYCACHEPREFIX=$XDG_CACHE_HOME

# python default install location when you: pip$VERSION install --user package
export PATH=$PATH:$HOME/.local/bin:/usr/local/bin

# Run py cmds in this file b4 the 1st prompt is displayed in interactive mode
export PYTHONSTARTUP=$XDG_CONFIG_HOME/python/interactive_startup.py

# HomeBrew on Linux needs all of this to work
export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
export HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar
export HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew
export MANPATH=$MANPATH:/home/linuxbrew/.linuxbrew/share/man
export INFOPATH=$INFOPATH:/home/linuxbrew/.linuxbrew/share/info
export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin

# make sure this is all in the bashrc for new shells
echo "export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew" >> ~/.bashrc
echo "export HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar" >> ~/.bashrc
echo "export HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew" >> ~/.bashrc
echo "export MANPATH=$MANPATH:/home/linuxbrew/.linuxbrew/share/man" >> ~/.bashrc
echo "export INFOPATH=$INFOPATH:/home/linuxbrew/.linuxbrew/share/info" >> ~/.bashrc
echo "PATH=$PATH:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin" >> ~/.bashrc

# We will remove /usr/lib/python3.*/EXTERNALLY-MANAGED until Debian Bookworm decides on a better way forward with virtual envs.
sudo rm /usr/lib/python3.*/EXTERNALLY-MANAGED
