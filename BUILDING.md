# Building APM

Before attempting to modify the code, have a look at the [contributing guidelines](https://github.com/airsdk/apm/blob/efb0b6ab357448dcf3e6cb27b684be6e1ac6dac7/.github/CONTRIBUTING.md).

APM is built using the AIR SDK. See the documentation at [airsdk.dev](https://airsdk.dev) to setup the AIR SDK on your machine.

The command line utility output used by `apm` was only introduced recently in AIR so you need to ensure you have at least version 33.1.1.554 of the AIR SDK installed.

## AIR IDE

You can use any AIR IDE to develop this project. The `client` directory is the root of the application source tree. It contains the following key directories:

- `src`: All actionscript source code for `apm`;
- `libs`: SWC's used by `apm`;

You should add the src directory as a source code directory and the libs directory as a swc directory to whatever IDE you are using. Set the output to an `out` directory underneath `client` to keep your build inline with the ant script.

## Ant

We have provided an ant build script `build.xml` that can be used to build the project.

Make a copy of the `build.config.example` file as `build.config` in your checkout. Edit the file and point the `air.sdk` property to the location of the AIR SDK on your machine. eg

```
air.sdk = /Users/marchbold/sdks/air/AIR_33.1.1.554
```

Run the bootstrap command to download the ant contrib utilities used by the build script:

```
ant bootstrap
```

Then you should be able to run ant to build `apm`:

```
❯ ant
Buildfile: /Users/marchbold/work/distriqt/airsdk/apm/source/build.xml

version_write:
     [copy] Copying 1 file to /Users/marchbold/work/distriqt/airsdk/apm/source/client/src/com/apm/client

build:
     [echo] Building apm...
    [mxmlc] Loading configuration: /Users/marchbold/work/sdks/air/current/frameworks/air-config.xml
    [mxmlc]
    [mxmlc]
    [mxmlc] 63502 bytes written to /Users/marchbold/work/distriqt/airsdk/apm/source/client/out/apm.swf in 1.604 seconds
    [mxmlc]
     [echo] Copying apm scripts...
     [copy] Copying 3 files to /Users/marchbold/work/distriqt/airsdk/apm/source/client/out
     [echo] done

BUILD SUCCESSFUL
Total time: 2 seconds
```

The output of this is the `client/out` directory. It should contain 4 files:

```
- apm
- apm.bat
- apm.swf
- apm.xml
```

The first two files are the launch scripts for macOS and Windows respectively. `apm.xml` is the application descriptor for the `apm` utility.

## Testing

In order to test your local build, set the `AIR_TOOLS` environment variable that you would have set during installation of `apm` to point to the `client/out` directory. Or you can just run apm from the `client/out` directory directly.

Once you set this you should be able to run `apm` in your terminal and reference your locally built version.
