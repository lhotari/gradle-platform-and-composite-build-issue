# Reproduce Gradle issue with platform / composite build & dependency substitution

This issue has been reported as https://github.com/gradle/gradle/issues/13658.

## The problem

### Background

In this example there are 3 different Gradle projects:

- library-project - multi-project build with library-a and library-b
- platform-project - a Gradle platform with dependency constraints for library-a and library-b
- consumer-project - multi-project build with 2 applications app-a and app-b
  - app-a depends on library-a
  - app-b depends on library-b
  - the settings.gradle includes library-project and contains
    dependency substitution for both library-a and library-b

### To reproduce

Run the `reproduce_issue.sh` script:

```
./reproduce_issue.sh
```
it uses the gradle version available on the PATH

### Expected outcome

When running the Gradle application's plugin's installDist, the app-a should contain library-a's jar
but not contain library-b jar since it doesn't depend on it.
Vice versa, app-b's `build/install/app-b/lib` directory should contain library-b jar, but not
library-a jar

### Actual outcome

Both applications contain both library jars in the install lib directory.
This is not correct since app-a doesn't depend on library-a and app-b doesn't
depend on library-b.

```
consumer-project/app-a/build/install/app-a/lib
├── app-a-1.0.jar
├── checker-qual-2.11.1.jar
├── commons-math3-3.6.1.jar
├── error_prone_annotations-2.3.4.jar
├── failureaccess-1.0.1.jar
├── guava-29.0-jre.jar
├── j2objc-annotations-1.3.jar
├── jsr305-3.0.2.jar
├── library-a-1.0.jar
├── library-b-1.0.jar  <--- THIS shouldn't be here
└── listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar
```

```
consumer-project/app-b/build/install/app-b/lib
├── app-b-1.0.jar
├── checker-qual-2.11.1.jar
├── commons-math3-3.6.1.jar
├── error_prone_annotations-2.3.4.jar
├── failureaccess-1.0.1.jar
├── guava-29.0-jre.jar
├── j2objc-annotations-1.3.jar
├── jsr305-3.0.2.jar
├── library-a-1.0.jar  <--- THIS shouldn't be here
├── library-b-1.0.jar
└── listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar
```

### Analysis from Gradle Build scans

Here's a build scan where the includedBuild is commented out in `consumer-project/settings.gradle`:
https://scans.gradle.com/s/b4jwxcbzixftc . 

![image](https://user-images.githubusercontent.com/66864/86291232-5d9b5a80-bbf7-11ea-83b9-38d5761c9c63.png)

That shows that `library-a` is a constraint of `app-a` and `library-b` is a constraint of `app-b` when the includedBuild is not present. 

With the includedBuild & dependency substitution in `settings.gradle`, the constraint has turned into an ordinary dependency, build scan is https://scans.gradle.com/s/zkdxr6mctbxg6. In addition there is both `library-a` and `library-b` as dependencies of the platform in both `app-a` and `app-b`:

![image](https://user-images.githubusercontent.com/66864/86291313-7efc4680-bbf7-11ea-935a-dbbdba87805c.png)
