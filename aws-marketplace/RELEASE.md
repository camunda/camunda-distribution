# Release Process

Before starting the release process for this repo, be aware of the constraints listed above.

The camunda-platform-helm repo must have already released.

## Mirroring the docker images

The release process is to start with the [Actions tab](https://github.com/camunda/aws-marketplace-dockerfiles/actions) and manually kick off workflows for the new versions for each application. Reference [values-latest.yaml](https://github.com/camunda/camunda-platform-helm/blob/main/charts/camunda-platform/values/values-latest.yaml) for the latest versions of each application.

I would recommend going down the list in values-latest.yaml in order to ensure that no dependencies get left out, which at the time of writing is this order:

1. [Operate]()
2. [Tasklist]()
3. [Zeebe]()
4. [Identity]()
5. [Connectors]()
6. [Keycloak]()
7. [Postgresql]()
8. [Optimize]()
9. [Web Modeler]()
10. [Elasticsearch]()

Next step is to build and push the license manager image:

11. [License Manager]()

And finally, to build and push the camunda helm chart

12. [Helm Chart]()

## AWS Marketplace Management Portal

The following steps require access to the "Camunda - Marketplace" MarketplaceFullAccess AWS SSO identity.

1. Go to [Marketplace Management Portal - Server Products](https://aws.amazon.com/marketplace/management/products/server)
2. Select "Camunda Self-Managed"
3. Click "Request changes" > "Update versions" > "Add new version" and then fill out the required form.

The form requires you to enter the names of each image you uploaded that is associated with this helm chart version.

Example form inputs:

### Version:
Camunda 8.4.1 - Chart 9.1.0

#### Get release notes
Find release notes fetch with following command and manually remove cute emojis
```
gh release view -R camunda/camunda-platform --json body --jq .body
```

### Release notes (do not copy example, use output from command above):
```
# Zeebe
# release/8.3.3
## Bug Fixes
### Gateway
* Unexpected value type in command response ([#5624](https://github.com/camunda/zeebe/issues/5624))
### Misc
* Form events are not replayed ([#15194](https://github.com/camunda/zeebe/issues/15194))
* Scheduled tasks should avoid overloading the streamprocessor ([#13870](https://github.com/camunda/zeebe/issues/13870))
* Feel error are causing bad user experiences ([#8938](https://github.com/camunda/zeebe/issues/8938))
## Maintenance
* Use consistent naming for command processors ([#15077](https://github.com/camunda/zeebe/issues/15077))
## Merged Pull Requests
* Stabilize S3BackupAcceptanceIT#shouldDeleteBackup ([#15210](https://github.com/camunda/zeebe/pull/15210))
* Add log throttling to benchmark apps ([#15165](https://github.com/camunda/zeebe/pull/15165))
* Consistent naming in command processors ([#15078](https://github.com/camunda/zeebe/pull/15078))
* Fix race condition between snapshot listener and updating currentSnapshot by PassiveRole ([#15046](https://github.com/camunda/zeebe/pull/15046))
* fix: Enrich incident messages with evaluation warnings ([#15011](https://github.com/camunda/zeebe/pull/15011))
* Replace incremental requestId in AtomixServerTransport with unique SnowflakeId ([#14857](https://github.com/camunda/zeebe/pull/14857))


# Operate
##  Bugfixes
* **tests**: fix IT tests ([#5922](https://github.com/camunda/operate/issues/5922))
* **security**: upgrade elasticsearch to 7.17.15 ([#5918](https://github.com/camunda/operate/issues/5918))
* modal button positioning when scrollbar is visible ([#5602](https://github.com/camunda/operate/issues/5602))
* **backend**: use listViewStore instead of flowNodeStore ([#5910](https://github.com/camunda/operate/issues/5910))

##  Chore
* Update zeebe and identity to 8.3.3 ([#5913](https://github.com/camunda/operate/issues/5913))

# Tasklist

##  Bugfixes
* extract the var retrieve from the loop ([#3817](https://github.com/camunda/tasklist/issues/3817))

##  Chore
* bump dependencies to 8.3.3 ([#3832](https://github.com/camunda/tasklist/issues/3832))
* update CHANGELOG.md


# Identity
No changes

```

### Container image:
```
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/zeebe:8.3.3
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/operate:8.3.3
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/tasklist:8.3.3
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/connectors-bundle:8.3.1
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/identity:8.3.3
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/keycloak:22.0.5
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/postgresql:15.5.0
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/optimize:8.3.3
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/modeler-restapi:8.3.1
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/modeler-webapp:8.3.1
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/modeler-websockets:8.3.1
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/elasticsearch:8.8.2
709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/licensemanager:0.0.1
```

### Delivery option title:
Camunda Helm Chart

### Delivery option description:
Camunda provides visibility into and control over business processes that span multiple microservices.

### Usage Instructions:
Instructions located here: https://docs.camunda.io/docs/next/self-managed/platform-deployment/helm-kubernetes/guides/aws-marketplace/

### Helm release name:
camunda

### Helm installation namespace:
camunda

### Kubernetes service account name:
camunda

![release-form-1](../blob/main/aws-marketplace/assets/release-form-1.png)
![release-form-2](../blob/main/aws-marketplace/assets/release-form-2.png)

## Viewing the status of the Marketplace Request

https://aws.amazon.com/marketplace/management/requests

![marketplace-status](../blob/main/aws-marketplace/assets/marketplace-status.png)

This page will tell you the status of the request to create a version, and will sometimes provide error messages that says why the version was denied. In my case, it failed once because the container image specified in the "Add a Version" form was not uploaded yet.

![marketplace-issues](../blob/main/aws-marketplace/assets/marketplace-issues.png)

## Testing a version

See [TESTING.md](./aws-marketplace/TESTING.md)

## Updating a versions visibility

On the product page, select "Request changes" > "Update versions" > ...

TODO: Can't find info necessary since all existing Versions are public.

