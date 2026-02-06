ARG TERRAFORM_VERSION=1.7.4
FROM 710267309417.dkr.ecr.us-east-1.amazonaws.com/builder/terraform:latest

WORKDIR /workspace

COPY . .

ARG TERRAFORM_VERSION

ARG IS_DEVELOPMENT_ENV
ARG VERSION
ARG BUILD_NUM
ARG GIT_COMMIT_SHA

ENV VERSION=$VERSION \
    BUILD_NUM=$BUILD_NUM \
    GIT_COMMIT_SHA=$GIT_COMMIT_SHA \
    IS_DEVELOPMENT_ENV=$IS_DEVELOPMENT_ENV \
    TFENV_TERRAFORM_VERSION=$TERRAFORM_VERSION

RUN tfenv use $TERRAFORM_VERSION

# Create directories with proper permissions for non-root user
RUN mkdir -p /workspace/.terraform /workspace/.terraform.d /var/tfenv && \
    chown -R nobody:nobody /workspace /var/tfenv

USER nobody
