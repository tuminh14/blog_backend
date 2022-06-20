#!/bin/sh

SELF=$(basename -s .sh "$0")
BUILD_IMG_OPT='img'
BUILD_IMG_TAG_OPT='tag'
DEPLOY_CACHE_OPT='deploy-cache'
HELP_OPT='help'
HELP_SHORT_OPT='h'

# How to use this script
usage() {
  usage_="Usage: ${SELF} [ --${BUILD_IMG_OPT} name ] [ --${BUILD_IMG_TAG_OPT} tag ] [ --${DEPLOY_CACHE_OPT} ]"
  description_="Helper script for speed up the building process by using prebuilt docker image"
  parameters_="  -$HELP_SHORT_OPT, --$HELP_OPT|Display help text and exit. No other output is generated"
  parameters_="$parameters_\n  --$BUILD_IMG_OPT|The name of the custom cache image, it will try to pull the image with this name to be use as a base, if not exist it will build a new one"
  parameters_="$parameters_\n  --$BUILD_IMG_TAG_OPT|The tag of the cache image"
  parameters_="$parameters_\n  --$DEPLOY_CACHE_OPT|Deploy the cached image to registry"
  parameters_=$(echo "$parameters_" | column -t -s '|' -c 50)
  printf '%s\n%s\n%s' "$usage_" "$description_" "$parameters_"
  exit 2
}

# Parsing the arguments
parsed_args=$(getopt -a -n ${SELF} --options $HELP_SHORT_OPT --longoptions $HELP_OPT,$BUILD_IMG_OPT:,$BUILD_IMG_TAG_OPT:,$DEPLOY_CACHE_OPT -- "$@")
is_valid_args=$?
if [ "$is_valid_args" != "0" ]; then
  usage
fi

# Override the default arguments
build_img=gradle
build_img_tag=latest
deploy_cache=false
print_help=false
eval set -- "$parsed_args"
while true; do
  case $1 in
    "--$HELP_OPT" | "-$HELP_SHORT_OPT") print_help=true; shift 1;;
    "--$BUILD_IMG_OPT") build_img=$2; shift 2;;
    "--$BUILD_IMG_TAG_OPT") build_img_tag=$2; shift 2;;
    "--$DEPLOY_CACHE_OPT") deploy_cache=true; shift;;
    # -- means the end of the arguments; drop this, and break out of the while loop
    "--") shift; break ;;
    # If invalid options were passed, then getopt should have reported an error,
    # which we checked as VALID_ARGUMENTS when getopt was called...
    "*") echo "Unexpected option: $1 - this should not happen."; usage ;;
  esac
done

if [ $print_help = true ]; then
  usage
fi

# Check if the cached image had already existed on the system or on the registry, if not it will build the cached image
if ! docker image inspect "$build_img":"$build_img_tag" 1>/dev/null 2>/dev/null && ! docker pull "$build_img":"$build_img_tag" 2>/dev/null; then
  echo "Image ${build_img}:${build_img_tag} not existed locally and not found in registry. Start building cached image"
  # Build initial cached image
  docker build \
    --target cache-dependencies \
    --tag "$build_img":"$build_img_tag" \
    --progress=plain \
    .
else
    # Build subsequent cached image
    docker build \
      --target cache-dependencies \
      --tag "$build_img":"$build_img_tag" \
      --build-arg BUILD_IMG="$build_img" \
      --build-arg BUILD_IMG_TAG="$build_img_tag" \
      --progress=plain \
      .
fi

# Deploy the cached image to registry for reuse in subsequent build
if [ $deploy_cache = true ]; then
  echo "Image ${build_img}:${build_img_tag} will start to be deployed to the registry"
  docker push "$build_img":"$build_img_tag"
fi