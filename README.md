webpipe source integration for GitHub
================================================================================

This enables you to develop your website in GitHub and have webpipe build and deploy it.


Features
--------------------------------------------------------------------------------

 -  Per-branch deployments for preview & testing


Overview
--------------------------------------------------------------------------------

The integration provides a GitHub webhook that deploys a webpipe pipeline for every new branch. Whenever you push to a branch, the integration triggers the associated pipeline and watches it to notify the result back to GitHub.


Installation
--------------------------------------------------------------------------------

Before you use the integration with any of your GitHub repositories, you must install it to your AWS account. This you must do only once.

To install the integration, you will need:

 -  an AWS account
 -  [GNU make](https://www.gnu.org/software/make/) >= 3.82
 -  [Bundler](https://bundler.io/)

If you meet the above requirements:

 1.  Package the Lambda layers and functions.

 2.  Upload the packages to the webpipe bucket.

 3.  Deploy the CloudFormation stack.

     The S3 URL for the CloudFormation stack template is `https://${webpipe_bucket}.s3.amazonaws.com/v1/sources/github/cfn.yaml`. You need `CAPABILITY_IAM`.
