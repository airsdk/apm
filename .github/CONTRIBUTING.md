# Contributing

Thank you for taking the time to contribute!

These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

**When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.** We have already laid out a plan of development and future goals for the tool, so it is important any development you may wish to do aligns with this direction.

Please note we have a code of conduct, please follow it in all your interactions with the project.

## How Can I Contribute?

There are many ways to contribute and not all of them involve coding.

- [Reporting bugs](#reporting-bugs)
- [Suggesting features](#suggesting-features)
- [Contributing code](#contributing-code)

## Reporting bugs

### Before submitting a bug

- Ensure the bug was not already reported by searching on GitHub under [issues](https://github.com/airsdk/apm/issues). If it has and the issue is still open, add a comment to the existing issue instead of opening a new one;
- Check the [discussions](https://github.com/airsdk/apm/discussions) for a list of common questions and problems;

### How to submit a bug

Bugs are tracked as [issues](https://github.com/airsdk/apm/issues/new) in GitHub. Explain the problem and include as much detail as possible to help maintainers reproduce the problem:

- Use a clear and descriptive title for the issue to identify the problem;
- Describe the exact steps which reproduce the problem in as many details as possible. For example, start by listing the command used and any output to the terminal.;
- Enable debugging outputs using the `-l` flag: `apm -l debug ...` , include the output while running this version of the command;
- Describe the behavior you observed after following the steps and point out what exactly is the problem with that behavior;
- Explain which behavior you expected to see instead and why;
- Include details about your configuration and environment, including air sdk version, java version, the OS and version you are using;

## Suggesting features

A feature can be anything, from a minor change to an existing feature or a completely new command.

### Before submitting a feature

Before submitting a feature check the [issues](https://github.com/airsdk/apm/issues) and [discussions](https://github.com/airsdk/apm/discussions) for a similar feature discussion. If one exists add your thoughts to the existing discussion.

### How to submit a feature request

If you see a feature that is missing or you would like to see in the tool, please start a [discussion](https://github.com/airsdk/apm/discussions/new) on the topic. In your discussion outline the usage of the feature in as much detail as possible and how you see this benefiting the tool.

Do not open an issue on GitHub until you have collected positive feedback about the change. Once discussed and we all believe it is a good feature to add you can create an [issue](https://github.com/airsdk/apm/issues/new) (labelled as an enhancement):

- Use a clear and descriptive title for the issue to identify the suggestion;
- Provide a step-by-step description of the suggested enhancement in as many details as possible;
- Provide specific examples to demonstrate the steps;
- Explain why this enhancement would be useful to most users;

## Contributing code

Before contributing code it's important that you have discussed the feature or are addressing an issue outstanding in the issues list.

If you don't know where to start have a look at the issues labelled [good first issue](https://github.com/airsdk/apm/labels/good%20first%20issue) or [help wanted](https://github.com/airsdk/apm/labels/help%20wanted). These should be the simpler issues or ones that we are asking for general feedback with.

### Fork the repository

Create a fork of the repository, and create a branch from the `develop` branch. The develop branch contains the current development state of apm. It should contain the most up-to-date code base.

### Local development

The apm tool can be developed locally. You can even run a [local apm repository](https://github.com/airsdk/apm-repository/) if you wish. To setup your development environment see the guide on [building](https://github.com/airsdk/apm/blob/master/BUILDING.md).

### Pull Requests

Once you have completed coding in your branch, create a PR from your fork to the `develop` branch in the apm repository. Never PR to the `main` branch, always to `develop`

Add a detailed description to the PR describing the changes you have made. It is important that you reference the github issue that this relates to.

The PR will then be reviewed and the reviewer(s) may ask you to complete additional work, tests, or other changes before your pull request can be ultimately accepted. If you have not followed the guidelines in this document your PR may be closed and not merged into the repository.

### Coding conventions

We follow the standard AS3 coding conventions and best practices as outlined [here](https://airsdk.dev/docs/development/coding-conventions).

Please ensure you follow these conventions in any code submissions and the following notes:

- Use tab indentation;
- Use [Allman style](https://en.wikipedia.org/wiki/Indentation_style#Allman_style) braces;

## Acknowledgements

Parts of this contributing guide were adapted from the [Contributing to Atom](https://github.com/atom/atom/blob/master/CONTRIBUTING.md) documentation.
