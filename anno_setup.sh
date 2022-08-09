#!/usr/bin/env bash


# exit on any error
set -e


script_filename="$0"

docstring='Create an annotation code directory populated with code dependencies and
development environment setup scripts for the Anno annotation of the genome assembly
with the specified (GenBank) assembly accession.

Usage

    $script_filename [-a|--assembly_accession] <assembly accession> [-e|--enscode_directory <ENSCODE directory>] [-d|--directory <annotation code directory>]


Arguments

    -e|--enscode_directory <ENSCODE directory>
        Specify the path of the centralized `ENSCODE` directory. Uses the path in the global `ENSCODE` environment variable by default.
    -d|--directory <annotation code directory>
        Specify the path for the annotation code directory. Defaults to
        `/nfs/production/flicek/ensembl/genebuild/<username>/annotations/<Scientific_name>-<assembly accession>`.'


# print script help if run without arguments
if [[ -z "$1" ]]; then
    echo "$docstring"
    kill -INT $$
fi


# parse script arguments
################################################################################
shortopts="a:e:d:"
longopts="assembly_accession:,,enscode_directory:,directory:"

parsed=$(getopt --options="$shortopts" --longoptions="$longopts" --name "$0" -- "$@") || exit 1
eval set -- "$parsed"

while true; do
    case "$1" in
        (-a|--assembly_accession)
            ASSEMBLY_ACCESSION="$2"
            shift 2
            ;;
        (-e|--enscode_directory)
            enscode_directory="$2"
            shift 2
            ;;
        (-d|--directory)
            ANNOTATION_CODE_DIRECTORY="$2"
            shift 2
            ;;
        (--)
            shift
            break
            ;;
        (*)
            exit 1
            ;;
    esac
done

remaining=("$@")

if [[ -z "$ASSEMBLY_ACCESSION" ]] && [[ -n "$remaining" ]]; then
    ASSEMBLY_ACCESSION="$remaining"
fi
################################################################################


# check the enscode_directory
################################################################################
if [[ -z "$enscode_directory" ]] && [[ -z "$ENSCODE" ]]; then
    echo "Error: no ENSCODE directory path provided and the ENSCODE environment variable is not set"
    echo "$docstring"
    kill -INT $$
fi

if [[ -z "$enscode_directory" ]]; then
    enscode_directory="$ENSCODE"
fi
################################################################################


# get the species scientific name from the assembly registry database
################################################################################
# add MySQL commands directory to PATH
mysql_commands_directory="/hps/software/users/ensembl/ensw/mysql-cmds/ensembl/bin"
PATH="$mysql_commands_directory:$PATH"

# get chain and version from the ASSEMBLY_ACCESSION string
assembly_accession_array=(${ASSEMBLY_ACCESSION//./ })
chain="${assembly_accession_array[0]}"
version="${assembly_accession_array[1]}"

get_scientific_name="
SELECT meta.subspecies_name
FROM assembly
INNER JOIN meta
  ON assembly.assembly_id = meta.assembly_id
WHERE assembly.chain = '$chain'
  AND assembly.version = '$version';"

response="$(gb1 gb_assembly_registry --skip-column-names -e "$get_scientific_name")"
if [[ -z "$response" ]]; then
    echo "Error: assembly accession not in the assembly registry database"
    kill -INT $$
fi

# remove leading and trailing whitespace characters
SCIENTIFIC_NAME="$(echo -e "${response}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
################################################################################


# create the annotation code directory
################################################################################
scientific_name_underscores="${SCIENTIFIC_NAME// /_}"
ANNOTATION_NAME="${scientific_name_underscores}-${ASSEMBLY_ACCESSION}"

annotations_code_root="/nfs/production/flicek/ensembl/genebuild/${USER}/annotations"

if [[ -z "$ANNOTATION_CODE_DIRECTORY" ]]; then
    ANNOTATION_CODE_DIRECTORY="${annotations_code_root}/${ANNOTATION_NAME}"
fi
echo -e "annotation code directory:\n$ANNOTATION_CODE_DIRECTORY"

annotation_enscode_directory="${ANNOTATION_CODE_DIRECTORY}/enscode"

mkdir --parents --verbose "$annotation_enscode_directory"
################################################################################
