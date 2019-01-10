- [`addToBashd`](#addToBashd)
- [`aptInstall`](#aptInstall)
- [`black`](#black)
- [`blue`](#blue)
- [`cleanDebPkgs`](#cleanDebPkgs)
- [`cleanTmp`](#cleanTmp)
- [`clearBasher`](#clearBasher)
- [`cyan`](#cyan)
- [`die`](#die)
- [`dload`](#dload)
- [`error`](#error)
- [`getGitHubLatest`](#getGitHubLatest)
- [`getUserDp`](#getUserDp)
- [`green`](#green)
- [`hasBuildArg`](#hasBuildArg)
- [`initDebPkgs`](#initDebPkgs)
- [`initTmp`](#initTmp)
- [`installBashd`](#installBashd)
- [`installBasher`](#installBasher)
- [`installBasherPkg`](#installBasherPkg)
- [`installDebBatPkg`](#installDebBatPkg)
- [`installDebPkgs`](#installDebPkgs)
- [`installDirs`](#installDirs)
- [`installFlexos`](#installFlexos)
- [`installFlexosPy`](#installFlexosPy)
- [`installFlexosSh`](#installFlexosSh)
- [`installPy`](#installPy)
- [`installPyPkgs`](#installPyPkgs)
- [`installSudoUser`](#installSudoUser)
- [`installUser`](#installUser)
- [`is`](#is)
- [`isb`](#isb)
- [`isc`](#isc)
- [`isd`](#isd)
- [`ise`](#ise)
- [`isl`](#isl)
- [`isn`](#isn)
- [`isr`](#isr)
- [`isx`](#isx)
- [`isz`](#isz)
- [`pink`](#pink)
- [`red`](#red)
- [`redBold`](#redBold)
- [`setUser`](#setUser)
- [`stderr`](#stderr)
- [`sudoc`](#sudoc)
- [`sudof`](#sudof)
- [`upgradeDebPkgs`](#upgradeDebPkgs)
- [`warn`](#warn)
- [`white`](#white)
- [`yellow`](#yellow)

***

## `addToBashd`

Add and read (source) a `bash.d` profile file (see `installBashd()` for `bash.d` details).

#### Usage

```shell
addToBashd <file_path> [<directory_path>]
```

#### Arguments

- file_path
    - Path to profile file
- directory_path
    - `bash.d` parent folder, see `installBashd()` for details

#### Examples

```shell
addToBashd /tmp/bar            # creates /root/.bash.d/bar
addToBashd /tmp/bar etc        # creates /etc/bash.d/bar
sudof foo addToBashd /tmp/bar  # creates /home/foo/.bash.d/bar
sudof foo addToBashd ${DECKBUILD_KIT_STOCK}/python/55_python.sh
```

## `aptInstall`

Install debian packages (`apt-get install`).

#### Usage

```shell
aptInstall <packages>
```

#### Examples

```shell
aptInstall curl wget
```

## `black`

Print a black message to stderr.

#### Usage

```shell
black <message>
```

## `blue`

Print a blue message to stderr.

#### Usage

```shell
blue <message>
```

## `cleanDebPkgs`

Clean debian package repository (`apt-get autoremove`).

#### Usage

```shell
cleanDebPkgs [<delete_files>]
```

#### Arguments

- delete_files
    - Clear also `/var/lib/apt/lists/*` if set to `true` or `1`

#### Examples

```shell
cleanDebPkgs true
```

## `cleanTmp`

Delete the temporary directory created by `initTmp()`.

#### Usage

```shell
cleanTmp
```

#### Examples

```shell
cleanTmp              # clean default tmp folder
initTmp; cleanTmp     # create/clean a custom tmp folder
```

## `clearBasher`

Clear basher environment (`unset BASHER_*`).

#### Usage

```shell
clearBasher
```

## `cyan`

Print a cyan message to stderr.

#### Usage

```shell
cyan <message>
```

## `die`

Print a red error message to stderr and abort process.

#### Usage

```shell
die <message> [<exit_code>]
```

#### Examples

```shell
die "Database unreachable"     # exit code is 1
die "No network connection" 5  # exit code is 5
```

## `dload`

Download file (`curl https://...`).

#### Usage

```shell
dload <url> [<destination_file>]
```

#### Examples

```shell
dload https://example.org/foo.txt /tmp/foo.txt # download to file
fooTxt=$(dload https://example.org/foo.txt)    # assign to fooTxt variable
```

## `error`

Print a red error message to stderr.

#### Usage

```shell
error <message>
```

#### Examples

```shell
error "Downloading file failed"
```

## `getGitHubLatest`

Get latest software version of a GitHub repository: Returns the version and sets `${_DECKBUILD_GITHUB_LATEST}`.

#### Usage

```shell
getGitHubLatest <repo>
```

#### Examples

```shell
# for https://api.github.com/repos/foobar/releases/latest:
getGitHubLatest foobar
```

## `getUserDp`

Get user's home directory.

#### Usage

```shell
getUserDp <user>
```

#### Examples

```shell
getUserDp foo
```

## `green`

Print a green message to stderr.

#### Usage

```shell
green <message>
```

## `hasBuildArg`

Check if `${DECKBUILD_ARGS}` contains given argument.

#### Usage

```shell
hasBuildArg <arg> [<separator>]
```

#### Arguments

- separator
    - Argument separator (e.g. `,`), default is whitespace

#### Examples

```shell
hasBuildArg -h
hasBuildArg -A ,
```

## `initDebPkgs`

Update debian package repository if necessary (`apt-get update`). Necessary means: `${_DECKBUILD_DEB_REPO_INIT}` is not set (`initDebPkgs()` sets `${_DECKBUILD_DEB_REPO_INIT}` after running).

#### Usage

```shell
initDebPkgs
```

#### Examples

```shell
unset ${_DECKBUILD_DEB_REPO_INIT}; initDebPkgs  # force action
```

## `initTmp`

Create a temporary directory (`mktemp -d`) and export the path as `${_DECKBUILD_TMP}`. BUT: You don't need to run `initTmp()` because a default tmp folder is always available.

#### Usage

```shell
initTmp
```

#### Examples

```shell
touch ${_DECKBUILD_TMP}/foo.txt          # use default tmp folder
initTmp; touch ${_DECKBUILD_TMP}/foo.txt # create/use a custom tmp folder
```

## `installBashd`

Initialize `bash.d` environment: bash.d folders store bash profile files. Profile files will be read (sourced) during container startup. BUT: Don't call this function directly, use `addToBashd()` instead.

#### Usage

```shell
installBashd [<directory_path>]
```

#### Arguments

- directory_path
    - `bash.d` parent folder, default is user's `${HOME}`

#### Examples

```shell
installBashd            # creates /root/.bash.d
sudof foo installBashd  # creates /home/foo/.bash.d
installBashd etc        # creates /etc/bash.d
```

## `installBasher`

Install [basher](https://github.com/basherpm/basher) environment (for specific user). BUT: Don't call this function directly, use `installBasherPkg()` instead.

#### Usage

```shell
installBasher
```

#### Examples

```shell
installBasher            # install basher for root
sudof foo installBasher  # install basher for user foo
```

## `installBasherPkg`

Install a [basher](https://github.com/basherpm/basher) package (see `installBasher()` for basher details).

#### Usage

```shell
installBasherPkg
```

#### Examples

```shell
installBasherPkg bar            # install bar package for root
sudof foo installBasherPkg bar  # install bar package for user foo
```

## `installDebBatPkg`

Install [bat's](https://github.com/sharkdp/bat) latest version.

#### Usage

```shell
installDebBatPkg
```

## `installDebPkgs`

Install some useful debian packages (`apt-get install sudo curl ...`).

#### Usage

```shell
installDebPkgs
```

## `installDirs`

Simplify system's directory structure (e.g. merge `/usr/local/bin` and `/usr/local/sbin`).

#### Usage

```shell
installDirs
```

## `installFlexos`

Install flexos environment (for specific user).

#### Usage

```shell
installFlexos [<directory_path>]
```

#### Arguments

- directory_path
    - `bash.d` parent folder, see `installBashd()` for details

#### Examples

```shell
installFlexos            # adds flexos files to root's bash.d folder
sudo foo installFlexos   # adds flexos files to user foo's bash.d folder
```

## `installFlexosPy`

Install flexos python packages (for specific user).

#### Usage

```shell
installFlexosPy
```

#### Examples

```shell
installFlexosPy             # install packages for root
sudof foo installFlexosPy   # install packages for user foo
```

## `installFlexosSh`

Install flexos [basher](https://github.com/basherpm/basher) packages (for specific user).

#### Usage

```shell
installFlexosSh
```

#### Examples

```shell
installFlexosSh             # install packages for root
sudof foo installFlexosSh   # install packages for user foo
```

## `installPy`

Install python environment (for specific user). BUT: Don't call this function directly, use `installPyPkgs()` instead.

#### Usage

```shell
installPy
```

#### Examples

```shell
installPy             # creates /root/.config/pip/pip.conf
sudof foo installPy   # creates /home/foo/.config/pip/pip.conf
```

## `installPyPkgs`

Install python packages (for specific user) of given pip-requirements file.

#### Usage

```shell
installPyPkgs <requirements_file>
```

#### Examples

```shell
installPyPkgs /tmp/root_reqs           # install packages for root
sudof foo installPyPkgs /tmp/foo_reqs  # install packages for user foo
```

## `installSudoUser`

Enable sudo for given user.

#### Usage

```shell
installSudoUser <user> [<sudo_args>]
```

#### Arguments

- sudo_args
    - `sudo` arguments, default are: `ALL=(ALL) NOPASSWD:ALL`

#### Examples

```shell
installSudoUser foo
setUser; installSudoUser ${DECKBUILD_USER}
```

## `installUser`

Create a user (and group).

#### Usage

```shell
installUser user user_id [user_home] [group] [group_id] [user_args] [group_args]
```

#### Arguments

- user
    - User name
- user_id
    - User ID
- user_home
    - Path to user's home directory
- group
    - Group name
- group_id
    - Group ID
- user_args
    - Additional arguments for `useradd` command
- group_args
    - Additional arguments for `groupadd` command

#### Examples

```shell
installUser foo 1001
installUser foo 1001 /home/user/foo
installUser foo 1001 /home/foo bar 2002
installUser foo 1001 /home/foo bar 2002 "-M" "-p myEncrPw"
```

## `is`

Check if values are equal.

#### Usage

```shell
is <value> <value>
```

#### Examples

```shell
is foo foo || ...
if is foo bar; then ...
```

## `isb`

Boolean-check if value is true. Returns `1` (`false`) for `0`, `false` and empty values. Returns `0` (`true`) for other values.

#### Usage

```shell
isb <value>
```

#### Examples

```shell
isb true || ...    # true
isb foo || ...     # true
if isb 1; then ... # true
isb 0 || ...       # false
isb false || ...   # false
isb "" || ...      # false
isb "   " || ...   # false
```

## `isc`

Check if command is runnable (`which <command>`).

#### Usage

```shell
isc <command>
```

#### Examples

```shell
isc ls || ...
if isc ps; then ...
```

## `isd`

Check if file exists and is a directory (`test -d`).

#### Usage

```shell
isd <path>
```

#### Examples

```shell
isd /tmp/foo || ...
if isd /tmp/bar; then ...
```

## `ise`

Check if file exists (`test -e`).

#### Usage

```shell
ise <path>
```

#### Examples

```shell
ise /tmp/foo.txt || ...
if ise /tmp/bar; then ...
```

## `isl`

Check if file exists and is a link (`test -L`).

#### Usage

```shell
isl <path>
```

#### Examples

```shell
isl /tmp/foo.sh || ...
if isl /tmp/bar; then ...
```

## `isn`

Check if value is a number.

#### Usage

```shell
isn <value>
```

#### Examples

```shell
isn 100 || ...
if isn 2; then ...
```

## `isr`

Check if file exists and is readable (`test -r`).

#### Usage

```shell
isr <path>
```

#### Examples

```shell
isr /tmp/foo.txt || ...
if isr /tmp/bar; then ...
```

## `isx`

Check if file exists and is executable (`test -x`).

#### Usage

```shell
isx <path>
```

#### Examples

```shell
isx /tmp/foo.sh || ...
if isx /tmp/bar; then ...
```

## `isz`

Check if value is empty (`test -z`).

#### Usage

```shell
isz <value>
```

#### Examples

```shell
isz "foo" || ...
if isz ""; then ...
```

## `pink`

Print a pink message to stderr.

#### Usage

```shell
pink <message>
```

## `red`

Print a red message to stderr.

#### Usage

```shell
red <message>
```

## `redBold`

Print a bold red message to stderr.

#### Usage

```shell
redBold <message>
```

## `setUser`

Configure user environment: Reads `${DECKBUILD_USER_CFG}` and sets related environment variables (e.g. `${DECKBUILD_USER}` and `${DECKBUILD_USER_ID}`).

#### Usage

```shell
setUser
```

## `stderr`

Print a message to stderr.

#### Usage

```shell
stderr <message> [<format>]
```

#### Arguments

- format
    - Format (passed to `echo`), e.g. `00;34` to print a blue message

#### Examples

```shell
stderr "Hello World"
stderr "Hello World" "00;34"
```

## `sudoc`

Run command as given user.

#### Usage

```shell
sudoc <user> <command>
```

#### Examples

```shell
sudoc foo ls
sudoc foo ls /home/foo
```

## `sudof`

Run shell function as given user.

#### Usage

```shell
sudof <user> <command>
```

#### Examples

```shell
sudof foo myShellFunc
sudof foo myShellFunc arg1 arg2
```

## `upgradeDebPkgs`

Upgrade all debian packages (`apt-get upgrade`).

#### Usage

```shell
upgradeDebPkgs
```

## `warn`

Print a red warning message to stderr.

#### Usage

```shell
warn <message>
```

#### Examples

```shell
warn "Timeout reached"
```

## `white`

Print a white message to stderr.

#### Usage

```shell
white <message>
```

## `yellow`

Print a yellow message to stderr.

#### Usage

```shell
yellow <message>
```
