# Git Tag Version

This is a script to enable simple versioning of git repositories based on tags following the [semantic versioning](http://semver.org/) scheme: **major.minor.patch**, eg. `1.0.21`.

Only the SCMs meta data is used to store the version information. No change is made to the repository contents if the version changes. If you bump the version, your **commit does not change**.
This may or may not be what you are looking for.

Mind: This script may create new versions by adding git tags **but it does not push**! Remember to use ```git push --tags``` to push your locally created tags to your remote repository.

## Use Cases

### New version by continuous integration

1. Change your repository, commit and push.
1. Your CI is triggered due to the push and checks the repository.
1. Your CI tests and checks all pass thus you would like to assign this particular commit a new patch version number.
1. The CI uses tags to assign a new version number without changing the repository - no new commit is generated.

### Manually assigning a new version

1. After weeks of hard work you are done with the basic implementation of your most precious application.
1. To celebrate you want to assign a 1.0.0 version to your latest commit.
1. You simply call the gtv script creating a 'v1.0.0' tag.
1. By pushing to your remote repository your v1.0.0. application is made public.

## Basic Usage

Refer to the online help by calling ```gtv help``` on the command line for a complete list of supported commands.

``` bash
# initialize by creating a 0.0.0 version
gtv init
# show current version, eg. 1.21.3
gtv show
# create a new tag with an increased minor version
gtv new minor
# show current version, eg. 1.22.0
gtv show
# assign an arbitrary but strictly increasing version number
gtv set 1.22.1
# 'show current version' is the default command, eg. 1.22.1
gtv
# create a new tag with an increased major version and message
gtv new major -m "new version description message"
# shows tag v2.0.0 with message "NEW"
git show $(git describe)
# create a new tag with an increased major version, message and suffix
gtv new major --message=ALPHA --suffix=-alpha
# shows tag v3.0.0-alpha with message "ALPHA"
git show $(git describe)
# ERROR!!! Not a strictly increaing number
gtv set 1.0.0
```

## Development

### Build

Since gtv is a plain shell script there is no original *build step*. Except we are including the version number within the released gtv artifact.

Create a gtv release artifact with this neat recursive solution:

```bash
make.sh build $(git-tag-version)
```

### Test

You can execute the tests with [Bash Automated Testing System](https://github.com/sstephenson/bats):

``` bash
make.sh test
```
