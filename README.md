Git Tag Version
===============
This is a script to enable simple versioning of git repositories based on tags with 'semantic versioning' like numbers. Only the SCMs meta data is used to store the version information - no need to change the repository content if the version changes.

Semantic versioning is assumed to be like: major.minor.patch, eg. 1.0.21. Refer to http://semver.org/ for details.

Mind: This script may create new versions by adding git tags **but it does not push**! Remember to use ```git push --tags``` to push your locally created tags to your remote repository. 

Use Cases
---------
### New version by continuous integration
1. Change your repository, commit and push.
1. Your CI is triggered based due to the push and checks the repository.
1. Your CI finds your changes exceptionally good and wants to assign your particular commit a version number.
1. The CI uses tags to assign a new version number without the need to change the repository again - no new commit is generated.

### Manually assigning a new version
1. After weeks of hard work you are done with the basic implementation of your most precious application.
1. To celebrate you want to assign a 1.0.0 version to your latest commit.
1. You simply call the gtv script creating a 'v1.0.0' tag.
1. By pushing to your remote repository your v1.0.0. application is made public.

Basic Usage
-----------
Refer to the online help by calling ```version help``` on the command line for a complete list of supported commands.

``` bash
# show the current version number (plain text)
gtv show
# create a new major, minor or patch version
gtv new <major|minor|patch>
# assign a specific version number
gtv set <number>
```
