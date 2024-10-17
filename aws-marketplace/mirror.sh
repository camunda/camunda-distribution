#!/bin/bash

export CAMUNDA_VERSION=10.4.2

helm repo update

aws sso login

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

get_chart_images $CAMUNDA_VERSION > chart_images

export CONNECTORS_VERSION="$(cat chart_images | grep connectors | sed 's/[^:]*://')"
export IDENTITY_VERSION="$(cat chart_images | grep identity | sed 's/[^:]*://')"
export OPERATE_VERSION="$(cat chart_images | grep operate | sed 's/[^:]*://')"
export OPTIMIZE_VERSION="$(cat chart_images | grep optimize | sed 's/[^:]*://')"
export TASKLIST_VERSION="$(cat chart_images | grep tasklist | sed 's/[^:]*://')"
export ZEEBE_VERSION="$(cat chart_images | grep zeebe | sed 's/[^:]*://')"
export MODELER_VERSION="$(cat chart_images | grep modeler | tail -n 1 | sed 's/[^:]*://')"
export ELASTICSEARCH_VERSION="$(cat chart_images | grep elasticsearch | sed 's/[^:]*://')"
export POSTGRESQL_VERSION="$(cat chart_images | grep postgresql | sed 's/[^:]*://')"
export KEYCLOAK_VERSION="$(cat chart_images | grep keycloak | sed 's/[^:]*://')"
export CONSOLE_VERSION="$(cat chart_images | grep console | sed 's/[^:]*://')"

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 709825985650.dkr.ecr.us-east-1.amazonaws.com

docker manifest inspect 709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/connectors-bundle:$CONNECTORS_BUNDLE > /dev/null
connectors_image_exists=$?
if [[ "$connectors_image_exists" != "0" ]]; then
    gh workflow run aws-marketplace-connectors.yaml -f imageTag=$CONNECTORS_VERSION
fi

docker manifest inspect 709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/identity:$IDENTITY_VERSION > /dev/null
identity_image_exists=$?
if [[ "$identity_image_exists" != "0" ]]; then
    gh workflow run aws-marketplace-identity.yaml -f imageTag=$IDENTITY_VERSION
fi


docker manifest inspect 709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/operate:$OPERATE_VERSION > /dev/null
operate_image_exists=$?
if [[ "$operate_image_exists" != "0" ]]; then
    gh workflow run aws-marketplace-operate.yaml -f imageTag=$OPERATE_VERSION
fi

docker manifest inspect 709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/optimize:$OPTIMIZE_VERSION > /dev/null
optimize_image_exists=$?
if [[ "$optimize_image_exists" != "0" ]]; then
    gh workflow run aws-marketplace-optimize.yaml -f imageTag=$OPTIMIZE_VERSION
fi

docker manifest inspect 709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/tasklist:$TASKLIST_VERSION > /dev/null
tasklist_image_exists=$?
if [[ "$tasklist_image_exists" != "0" ]]; then
    gh workflow run aws-marketplace-tasklist.yaml -f imageTag=$TASKLIST_VERSION
fi

docker manifest inspect 709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/zeebe:$ZEEBE_VERSION > /dev/null
zeebe_image_exists=$?
if [[ "$zeebe_image_exists" != "0" ]]; then
    gh workflow run aws-marketplace-zeebe.yaml -f imageTag=$ZEEBE_VERSION
fi

docker manifest inspect 709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/modeler-restapi:$MODELER_VERSION > /dev/null
modeler_image_exists=$?
if [[ "$modeler_image_exists" != "0" ]]; then
    gh workflow run aws-marketplace-modeler.yaml -f imageTag=$MODELER_VERSION
fi

docker manifest inspect 709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/elasticsearch:$ELASTICSEARCH_VERSION > /dev/null
elasticsearch_image_exists=$?
if [[ "$elasticsearch_image_exists" != "0" ]]; then
    gh workflow run aws-marketplace-elasticsearch.yaml -f imageTag=$ELASTICSEARCH_VERSION
fi

docker manifest inspect 709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/postgresql:$POSTGRESQL_VERSION > /dev/null
postgresql_image_exists=$?
if [[ "$postgresql_image_exists" != "0" ]]; then
    gh workflow run aws-marketplace-postgresql.yaml -f imageTag=$POSTGRESQL_VERSION
fi


docker manifest inspect 709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/keycloak:$KEYCLOAK_VERSION > /dev/null
keycloak_image_exists=$?
if [[ "$keycloak_image_exists" != "0" ]]; then
    gh workflow run aws-marketplace-keycloak.yaml -f imageTag=$KEYCLOAK_VERSION
fi

docker manifest inspect 709825985650.dkr.ecr.us-east-1.amazonaws.com/camunda/camunda8/camunda-platform:$CAMUNDA_VERSION > /dev/null
helm_image_exists=$?
if [[ "$helm_image_exists" != "0" ]]; then
    gh workflow run aws-marketplace-camunda-helm-chart.yaml -f imageTag=$CAMUNDA_VERSION -f awsImageTag=$CAMUNDA_VERSION
fi
