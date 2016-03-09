Version
=======
This is a script to enable simple versioning of git repositories based on tags with 'semantic versioning' like numbers. Only the SCMs meta data is used to store the version information - no need to change the repository content if the version increases.

Semantic versioning is assumed to be like:
major.minor.patch, eg. 1.0.21. Refer to http://semver.org/ for details.

Use Cases
---------
### New version by continuous integration
1. Change your repository, commit and push.
1. Your CI is triggered based due to the push and checks the repository.
1. Your CI finds your changes exceptionally good and wants assign your particular commit a version number.
1. The CI uses tag to assign a new version number without the need to change the repository again - no new commit is generated.

### Manually assigning a new version
TODO

Basic Usage
-----------

``` bash
# online help
version help
# show the current version number (plain text)
version show
# create a new major version
version new major
# create a new minor version
version new minor
# create a new patch version
version new patch
# assign a specific version number
version set <number>
```

Refer to the online help by calling ```version help``` on the command line for details.
