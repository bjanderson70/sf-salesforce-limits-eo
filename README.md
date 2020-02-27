# SFDX  Apex Connector + REST API
This code uses a Apex Connector + REST API to extract the Salesforce Limits.
Once the external source is validated and synced add the Permission Set (Salesforce Limit Permission Set) to the appropriate users. In addition, the code supports both Anonymous and Named Credentials. If Anonymous is used, the connector uses the session id of the invoker.

This code is provided without any warranty or support

## Dev, Build and Test
You should be able to push this to any scratch org

## Resources

## Description of Files and Directories
Standard Salesforce DX project structure

## Issues
There is currently an issue with the Report Designer when creating a Report giving an internal error.
This occurs with both Anonymous and Name Credentials

## Deploying to Production

Don’t deploy your code to production directly from Visual Studio Code. The deploy and retrieve commands do not support transactional operations, which means that a deployment can fail in a partial state. Also, the deploy and retrieve commands don’t run the tests needed for production deployments. The push and pull commands are disabled for orgs that don’t have source tracking, including production orgs.

Deploy your changes to production using [packaging](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp.htm) or by [converting your source](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_source.htm#cli_reference_convert) into metadata format and using the [metadata deploy command](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_mdapi.htm#cli_reference_deploy).
