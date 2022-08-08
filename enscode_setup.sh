#!/usr/bin/env bash


# exit on any error
set -e


# settings
ENSEMBL_ANALYSIS_BRANCH="main"
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

ENSCODE=$(realpath $1)

# create the ENSCODE directory if it doesn't exist
mkdir --parents --verbose "$ENSCODE"

cd "$ENSCODE"

# check if ENSCODE directory is empty, exit if not empty
if [[ -n "$(ls -A "$ENSCODE")" ]]; then
    echo "Error: $ENSCODE directory not empty, exiting"
    kill -INT $$
fi


# Genebuild repositories
# https://github.com/Ensembl/ensembl-analysis
git clone --branch "$ENSEMBL_ANALYSIS_BRANCH" git@github.com:Ensembl/ensembl-analysis.git
# https://github.com/Ensembl/ensembl-genes
git clone git@github.com:Ensembl/ensembl-genes.git

# https://github.com/Ensembl/ensembl
git clone https://github.com/Ensembl/ensembl.git
# https://github.com/Ensembl/ensembl-io
git clone https://github.com/Ensembl/ensembl-io.git
# https://github.com/Ensembl/ensembl-production
git clone https://github.com/Ensembl/ensembl-production.git
# https://github.com/Ensembl/ensembl-hive
git clone https://github.com/Ensembl/ensembl-hive.git
# https://github.com/Ensembl/ensembl-compara
git clone --branch "$ENSEMBL_COMPARA_BRANCH" https://github.com/Ensembl/ensembl-compara.git

# https://github.com/Ensembl/ensembl-killlist
git clone https://github.com/Ensembl/ensembl-killlist.git
# https://github.com/Ensembl/ensembl-taxonomy
git clone https://github.com/Ensembl/ensembl-taxonomy.git
# https://github.com/Ensembl/ensembl-variation
git clone https://github.com/Ensembl/ensembl-variation.git

# datachecks
# https://github.com/Ensembl/ensembl-datacheck
git clone https://github.com/Ensembl/ensembl-datacheck.git
# https://github.com/Ensembl/ensembl-metadata
git clone https://github.com/Ensembl/ensembl-metadata.git
# https://github.com/Ensembl/ensembl-orm
git clone https://github.com/Ensembl/ensembl-orm.git
