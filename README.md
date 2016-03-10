# debpackaging

At some point, I'll make a script that just sets everything up. Until then, this is an evolving process.

## How do I make this work?

### 1) Install Packages
apt-get install vim sudo cowbuilder dupload

### 2) Grant yourself sudo rights
As root (usermod -aG sudo YOURUSERNAME)

### 3) Create or Import your GPG key
You'll need your public and private keys. They'll be used to sign the repo.

### 4) Create the build environment
Modify "create_build_environment.sh" to reflect your GPG key, and target release. Then run the script. In time, I'll just make these options on the command-line.

### 5) Create the repo
Modify "repo_setup.sh" to reflect your GPG key, and target release. Then run the script. In time, I'll just make these options on the command-line.

### 6) Pick a workspace
I like to use ~/workspace. This is used to store the source files, packaging files, etc. When using "build_package.sh" and "build_local_package.sh" they assum your current working directory is your workspace.

## I need help?

There is no support. That said, these scripts and methods are based on information from the Debian wiki.

<https://wiki.debian.org/AutomateBackports>
<https://wiki.debian.org/PbuilderTricks>
