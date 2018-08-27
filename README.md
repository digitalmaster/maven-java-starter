# Application

## Quality of Life Tools

`Lombok` for easier, less verbose Java data classes

## Testing

Testing is enabled through `JUnit` with `AssertJ` for the assertions library. Unit tests
are enabled by default and integration tests are skipped. There is a profile
called `ci` which runs both and can be enabled by passing the `-P` parameter such as:

```
mvn clean verify -P ci
```

## Logging

Logging is done via `SLF4J` APIs piped to `Logback` as an implementation. For the developer this
means that you should _ONLY_ use the `org.slf4j.` package logging constructs:

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MyClass {

	private static final Logger logger = LoggerFactory.getLogger(MyClass.class);

	//...

}
```

For implementation: a `logback.xml` file in `core/src/main/resources` provides the
appropriate logging behavior. The Logback implementation includes a Daily Rolling
File with file sifting enabled through the value of the `MDC` value. This appender
is also asynchronous for speed purposes.

## Releases

Releases are achieved through the `JGitFlow` plugin using the following steps. Note that
you must be checked in to the `dev` branch and there _must NOT be any uncommitted
changes_ on the branch.

1. Run `mvn jgitflow:release-start`. This will prompt you for the release number for each module. Hit enter to accept the default
2. Once `release-start` completes you should be on a `release-VERSION` branch where `VERSION` is the release version entered
3. Run all tests and perform any functional test validations. If changes are required they can be made on the release branch
if dev has diverged. The results will be merged up to `dev` along with `master`
4. If all looks good, run `mvn jgitflow:release-finish`. This will complete the release and merge changes into local master
5. Create a new tag on the `master` branch with `git tag VERSION`
6. Push all changes up to the remote `dev` and `master` branches. Include the `--tags` flag i.e `git push --tags`
7. Create a release tag in GitHub to point to the Git tag created. The git tag will simply be the `VERSION` entered above

You should now also be able to run `git checkout VERSION` to jump straight to the last commit associated with the given release version

### Hotfixes

Hotfixes are a bit simpler but require much heavier scrutiny since the PRs go straight to master:

1) Create a `hotfix-*` branch where `*` is the name of the feature being fixed
    - 1 feature per hotfix branch for easier tracking
2) Create a PR in Github going to `master`
    - **This means EXTRA scrutiny around testing, style, and pattern enforcement**
3) Once merged, checkout `master` locally
4) Run `git tag X.X.X` where `X.X.X` is the Major.Minor.Patch version
    - If there is no patch version yet for the Major.Minor release version then Patch is 1
    - Otherwise increment the Patch version by 1
    - ex: if previous version `1.2`, tag will be `1.2.1`
    - ex: if previous version `1.2.4`, tag will be `1.2.5`
5) Run `git push --tags`
    - If you see a rejected tag for earlier versions, ignore
    - If you get `[new tag] X.X.X` where `X.X.X` is your new patch version, success
6) In Github, click `Releases`, find the `Major.Minor` release associated to the patch, and click `Edit`
7) Change the associated tag to the newly created tag from above. A green check mark with `Existing Tag` should appear next to/below the input box
8) Click `Update Release`

### Common Errors:

`Error starting release: a release branch [refs/remotes/origin/release-VERSION_HERE] already exists. Finish that first!`

Means that the plugin found a branch prefixed with `release-` in the remote repository. This branch must be deleted before
a release can occur. If the branch is needed to be kept rename it with the `version-VERSION_HERE` naming pattern instead

## Deployment

An `initd.sh` is provided and must be filled in with the desired application and service name which will automatically run the generated artifact
on a Linux machine.

Alternatively - a Dockerfile is provided for Docker-based deployments which builds and packages the final artifact into a clean Alpine image.
This Dockerfile assumes the application can be built with the `mvn package` goal.
