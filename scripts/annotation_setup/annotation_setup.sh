#!/usr/bin/env bash


# exit on any error
set -e


script_filename="$0"

docstring="Create an annotation code directory populated with code dependencies and
development environment setup scripts for the Genebuild annotation of
the genome assembly with the specified (GenBank) assembly accession.

The annotation code directory path by default has the format:
/hps/nobackup2/production/ensembl/<username>/annotations/<Scientific_name>-<assembly accession>
but can be also specified as an argument.

usage: $script_filename [-a|--assembly_accession] <assembly accession> -s|--server_set <server set> [-e|--enscode_directory <ENSCODE directory>] [-d|--directory <annotation code directory>]"


# print script help if run without arguments
if [[ -z "$1" ]]; then
    echo "$docstring"
    kill -INT $$
fi


# parse script arguments
################################################################################
shortopts="a:s:e:d:"
longopts="assembly_accession:,server_set:,enscode_directory:,directory:"

parsed=$(getopt --options="$shortopts" --longoptions="$longopts" --name "$0" -- "$@") || exit 1
eval set -- "$parsed"

while true; do
    case "$1" in
        (-a|--assembly_accession)
            ASSEMBLY_ACCESSION="$2"
            shift 2
            ;;
        (-s|--server_set)
            SERVER_SET="$2"
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

# choose a server set at random if one hasn't been specified
if [[ -z "$SERVER_SET" ]]; then
    server_sets_array=("set1" "set2")
    SERVER_SET=${server_sets_array[$RANDOM % ${#server_sets_array[@]}]}
fi
################################################################################


# check the enscode_directory
################################################################################
if [[ -z "$enscode_directory" ]] && [[ -z "$ENSCODE" ]]; then
    echo "Error: the global ENSCODE environment variable should be set, or its path provided as an argument"
    echo "$docstring"
    kill -INT $$
fi

if [[ -z "$enscode_directory" ]]; then
    enscode_directory="$ENSCODE"
fi
################################################################################


# retrieve scientific name and clade from the assembly registry database
################################################################################
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

get_clade="
SELECT assembly.clade
FROM assembly
WHERE assembly.chain = '$chain'
  AND assembly.version = '$version';"

response="$(gb1 gb_assembly_registry --skip-column-names -e "$get_clade")"

# remove leading and trailing whitespace characters
CLADE="$(echo -e "${response}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
################################################################################


# create the annotation code directory
################################################################################
scientific_name_underscores="${SCIENTIFIC_NAME// /_}"
ANNOTATION_NAME="${scientific_name_underscores}-${ASSEMBLY_ACCESSION}"

#annotations_code_root="/hps/nobackup2/production/ensembl/${USER}/annotations"
annotations_code_root="/nfs/production/panda/ensembl/${USER}/annotations"

if [[ -z "$ANNOTATION_CODE_DIRECTORY" ]]; then
    ANNOTATION_CODE_DIRECTORY="${annotations_code_root}/${ANNOTATION_NAME}"
fi
echo -e "annotation code directory:\n$ANNOTATION_CODE_DIRECTORY"

annotation_enscode_directory="${ANNOTATION_CODE_DIRECTORY}/enscode"

mkdir --parents --verbose "$annotation_enscode_directory"
################################################################################


# populate the annotation enscode directory
################################################################################
cd "$enscode_directory"

repository="ensembl-analysis"
cd "$repository"
git worktree add "${annotation_enscode_directory}/${repository}" -b "$ANNOTATION_NAME"
cd -

repository="ensembl-genes"
cd "$repository"
git worktree add "${annotation_enscode_directory}/${repository}" -b "$ANNOTATION_NAME"
cd -

repositories=(
    "ensembl"
    "ensembl-io"
    "ensembl-production"
    "ensembl-hive"
    "ensembl-compara"
    "ensembl-killlist"
    "ensembl-taxonomy"
    "ensembl-variation"
    "ensembl-datacheck"
    "ensembl-metadata"
    "ensembl-orm"
)

for repository in "${repositories[@]}"; do
    ln --symbolic --verbose "${enscode_directory}/${repository}" "${annotation_enscode_directory}/${repository}"
done
################################################################################


# clone Genebuild_annotations; create the annotation log directory
################################################################################
cd "$ANNOTATION_CODE_DIRECTORY"

git clone git@github.com:williamstark01/Genebuild_annotations.git
cd Genebuild_annotations

# create directory for keeping the annotation log and config files
ANNOTATION_LOG_DIRECTORY="${ANNOTATION_CODE_DIRECTORY}/Genebuild_annotations/${ANNOTATION_NAME}"
mkdir --verbose "$ANNOTATION_LOG_DIRECTORY"
################################################################################


# generate some values
################################################################################
annotations_data_root="/hps/nobackup2/production/ensembl/genebuild/production"

annotation_data_clade_directory="${annotations_data_root}/${CLADE}"

scientific_name_underscores_lower_case="${scientific_name_underscores,,}"
ANNOTATION_DATA_DIRECTORY="${annotation_data_clade_directory}/${scientific_name_underscores_lower_case}/${ASSEMBLY_ACCESSION}"

if [[ "$CLADE" == "teleostei" ]]; then
    projection_source_database=""
    skip_projection="1"
fi
################################################################################


# generate .envrc
################################################################################
envrc_path="${ANNOTATION_LOG_DIRECTORY}/.envrc"
cp .envrc-template "$envrc_path"

sed --in-place -e "s/ASSEMBLY_ACCESSION_value/${ASSEMBLY_ACCESSION}/g" "$envrc_path"
sed --in-place -e "s/SCIENTIFIC_NAME_value/${SCIENTIFIC_NAME}/g" "$envrc_path"
sed --in-place -e "s/CLADE_value/${CLADE}/g" "$envrc_path"
sed --in-place -e "s/ANNOTATION_NAME_value/${ANNOTATION_NAME}/g" "$envrc_path"

sed --in-place -e "s|ANNOTATION_CODE_DIRECTORY_value|${ANNOTATION_CODE_DIRECTORY}|g" "$envrc_path"
sed --in-place -e "s|ANNOTATION_LOG_DIRECTORY_value|${ANNOTATION_LOG_DIRECTORY}|g" "$envrc_path"
sed --in-place -e "s|ANNOTATION_DATA_DIRECTORY_value|${ANNOTATION_DATA_DIRECTORY}|g" "$envrc_path"

sed --in-place -e "s|ENSCODE_value|${annotation_enscode_directory}|g" "$envrc_path"
sed --in-place -e "s|SERVER_SET_value|${SERVER_SET}|g" "$envrc_path"
################################################################################


# generate pipeline_config.ini
# existing file template:
# https://github.com/Ensembl/ensembl-analysis/blob/dev/hive_master/modules/Bio/EnsEMBL/Analysis/Hive/Config/genome_annotation.ini
################################################################################
pipeline_config_path="${ANNOTATION_LOG_DIRECTORY}/pipeline_config.ini"

echo "assembly_accessions=[${ASSEMBLY_ACCESSION}]" >> "$pipeline_config_path"
echo "output_path=${annotation_data_clade_directory}" >> "$pipeline_config_path"
echo "release_number=${ENSEMBL_RELEASE}" >> "$pipeline_config_path"
if [[ -n "$production_name_modifier" ]]; then
    echo "production_name_modifier=${production_name_modifier}" >> "$pipeline_config_path"
fi
echo "skip_rnaseq=0" >> "$pipeline_config_path"
echo "skip_long_read=0" >> "$pipeline_config_path"
echo "skip_projection=${skip_projection}" >> "$pipeline_config_path"
if [[ -n "$projection_source_database" ]]; then
    echo "projection_source_db_name=${projection_source_database}" >> "$pipeline_config_path"
fi
echo "user_r=ensro" >> "$pipeline_config_path"
echo "user_w=ensadmin" >> "$pipeline_config_path"
echo "password=ensembl" >> "$pipeline_config_path"
echo "server_set=${SERVER_SET}" >> "$pipeline_config_path"
echo "dbowner=${USER}" >> "$pipeline_config_path"
echo "genebuilder_id=${GENEBUILDER_ID}" >> "$pipeline_config_path"
echo "email_address=${USER}@ebi.ac.uk" >> "$pipeline_config_path"
################################################################################


# generate annotation_log.md
################################################################################
annotation_log_path="${ANNOTATION_LOG_DIRECTORY}/annotation_log.md"

echo "# $ANNOTATION_NAME" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "$SCIENTIFIC_NAME" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "$ASSEMBLY_ACCESSION" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "https://www.ncbi.nlm.nih.gov/assembly/$ASSEMBLY_ACCESSION" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "https://en.wikipedia.org/wiki/$scientific_name_underscores" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "## annotation" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "## $(date '+%Y-%m-%d')" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo 'run the pipeline up to analysis 211, "create_rnaseq_for_layer_db"' >> "$annotation_log_path"
echo '```' >> "$annotation_log_path"
echo 'beekeeper.pl -url $EHIVE_URL -loop -analyses_pattern "1..211"' >> "$annotation_log_path"
echo '```' >> "$annotation_log_path"
################################################################################


# initialize the pipeline
################################################################################
cd "$ANNOTATION_LOG_DIRECTORY"

direnv allow

# specify the Python virtual environment to use during annotation
pyenv local genebuild

source .envrc

# set the global Python version to genebuild during initialization
global_python_version=$(pyenv global)
pyenv global genebuild
perl "${ENSCODE}/ensembl-analysis/scripts/genebuild/create_annotation_configs.pl" -config_file pipeline_config.ini
pyenv global "$global_python_version"

pipeline_config_cmds_path="${ANNOTATION_LOG_DIRECTORY}/pipeline_config.ini.cmds"
mv "${annotation_data_clade_directory}/pipeline_config.ini.cmds" "$pipeline_config_cmds_path"
ehive_url_line=$(grep "EHIVE_URL" "$pipeline_config_cmds_path")
ehive_url_line_array=(${ehive_url_line//=/ })
EHIVE_URL="${ehive_url_line_array[2]}"

sed --in-place -e "s|EHIVE_URL_value|${EHIVE_URL}|g" "$envrc_path"

direnv allow
################################################################################


# create a git branch for the annotation
################################################################################
git checkout -b "$ANNOTATION_NAME"

git add annotation_log.md .envrc pipeline_config.ini .python-version pipeline_config.ini.cmds

git commit --all --message="import annotation config files"
################################################################################


# print next steps for the user
################################################################################
echo ""
echo ""
echo ""
echo "go to the annotation log directory:"
echo "cd \"$ANNOTATION_LOG_DIRECTORY\""
echo ""
echo "run to create a tmux session for the annotation:"
echo 'tmux_session_name=(${ANNOTATION_NAME//./_}); tmux new -s "$tmux_session_name"'
echo ""
echo "start the pipeline:"
echo 'beekeeper.pl -url $EHIVE_URL -loop -analyses_pattern "1..211"'
################################################################################
