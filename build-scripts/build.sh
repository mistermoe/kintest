#! /bin/bash

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function contains() {
    local selection="$1"
    shift
    local arr=("$@")

    for i in "${arr[@]}"
    do
        if [ "$i" == "$selection" ] ; then
            echo "found"
        fi
    done
}

function prompt_for_selection() {
    local prompt="$1"
    shift
    
    local choices=("$@")
    
    local selection
    local valid_selection

    until [ "$valid_selection" == "found" ]; do
        read -p "$prompt " selection
        valid_selection=$(contains "$selection" "${choices[@]}")
    done

    echo $selection
}

function prompt_directory_name() {
    read -p "Which lambda would you like to build an image for? " LAMBDA_NAME

    echo $LAMBDA_NAME
}

function prompt_push_img() {
    read -p "Would you like to push the image? y/n: " PUSH_IMG

    until [ $PUSH_IMG == "y" ] || [ $PUSH_IMG == "n" ]; do
        read -p "Please provide either y or n: " PUSH_IMG
    done

    echo $PUSH_IMG
}

lambda_dirs=$(ls ./lambdas)
lambdas=($lambda_dirs)
lambda_prompt="Which lambda do you want to build an image for (${lambdas[@]})?"
lambda=$(prompt_for_selection "$lambda_prompt" "${lambdas[@]}")

IMG_TAG=$(date +"%Y.%m.%d.%s")

docker build --no-cache \
    -f ${CWD}/../dockerfiles/python.Dockerfile \
    -t ${ECR_REGISTRY}/kinesis-analytics-lambdas/${lambda}:$IMG_TAG \
    --build-arg lambda=$lambda \
    ${CWD}/../

PUSH_IMG=$(prompt_push_img)

if [ $PUSH_IMG == "y" ]; then
    docker push ${ECR_REGISTRY}/kinesis-analytics-lambdas/${lambda}:$IMG_TAG
fi
