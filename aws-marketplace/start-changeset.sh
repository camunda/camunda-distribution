#!/bin/bash

CAMUNDA_VERSION=8.5.8
CHART_VERSION=10.4.2

RELEASE_NOTES="$(cat releasenotes)"

helm repo update

#aws sso login

get_chart_images () {
    chart_version="${1}"
    helm template \
        --skip-tests \
        camunda \
        "camunda/camunda-platform" \
        --set webModeler.enabled=true \
        --set webModeler.restapi.mail.fromAddress=fake@fake.com \
        --set console.enabled=true \
        --version "${chart_version}" 2> /dev/null |
    tr -d "\"'" | awk '/image:/{gsub(/^(camunda|bitnami)/, "&", $2); printf "%s\n", $2}' |
    sort | uniq | sed 's/docker\.io\/bitnami\///' | grep -v latest
}

get_chart_images $CHART_VERSION > chart_images


export CONNECTORS_VERSION="$(cat chart_images | grep connectors | sed 's/[^:]*://')"
export IDENTITY_VERSION="$(cat chart_images | grep identity | head -n 1 | sed 's/[^:]*://')"
export OPERATE_VERSION="$(cat chart_images | grep operate | sed 's/[^:]*://')"
export OPTIMIZE_VERSION="$(cat chart_images | grep optimize | sed 's/[^:]*://')"
export TASKLIST_VERSION="$(cat chart_images | grep tasklist | sed 's/[^:]*://')"
export ZEEBE_VERSION="$(cat chart_images | grep zeebe | sed 's/[^:]*://')"
export MODELER_VERSION="$(cat chart_images | grep modeler | tail -n 1 | sed 's/[^:]*://')"
export ELASTICSEARCH_VERSION="$(cat chart_images | grep elasticsearch | sed 's/[^:]*://')"
export POSTGRESQL_VERSION="$(cat chart_images | grep postgresql | sed 's/[^:]*://')"
export KEYCLOAK_VERSION="$(cat chart_images | grep keycloak | sed 's/[^:]*://')"
export CONSOLE_VERSION="$(cat chart_images | grep console | sed 's/[^:]*://')"
LICENSEMANAGER_VERSION=0.0.1


cat > changeset << EOF
[
    {
      "ChangeType": "AddDeliveryOptions",
      "Entity":
      {
        "Identifier": "cc2bd756-6b60-48aa-b312-e97293f0d670",
        "Type": "ContainerProduct@1.0"
      },
      "DetailsDocument":
      {
        "Version":
        {
          "VersionTitle": "Camunda ${CAMUNDA_VERSION} - Chart ${CHART_VERSION}",
          "ReleaseNotes": "${RELEASE_NOTES}"
        },
        "DeliveryOptions":
        [
          {
            "DeliveryOptionTitle": "Camunda Helm Chart",
            "Details":
            {
              "HelmDeliveryOptionDetails":
              {
                "CompatibleServices":
                [
                  "EKS",
                  "EKS-Anywhere"
                ],
                "ContainerImages":
                [
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/zeebe:${ZEEBE_VERSION}",
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/operate:${OPERATE_VERSION}",
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/tasklist:${TASKLIST_VERSION}",
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/connectors-bundle:${CONNECTORS_VERSION}",
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/identity:${IDENTITY_VERSION}",
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/keycloak:${KEYCLOAK_VERSION}",
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/postgresql:${POSTGRESQL_VERSION}",
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/optimize:${OPTIMIZE_VERSION}",
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/modeler-restapi:${MODELER_VERSION}",
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/modeler-webapp:${MODELER_VERSION}",
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/modeler-websockets:${MODELER_VERSION}",
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/elasticsearch:${ELASTICSEARCH_VERSION}",
                  "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/licensemanager:${LICENSEMANAGER_VERSION}"
                ],
                "HelmChartUri": "709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/camunda-platform:${CHART_VERSION}",
                "Description": "Camunda provides visibility into and control over business processes that span multiple microservices.",
                "UsageInstructions": "Instructions located here: https://docs.camunda.io/docs/self-managed/setup/deploy/amazon/aws-marketplace/",
                "QuickLaunchEnabled": false,
                "MarketplaceServiceAccountName": "camunda",
                "ReleaseName": "camunda",
                "Namespace": "camunda",
                "OverrideParameters": [
                  {
                      "Key": "AWSMP.LICENSE.SECRET",
                      "DefaultValue": "\${AWSMP_LICENSE_SECRET}"
                  }
                ]
              }
            }
          }
        ]
      }
    }]
EOF

export CHANGESET="$(cat changeset)"

aws marketplace-catalog start-change-set \
  --catalog "AWSMarketplace" \
  --change-set "$CHANGESET" \

