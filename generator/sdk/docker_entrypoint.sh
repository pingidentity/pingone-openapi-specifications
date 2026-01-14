#!/usr/bin/env bash

set -eo pipefail

echo "\$ $0" "$*"

script_name=$0
script_dir=$(dirname "$script_name")

if [[ -z $1 ]]; then
  echo "Source OAS file should be specified as the first argument"
  exit 1
fi

if [[ ! -f $1 ]]; then
  echo "Source OAS file $1 does not exist"
  exit 1
fi

if [[ -z $2 ]]; then
  echo "Language argument should be set as the second argument"
  exit 1
fi

if [[ -z $3 ]]; then
  echo "Product name argument, which determines the project name, should be set as the third argument"
  exit 1
fi

sdkVersion="dev"
if [[ -z $4 ]]; then
  echo "WARNING: SDK version argument missing, defaulting to $sdkVersion"
else
  sdkVersion=$4
fi

SOURCEFILE=$1
LANGUAGE=$2
PRODUCT=$3

# Check if language templates exist
LANGUAGE_DIR="$GENERATOR_DIR/languages/$LANGUAGE"
USE_CUSTOM_LANGUAGE=true
if [[ ! -d $LANGUAGE_DIR ]]; then
  echo "WARNING: Ping configuration for language $LANGUAGE not found. Skipping."
  USE_CUSTOM_LANGUAGE=false
fi
TEMPLATES_DIR="$LANGUAGE_DIR/templates"
USE_TEMPLATES=$USE_CUSTOM_LANGUAGE
if [[ ! -d $TEMPLATES_DIR ]]; then
  echo "WARNING: Ping templates for language $LANGUAGE not found. Using default templates instead."
  USE_TEMPLATES=false
fi

clientName=$(printf "$CLIENT_NAME_FORMAT_MASK" "$PRODUCT" "$LANGUAGE")

echo "Building $PRODUCT $LANGUAGE sdk. ($clientName)"
mkdir -p $GENERATOR_OUTPUT_DIR

httpUserAgentFormat="$GENERATOR_SDK_USER_AGENT_PREFIX%s/%s"
httpUserAgent=$(printf "$httpUserAgentFormat" "$clientName" "$sdkVersion")

additionalGeneratorArgs=""
# Add additional parameters based on conditions
if [[ "$DEBUG" == "true" ]]; then
  additionalGeneratorArgs+=" --global-property debugSupportingFiles=true \
    --global-property debugModels=true \
    --global-property debugOpenAPI=true"
fi
if [[ "$LANGUAGE" == "go" ]]; then
  additionalGeneratorArgs+=" --enable-post-process-file \
    --type-mappings=\"integer=int32,number=float32,string+byte=[]byte,string+UUID=uuid.UUID,string+uuid=uuid.UUID,integer+bigInt=big.Int,number+bigFloat=big.Float,number+bigFloatUnquoted=types.BigFloatUnquoted,integer+unix-date-time=types.UnixTime\" \
    --import-mappings=\"uuid.UUID=github.com/google/uuid,integer+bigInt=math/big,number+bigFloat=math/big,types.BigFloatUnquoted=$GENERATOR_GIT_HOST/$GENERATOR_GIT_USER_ID/$clientName/types,types.UnixTime=$GENERATOR_GIT_HOST/$GENERATOR_GIT_USER_ID/$clientName/types\" \
    --additional-properties=apiNameSuffix=Api,enumClassPrefix=true,packageName=$PRODUCT,packageVersion=$sdkVersion,isGoSubmodule=true,useOneOfDiscriminatorLookup=true,withGoMod=false,disallowAdditionalPropertiesIfNotPresent=false \
    --inline-schema-options RESOLVE_INLINE_ENUMS=true,ARRAY_ITEM_SUFFIX=,MAP_ITEM_SUFFIX="

  # If $GENERATOR_DIR/languages/$LANGUAGE/model-name-mappings.txt exists, read it, take each line and add it to the generator command with the `--model-name-mappings` parameter, comma separated
  if [[ -f "$GENERATOR_DIR/languages/$LANGUAGE/model-name-mappings.txt" ]]; then
    modelNameMappings=$(cat "$GENERATOR_DIR/languages/$LANGUAGE/model-name-mappings.txt" | tr '\n' ',')
    additionalGeneratorArgs+=" --model-name-mappings=$modelNameMappings"
  fi

  export GO_POST_PROCESS_FILE="$GENERATOR_DIR/languages/go/postprocessing/file-postprocessing.sh"
fi
if [[ "$LANGUAGE" == "python" ]]; then
  additionalGeneratorArgs+=" --additional-properties=packageName=$PRODUCT,packageVersion=$sdkVersion,projectName=$PRODUCT"

  # If $GENERATOR_DIR/languages/$LANGUAGE/model-name-mappings.txt exists, read it, take each line and add it to the generator command with the --model-name-mappings parameter, comma separated
  if [[ -f "$GENERATOR_DIR/languages/$LANGUAGE/model-name-mappings.txt" ]]; then
    modelNameMappings=$(cat "$GENERATOR_DIR/languages/$LANGUAGE/model-name-mappings.txt" | tr '\n' ',')
    additionalGeneratorArgs+=" --model-name-mappings=$modelNameMappings"
  fi
fi

generatorCmd="/usr/local/bin/docker-entrypoint.sh generate \
    -i $SOURCEFILE \
    -g $LANGUAGE \
    -o $GENERATOR_OUTPUT_DIR \
    $([ "$USE_TEMPLATES" = true ] && echo "-t $TEMPLATES_DIR") \
    --git-host $GENERATOR_GIT_HOST \
    --git-user-id $GENERATOR_GIT_USER_ID \
    --git-repo-id \"$clientName\" \
    $([ "$USE_CUSTOM_LANGUAGE" = true ] && echo "--ignore-file-override=$LANGUAGE_DIR/.openapi-generator-ignore") \
    --http-user-agent \"$httpUserAgent\" \
    %s"

generatorCmd=$(printf "$generatorCmd" "$additionalGeneratorArgs")

# Execute the docker command
echo "Command Used: $generatorCmd"
eval $generatorCmd
