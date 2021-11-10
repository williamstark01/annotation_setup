#!/usr/bin/env bash


# exit on any error
set -e


# settings
ENSEMBL_ANALYSIS_BRANCH="feature/main_alpha"
ENSEMBL_COMPARA_BRANCH="release/98"


script_filename=$0

docstring="Create the ENSCODE Genebuild annotation codebase directory and retrieve
the git repositories used in the annotation pipeline and handover checks.

usage: $script_filename <ENSCODE directory path>"


# print script help if run without arguments
if [[ -z $1 ]]; then
    echo "$docstring"
    kill -INT $$
fi

ENSCODE=$1

# create the ENSCODE directory if it doesn't exist
mkdir --parents --verbose "$ENSCODE"

cd "$ENSCODE"

# check if ENSCODE directory is empty, exit if not empty
if [[ -n "$(ls -A "$ENSCODE")" ]]; then
    echo "Error: $ENSCODE directory not empty, exiting"
    kill -INT $$
fi


# Genebuild repositories
git clone --branch "$ENSEMBL_ANALYSIS_BRANCH" https://github.com/Ensembl/ensembl-analysis.git
git clone https://github.com/Ensembl/ensembl-genes.git

git clone https://github.com/Ensembl/ensembl.git
git clone https://github.com/Ensembl/ensembl-io.git
git clone https://github.com/Ensembl/ensembl-production.git
git clone https://github.com/Ensembl/ensembl-hive.git
git clone --branch "$ENSEMBL_COMPARA_BRANCH" https://github.com/Ensembl/ensembl-compara.git

git clone https://github.com/Ensembl/ensembl-killlist.git
git clone https://github.com/Ensembl/ensembl-taxonomy.git
git clone https://github.com/Ensembl/ensembl-variation.git

# datachecks
git clone https://github.com/Ensembl/ensembl-datacheck.git
git clone https://github.com/Ensembl/ensembl-metadata.git
git clone https://github.com/Ensembl/ensembl-orm.git
