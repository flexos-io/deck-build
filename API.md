- [`addMetaFile`](#addMetaFile)
- [`addToBashd`](#addToBashd)
- [`aptInstall`](#aptInstall)
- [`black`](#black)
- [`blue`](#blue)
- [`cleanDebPkgs`](#cleanDebPkgs)
- [`cleanTmp`](#cleanTmp)
- [`cyan`](#cyan)
- [`die`](#die)
- [`dload`](#dload)
- [`error`](#error)
- [`getArg`](#getArg)
- [`getGitHubLatest`](#getGitHubLatest)
- [`getUserDp`](#getUserDp)
- [`getUserHome`](#getUserHome)
- [`green`](#green)
- [`hasArg`](#hasArg)
- [`hasBuildArg`](#hasBuildArg)
- [`initDebPkgs`](#initDebPkgs)
- [`initTmp`](#initTmp)
- [`installBashd`](#installBashd)
- [`installSudoUser`](#installSudoUser)
- [`installUser`](#installUser)
- [`is`](#is)
- [`isBuild`](#isBuild)
- [`isDev`](#isDev)
- [`isProd`](#isProd)
- [`isTest`](#isTest)
- [`isTrial`](#isTrial)
- [`isb`](#isb)
- [`isc`](#isc)
- [`isd`](#isd)
- [`ise`](#ise)
- [`isl`](#isl)
- [`isn`](#isn)
- [`isr`](#isr)
- [`isx`](#isx)
- [`isz`](#isz)
- [`lnDir`](#lnDir)
- [`pink`](#pink)
- [`red`](#red)
- [`redBold`](#redBold)
- [`setUser`](#setUser)
- [`sourceBashdFile`](#sourceBashdFile)
- [`sourceBashdFiles`](#sourceBashdFiles)
- [`stderr`](#stderr)
- [`sudoc`](#sudoc)
- [`sudof`](#sudof)
- [`upgradeDebPkgs`](#upgradeDebPkgs)
- [`warn`](#warn)
- [`white`](#white)
- [`yellow`](#yellow)

***

## `addMetaFile`

Create a metafile that contains informations like the OS version"

#### Usage

```shell
addMetaFile <destination_directory> [<data_file>]
```

#### Arguments

- destination_directory
    - Destination directory for metafile
- data_file
    - Append content (`key=value` format) from this file to metafile

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
addToBashd /tmp/bar /etc       # creates /etc/bash.d/bar
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
    - Clear also `/var/lib/apt/lists/*`, default is `true`

#### Examples

```shell
cleanDebPkgs false
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
initTmp; cleanTmp     # create and clean a custom tmp folder
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

Download file (`curl https://...`). Set `${DECKBUILD_CACHE}` to cache (and reuse) downloaded files in given directory.

#### Usage

```shell
dload <url> [<destination_file>]
```

#### Examples

```shell
dload https://example.org /tmp/index.html    # download to file
txt=$(dload https://example.org/foo.txt)     # assign to "txt" variable
export DECKBUILD_CACHE=~/cache; dload https://example.org ./index.html
export DECKBUILD_CACHE=~/cache; dload ...    # cache read-only mode
export DECKBUILD_CACHE=~/cache:ro; dload ... # cache read-only mode
export DECKBUILD_CACHE=~/cache:rw; dload ... # cache read-write mode
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

## `getArg`

Get value of given key-value argument.

#### Usage

```shell
getArg <key-value_argument> [<arguments>]
```

#### Arguments

- arguments
    - All arguments, default is `${MY_ARGS}`

#### Examples

```shell
getArg --foo "-h --foo=bar"              # returns "bar"
getArg --foo "-h --foo=bar1 --foo=bar2"  # returns "bar2"
getArg --foo -h                          # returns ""
```

## `getGitHubLatest`

Get latest software version of a GitHub repository: Returns the version and sets `${DECKBUILD_GITHUB_LATEST}`.

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

Get user's home directory path.

#### Usage

```shell
getUserDp <user>
```

#### Examples

```shell
getUserDp foo
```

## `getUserHome`

Alias for `getUserDp()`.

#### Usage

```shell
getUserHome <user>
```

## `green`

Print a green message to stderr.

#### Usage

```shell
green <message>
```

## `hasArg`

Check if arguments contain the given argument.

#### Usage

```shell
hasArg <argument> [<arguments>]
```

#### Arguments

- arguments
    - All arguments, default is `${MY_ARGS}`

#### Examples

```shell
hasArg -h "-h --foo"
hasArg --foo "-h --foo=bar"
hasArg -A
```

## `hasBuildArg`

Check if `${DECKBUILD_ARGS}` contains the given argument.

#### Usage

```shell
hasBuildArg <argument>
```

#### Examples

```shell
hasBuildArg -e
```

## `initDebPkgs`

Update debian package repository (`apt-get update`).

#### Usage

```shell
initDebPkgs
```

## `initTmp`

Create a temporary directory (`mktemp -d`) and export the path as `${DECKBUILD_TMP}`. BUT: You don't need to run `initTmp()` because a default tmp folder is always available.

#### Usage

```shell
initTmp
```

#### Examples

```shell
touch ${DECKBUILD_TMP}/foo.txt          # use default tmp folder
initTmp; touch ${DECKBUILD_TMP}/foo.txt # create/use a custom tmp folder
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
installBashd /etc       # creates /etc/bash.d
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

## `isBuild`

Check if this is the building stage.

#### Usage

```shell
isBuild
```

#### Examples

```shell
isBuild && echo "Yes: Building stage" || echo "No: Not building stage"
export DECKBUILD_STAGE=build; if isBuild; then ...      # returns true
export DECKBUILD_STAGE=BUILD; if isBuild; then ...      # returns true
export DECKBUILD_STAGE=dev; if isBuild; then ...        # returns false
```

## `isDev`

Check if this is the development stage.

#### Usage

```shell
isDev
```

#### Examples

```shell
isDev && echo "Yes: Development stage" || echo "No: Not development stage"
export DECKBUILD_STAGE=dev; if isDev; then ...          # returns true
export DECKBUILD_STAGE=development; if isDev; then ...  # returns true
export DECKBUILD_STAGE=DEV; if isDev; then ...          # returns true
export DECKBUILD_STAGE=DEVELOPMENT; if isDev; then ...  # returns true
export DECKBUILD_STAGE=prod; if isDev; then ...         # returns false
```

## `isProd`

Check if this is the production stage.

#### Usage

```shell
isProd
```

#### Examples

```shell
isProd && echo "Yes: Production stage" || echo "No: Not production stage"
export DECKBUILD_STAGE=prod; if isProd; then ...        # returns true
export DECKBUILD_STAGE=production; if isProd; then ...  # returns true
export DECKBUILD_STAGE=PROD; if isProd; then ...        # returns true
export DECKBUILD_STAGE=PRODUCTION; if isProd; then ...  # returns true
export DECKBUILD_STAGE=dev; if isProd; then ...         # returns false
```

## `isTest`

Check if this is the test stage.

#### Usage

```shell
isTest
```

#### Examples

```shell
isTest && echo "Yes: test stage" || echo "No: Not test stage"
export DECKBUILD_STAGE=test; if isTest; then ...  # returns true
export DECKBUILD_STAGE=TEST; if isTest; then ...  # returns true
export DECKBUILD_STAGE=prod; if isTest; then ...  # returns false
```

## `isTrial`

Check if this is the trial stage.

#### Usage

```shell
isTrial
```

#### Examples

```shell
isTrial && echo "Yes: trial stage" || echo "No: Not trial stage"
export DECKBUILD_STAGE=trial; if isTrial; then ...  # returns true
export DECKBUILD_STAGE=TRIAL; if isTrial; then ...  # returns true
export DECKBUILD_STAGE=prod; if isTrial; then ...   # returns false
```

## `isb`

Boolean check. Returns `1` (`false`) for `0`, `false` and empty values. Returns `0` (`true`) for other values.

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

## `lnDir`

Move source data to destination folder and replace source directory by link to destination.

#### Usage

```shell
lnDir <source_directory> <destination_directory>
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

## `sourceBashdFile`

Read (source) a `bash.d` profile file (see `installBashd()` for `bash.d` details).

#### Usage

```shell
sourceBashdFile <file_name> [<directory_path>]
```

#### Arguments

- file_name
    - Profile file name
- directory_path
    - `bash.d` parent folder, see `installBashd()` for details

#### Examples

```shell
sourceBashdFile bar            # sources /root/.bash.d/bar
sourceBashdFile bar /etc       # sources /etc/bash.d/bar
sudof foo sourceBashdFile bar  # sources /home/foo/.bash.d/bar
```

## `sourceBashdFiles`

Read (source) all `bash.d` profile files (see `installBashd()` for `bash.d` details).

#### Usage

```shell
sourceBashdFiles [<directory_path>]
```

#### Arguments

- directory_path
    - `bash.d` parent folder, see `installBashd()` for details

#### Examples

```shell
sourceBashdFiles           # sources /root/.bash.d/*
sourceBashdFiles /etc      # sources /etc/bash.d/*
sudof foo sourceBashdFile  # sources /home/foo/.bash.d/*
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

Run command as given user (`sudo ...`).

#### Usage

```shell
sudoc <user> <command> [<command_arguments>]
```

#### Examples

```shell
sudoc foo ls
sudoc foo ls /home/foo
```

## `sudof`

Run shell function as given user (`sudo ...`).

#### Usage

```shell
sudof <user> <function> [<function_arguments>]
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
