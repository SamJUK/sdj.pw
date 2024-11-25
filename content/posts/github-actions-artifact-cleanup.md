---
title: "Cleaning Up Github Actions Artifacts via cli"
description: "How to clean-up Github action artifacts via the github cli, helping reduce github storage usage and billing."
date: 2024-08-05T05:00:00+00:00
tags: ["github", "devops"]
documentation: https://docs.sdj.pw/general/github/cleanup-artifacts.html
---
There are a handful of guides on how to clean-up old Github Action Artifacts. The issue I have with the ones I've seen, is they are really convoluted solutions for such a simple task.

I am making an assumption here that you are using the [Github CLI tool](https://cli.github.com/). If you are not, then your missing out, go give it a go (even just for this task). You can even use the [CLI directly within your workflows](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/using-github-cli-in-workflows) if you can to run the clean-up as a nightly task etc. 

### Delete All Artifacts In a Single Command
> ℹ️ Note: You do not need to replace the values in brackets like `{owner}`. Github CLI infers this based on your configured Git remotes for the current Git context.

🚨 One liner that will remove **ALL** the existing artifacts in a repository. I like to declare this is a shell alias `gh-purge-artifacts`. Although it a shell script, Makefile could also work well.
```sh
export GH_PAGER=cat
gh api repos/{owner}/{repo}/actions/artifacts --jq '.artifacts[] | .id' \
| xargs -I "<>" gh api -X DELETE "repos/{owner}/{repo}/actions/artifacts/<>"
```

### Useful Commands

#### Listing Artifacts
We can list out artifacts with the following command, then we can filter artifacts down based on workflow, size, age. And even shake the object down before passing it onto other processes.
```sh
# List out current Artifacts
gh api repos/{owner}/{repo}/actions/artifacts

# List out current Artifacts with a subset of data for piping into other processes
GH_PAGER=cat gh api repos/{owner}/{repo}/actions/artifacts \
  --jq '.artifacts[] | { id: .id, name: .name, size: .size_in_bytes, expires: .expires_at, run_id: .workflow_run.id}'
```

#### Deleting Artifacts
```sh
gh api -X DELETE repos/{owner}/{repo}/actions/artifacts/1234567
```
