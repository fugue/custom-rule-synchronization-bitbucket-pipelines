# Automating Custom Rule Synchronization Using Bitbucket

## Prerequisites
- Enable pipelines in repository settings:   
   - From within your Bitbucket repository, click “Repository Settings” along the left side of the page   
   - Scroll down to the bottom of the menu that appears on the left side of the page to the “Pipelines” section   
   - Click “Settings”   
   - Click the slider next to “Enable Pipelines” so that it appears green with a white checkmark   
- Add `FUGUE_API_ID` and `FUGUE_API_SECRET` as [repository variables](https://docs.fugue.co/api.html#getting-started-create-client-id-and-secret)
- Create a git repository in Bitbucket, clone it locally, and ensure it contains the following:
    - A `rules/` directory, which will hold your custom rules defined in `.rego` files
    - Any custom rules that you want to be automatically synchronized with the Fugue SaaS platform
    - An empty `bitbucket-pipelines.yml` file, which will tell Bitbucket Pipelines what to do when a build is triggered

## Workflow Overview
![workflow](/img/workflow.jpg "workflow overview")

Once configured and engaged according to the instructions below, the workflow depicted above will automatically synchronize custom rules (defined locally in `.rego` files and pushed to Bitbucket) with the Fugue SaaS platform and (optionally) be added to a specific custom family.

## Workflow
### Set up your `bitbucket-pipelines.yml` file
Copy and paste the following into your empty `bitbucket-pipelines.yml` file, then save it:

```yaml
pipelines:
  default:
    - step:
        name: 1 - Sync Rules
        script:
          - sudo wget https://github.com/$(wget https://github.com/fugue/fugue-client/releases/latest -O - | egrep '/.*/.*/.*fugue-linux-amd64' -o) -P /usr/local/bin/
          - mv /usr/local/bin/fugue-linux-amd64 /usr/local/bin/fugue
          - chmod 755 /usr/local/bin/fugue
          - fugue --version
          - fugue sync rules rules/
```

This is a single step, default pipeline that retrieves the latest release of the Fugue CLI client from the GitHub [releases page](https://github.com/fugue/fugue-client/releases), stores it locally, and synchronizes your custom rules repository with your Fugue UI.

*Note: `fugue sync rules` is a single-direction command: when executed, it will add any unique rules from the specified local directory to the Fugue UI, but will pull any rule updates from the Fugue UI to update your local rules repository. To delete custom rules from the Fugue UI, run `fugue delete rules -h` in your terminal and follow the instructions that are provided.*

If you would like to add these custom rules to a custom family, switch out the last line in the `bitbucket-pipelines.yml` file with the following line, replacing the `[family_id]` with the intended custom family UUID:

`fugue sync rules rules/ --target-rule-family [family_id]`

To find out the UUID of your custom family, execute the following line in your terminal and copy the intended custom family UUID from the far left column:

`fugue list families --source CUSTOM`

### Commit and push rules to Bitbucket repository

After saving changes to your rules in the `rules/` directory of your local git repository, execute the following lines of code in your terminal:

```
git add bitbucket-pipelines.yml rules/*
git commit -m "sync custom rules"
git push
```
*Note: you only need to add `bitbucket-pipelines.yml` the first time you commit it to your repository and any time you make changes to the pipeline file thereafter.*

### Trigger Bitbucket Pipelines

This step is automatically triggered when you push to your Bitbucket repository, and therefore does not require any action on your part.

Bitbucket Pipelines will detect that a new commit has been pushed to the repository, then it will execute a build based on the latest version of the `bitbucket-pipelines.yml` file in the repository.

If the build fails, this is likely due to improperly defined rules. Inspect the error message that populates at the end of the build (under the `Build Teardown` step) and make any necessary changes to your rules, referring to the [Fugue rules documentation](https://docs.fugue.co/rules-landing.html#rules) for help.

### Rules are synchronized in Fugue SaaS platform

This step is automatically triggered when your Bitbucket Pipelines build is complete, and therefore does not require any action on your part.

Upon successful completion of the Bitbucket Pipelines build, your custom rules will be available in the Fugue SaaS platform.
