# Shopify App CLI [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)[![Build Status](https://travis-ci.com/Shopify/shopify-app-cli.svg?token=qtPazgjyosjEEgxgq7VZ&branch=master)](https://travis-ci.com/Shopify/shopify-app-cli)

Shopify App CLI helps you build Shopify apps faster. It automates many common tasks in the development process and lets you add features, such as billing and webhooks.

#### Table of Contents

- [Install](#install)
- [Getting started](#getting-started)
- [Commands](#commands)
- [Contributing to development](#developing-shopify-app-cli)
- [Uninstall](#uninstalling-shopify-app-cli)
- [Changelog](#changelog)

### Requirements

- If you don’t have one, [create a Shopify partner account](https://partners.shopify.com/signup).
- If you don’t have one, [create a development store](https://help.shopify.com/en/partners/dashboard/development-stores#create-a-development-store) where you can install and test your app.

## Download and install

1. Download and install the Shopify App CLI, by running the following command:
    
   ``` $ git clone git@github.com:Shopify/temp-shopify-app-cli.git```

2. Change directories so that you are in `temp-shopify-app-cli` directory.

3. Print the path to this working directory by running the following command:
   
   ```pwd```

   Copy the path that is returned.

4. Open your bash profile by running the following command: `vi ~/.bash_profile`

5. Add the following lines to your bash profile:

     ```export PATH={results_from_running_pwd}/bin/:$PATH```

     ```export SCRIPTS_PLATFORM=1```
     
5. Run the following command: 
    ```shopify load-dev results_from_running_pwd```     

6. Close your terminal and then restart it. 

## Turn on the beta flag for your dev store

You need a store to test your script. This store needs to be a development or test (not a production store) and it needs to have the **scripts_platform** beta flag enabled.

1. From your Shopify internal dashboard, turn on the **scripts_platform** beta flag.


## Getting started

Developers should have some prior knowledge of the Shopify app ecosystem. Currently Shopify App CLI creates apps using either Node or Ruby.



## Commands

### Create a new app project

Run the `create` command to scaffold a new Shopify app in your current directory and generate all the necessary starter files. You can create a Node or Rails app.

Run the following command:

```sh
$ shopify create app APP_NAME
```


### Start a development server

Run the `serve` command to start a local development server as well as a public tunnel to your local development app.

From your app directory, run the following command:
```sh
$ shopify serve
```
Your app is visible to anyone with the ngrok URL.

Your terminal displays the localhost and port where your app is visible. You can now go to your Partner Dashboard and install your app to your development store.


### Preview your app and install it on your development store

Run the `open` command to install your app on a development store.

To install your app on a store:

1. Run the following command from your app directory: `shopify open` The installation URL opens in your web browser.
2. When prompted, choose to install the app on your development store.


### Generate new app features

Run the `generate` command to create the resources for your app.

This command can create the following resources:

- Pages in your app
- App billing models and endpoints
- Webhooks to listen for store events

#### Create a new page

Run the following command from your app directory:

```sh
$ shopify generate page <page_name>
```
A new page is created in the `pages` directory. If your app is a Node app, then you can view this page by appending the page_name to the url.



### Update your CLI software

Use the `update` command to update your production instance of the Shopify App CLI software to the latest version.

Run the following command from your app directory:

```sh
$ shopify update
```


## Developing Shopify App CLI

This is an [open-source](https://github.com/Shopify/shopify-app-cli/blob/master/.github/LICENSE.md) tool and developers are [invited to contribute](https://github.com/Shopify/shopify-app-cli/blob/master/.github/CONTRIBUTING.md) to it. Please check the [code of conduct](https://github.com/Shopify/shopify-app-cli/blob/master/.github/CODE_OF_CONDUCT.md) and the [design guidelines](https://github.com/Shopify/shopify-app-cli/blob/master/.github/DESIGN.md) before you begin.

If you need to run multiple instances of the Shopify App CLI (for example, to test your work). The `load-dev` and `load-system` commands can be used to change between production and development instances of the Shopify App CLI.




## Changelog

**Shopify create command changes**
The subcommand to create a project was renamed from `project` to `app`. February 11, 2020

**Context-sensitive commands**
Context-sensitivity has been added to the commands and help. When you run a command, your directory is used to decide if the command runs. Previously, you could run any command from any directory. Now you need to be in an app directory to run a command that affects an app. To create an app, you need to be in the root directory.

The following commands can be run from the root directory only:

* `create` - create an app project
* `update` - update the Shopify App CLI to the latest version
* `open`   - install your app on a development store
*  the open-source developer commands `load-dev` and `load-system`


The following commands can be run from an app directory:

* `deploy` - deploy your app to a hosting service
* `generate` - generate code for resources in your app.
* `populate` - add example objects to your development store.
*  the convenience commands for debugging: `authenticate`, `connect`, `serve`, and `tunnel`.
* `update` - update the Shopify App CLI to the latest version
*  the open-source developer commands `load-dev` and `load-system`

Also, when you run `shopify help` it returns the commands that apply to the project or directory that you are in. February 11, 2020
