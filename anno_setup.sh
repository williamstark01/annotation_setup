#!/usr/bin/env bash


# exit on any error
set -e


script_filename="$0"

docstring='Create an annotation code directory populated with code dependencies and
development environment setup scripts for the Anno annotation of the genome assembly
with the specified (GenBank) assembly accession.

Usage

    $script_filename [-a|--assembly_accession] <assembly accession> [-e|--enscode_directory <ENSCODE directory>] [-c|--code_directory <annotation code directory>]


Arguments

    -e|--enscode_directory <ENSCODE directory>
        Specify the path of the centralized `ENSCODE` directory. Uses the path in the global `ENSCODE` environment variable by default.
    -c|--code_directory <annotation code directory>
        Specify the path for the annotation code directory. Defaults to
        `/nfs/production/flicek/ensembl/genebuild/<username>/annotations/<Scientific_name>-<assembly accession>`.
    -t|--test
        Specify a test annotation, does not update the assembly registry database.'


# print script help if run without arguments
if [[ -z "$1" ]]; then
    echo "$docstring"
    kill -INT $$
fi


# parse script arguments
################################################################################
shortopts="a:e:c:t:"
longopts="assembly_accession:,enscode_directory:,code_directory:,test:"

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
        (-c|--code_directory)
            ANNOTATION_CODE_DIRECTORY="$2"
            shift 2
            ;;
        (-t|--test)
            TEST_RUN="$2"
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


# save the script directory
################################################################################
SCRIPT_DIRECTORY="$(dirname "$(readlink -f "$0")")"
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

echo "$ASSEMBLY_ACCESSION species scientific name: $SCIENTIFIC_NAME"
echo
################################################################################


# create the annotation code directory
################################################################################
scientific_name_underscores="${SCIENTIFIC_NAME// /_}"
ANNOTATION_NAME="${scientific_name_underscores}-${ASSEMBLY_ACCESSION}"

annotations_code_root="/nfs/production/flicek/ensembl/genebuild/${USER}/annotations"

if [[ -z "$ANNOTATION_CODE_DIRECTORY" ]]; then
    ANNOTATION_CODE_DIRECTORY="${annotations_code_root}/${ANNOTATION_NAME}"
fi
echo "annotation code directory:"
echo "$ANNOTATION_CODE_DIRECTORY"
echo

#mkdir --parents --verbose "$ANNOTATION_CODE_DIRECTORY"
mkdir --parents "$ANNOTATION_CODE_DIRECTORY"

annotation_enscode_directory="${ANNOTATION_CODE_DIRECTORY}/enscode"

#mkdir --parents --verbose "$annotation_enscode_directory"
mkdir --parents "$annotation_enscode_directory"
################################################################################


# set up annotation enscode directory
################################################################################
echo "setting up annotation enscode directory"

cd "$enscode_directory"

repository="ensembl-analysis"
cd "$repository"
git fetch origin
git worktree prune
git branch -D "$ANNOTATION_NAME" &>/dev/null || true
git branch "$ANNOTATION_NAME" "origin/experimental/gbiab"
git worktree add "${annotation_enscode_directory}/${repository}" "$ANNOTATION_NAME"
cd "$enscode_directory"

repository="ensembl-genes"
cd "$repository"
git fetch origin
git worktree prune
git branch -D "$ANNOTATION_NAME" &>/dev/null || true
git branch "$ANNOTATION_NAME" "origin/main"
git worktree add "${annotation_enscode_directory}/${repository}" "$ANNOTATION_NAME"
cd "$enscode_directory"

repository="ensembl-anno"
cd "$repository"
git fetch origin
git worktree prune
git branch -D "$ANNOTATION_NAME" &>/dev/null || true
git branch "$ANNOTATION_NAME" "origin/main"
git worktree add "${annotation_enscode_directory}/${repository}" "$ANNOTATION_NAME"
cd "$enscode_directory"

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
    #ln --symbolic --verbose "${enscode_directory}/${repository}" "${annotation_enscode_directory}/${repository}"
    ln --symbolic "${enscode_directory}/${repository}" "${annotation_enscode_directory}/${repository}"
done

echo
################################################################################


# create the annotation log directory
################################################################################
cd "$ANNOTATION_CODE_DIRECTORY"

# create directory for storing the annotation config files
ANNOTATION_LOG_DIRECTORY="${ANNOTATION_CODE_DIRECTORY}/annotation"
#mkdir --verbose "$ANNOTATION_LOG_DIRECTORY"
mkdir "$ANNOTATION_LOG_DIRECTORY"

cd "$ANNOTATION_LOG_DIRECTORY"
###############################################################################


# generate some values, create parent data directories
################################################################################
annotations_data_root="/hps/nobackup/flicek/ensembl/genebuild/${USER}/annotations"

ANNOTATION_DATA_DIRECTORY="${annotations_data_root}/${ANNOTATION_NAME}"

#JOB_QUEUE="production"
JOB_QUEUE="short"

# create parent data directories
#bsub -q $JOB_QUEUE -Is mkdir --parents --verbose "$ANNOTATION_DATA_DIRECTORY"
bsub -q $JOB_QUEUE -Is mkdir --parents "$ANNOTATION_DATA_DIRECTORY"
# add write permission to file group
#bsub -q $JOB_QUEUE -Is chmod --verbose g+w "$ANNOTATION_DATA_DIRECTORY"
bsub -q $JOB_QUEUE -Is chmod g+w "$ANNOTATION_DATA_DIRECTORY"

echo
################################################################################


# copy config files and store in a git repository
################################################################################
# EnsemblAnnoBraker_conf.pm
# file template:
# https://github.com/Ensembl/ensembl-analysis/blob/experimental/gbiab/modules/Bio/EnsEMBL/Analysis/Hive/Config/EnsemblAnnoBraker_conf.pm
pipeline_config_path="${ANNOTATION_LOG_DIRECTORY}/EnsemblAnnoBraker_conf.pm"
pipeline_config_template_path="${annotation_enscode_directory}/ensembl-analysis/modules/Bio/EnsEMBL/Analysis/Hive/Config/EnsemblAnnoBraker_conf.pm"
#cp --preserve --verbose "$pipeline_config_template_path" "$pipeline_config_path"
cp --preserve "$pipeline_config_template_path" "$pipeline_config_path"

# load_environment.sh
load_environment_path="${ANNOTATION_LOG_DIRECTORY}/load_environment.sh"
cp "${SCRIPT_DIRECTORY}/load_environment-template.sh" "$load_environment_path"

git init
git add EnsemblAnnoBraker_conf.pm load_environment.sh
git commit --all --message="import config template files"
echo
################################################################################


# characters to escape in sed substitutions: ^.[]/\$*
# https://unix.stackexchange.com/questions/32907/what-characters-do-i-need-to-escape-when-using-sed-in-a-sh-script/33005#33005
# https://en.wikipedia.org/wiki/Regular_expression#POSIX_basic_and_extended


# update EnsemblAnnoBraker_conf.pm
################################################################################
# "base_output_dir" line 47
sed --in-place -e "s|'base_output_dir'              => '',|'base_output_dir' => '$ANNOTATION_DATA_DIRECTORY',|g" "$pipeline_config_path"

scientific_name_underscores_lower_case="${scientific_name_underscores,,}"
assembly_accession_underscores="${ASSEMBLY_ACCESSION//./_}"
assembly_accession_underscores_lower_case="${assembly_accession_underscores,,}"

# "production_name" line 59
sed --in-place -e "s/'production_name'              => '' || \$self->o('species_name'),/'production_name' => '$scientific_name_underscores_lower_case-$assembly_accession_underscores_lower_case' || \$self->o('species_name'),/g" "$pipeline_config_path"

# "user_r" line 61
sed --in-place -e "s/'user_r'                       => '',/'user_r' => 'ensro',/g" "$pipeline_config_path"

# "user" line 62
sed --in-place -e "s/'user'                         => '',/'user' => 'ensadmin',/g" "$pipeline_config_path"

# "password" line 63
sed --in-place -e "s/'password'                     => '',/'password' => 'ensembl',/g" "$pipeline_config_path"

# "input_ids" line 476
perl -0777 -i -pe "s/-input_ids         => \[\n        #\{'assembly_accession' => 'GCA_910591885.1'\},\n        #\t\{'assembly_accession' => 'GCA_905333015.1'\},\n      \],/-input_ids => \[\{'assembly_accession' => '$ASSEMBLY_ACCESSION'\}\],/igs" "$pipeline_config_path"

# set current_genebuild to 0 to disable updating the assembly registry database,
# currently a noop
if [[ -z "$TEST_RUN" ]]; then
    # "current_genebuild" line 43
    sed --in-place -e "s/'current_genebuild'            => 1,/'current_genebuild' => 0,/g" "$pipeline_config_path"
fi
################################################################################


# update ProcessGCA.pm
# https://github.com/Ensembl/ensembl-analysis/blob/experimental/gbiab/modules/Bio/EnsEMBL/Analysis/Hive/RunnableDB/ProcessGCA.pm
################################################################################
# ensembl-analysis/modules/Bio/EnsEMBL/Analysis/Hive/RunnableDB/ProcessGCA.pm
ProcessGCA_path="${annotation_enscode_directory}/ensembl-analysis/modules/Bio/EnsEMBL/Analysis/Hive/RunnableDB/ProcessGCA.pm"

sed --in-place -e "s/my \$current_genebuild = \$self->param('current_genebuild');/#my \$current_genebuild = \$self->param('current_genebuild');/g" "$ProcessGCA_path"
sed --in-place -e "s/#my \$current_genebuild  = 0;/my \$current_genebuild  = 1;/g" "$ProcessGCA_path"
################################################################################


# update load_environment.sh
################################################################################
sed --in-place -e "s/ASSEMBLY_ACCESSION_value/${ASSEMBLY_ACCESSION}/g" "$load_environment_path"
sed --in-place -e "s/SCIENTIFIC_NAME_value/${SCIENTIFIC_NAME}/g" "$load_environment_path"

sed --in-place -e "s/ANNOTATION_NAME_value/${ANNOTATION_NAME}/g" "$load_environment_path"

sed --in-place -e "s|ANNOTATION_CODE_DIRECTORY_value|${ANNOTATION_CODE_DIRECTORY}|g" "$load_environment_path"
sed --in-place -e "s|ANNOTATION_LOG_DIRECTORY_value|${ANNOTATION_LOG_DIRECTORY}|g" "$load_environment_path"
sed --in-place -e "s|ANNOTATION_DATA_DIRECTORY_value|${ANNOTATION_DATA_DIRECTORY}|g" "$load_environment_path"

sed --in-place -e "s|ENSCODE_value|${annotation_enscode_directory}|g" "$load_environment_path"
################################################################################


# initialize the pipeline
################################################################################
source load_environment.sh

eHive_commands_path="$ANNOTATION_LOG_DIRECTORY/eHive_commands.txt"

init_pipeline.pl EnsemblAnnoBraker_conf.pm --hive_force_init 1 >> "$eHive_commands_path"

ehive_url_line=$(grep "EHIVE_URL" "$eHive_commands_path" | grep "bash")

ehive_url_line_array=(${ehive_url_line//\"/ })
EHIVE_URL="${ehive_url_line_array[2]}"

sed --in-place -e "s|EHIVE_URL_value|${EHIVE_URL}|g" "$load_environment_path"

source load_environment.sh
################################################################################


# generate annotation_log.md
################################################################################
annotation_log_path="${ANNOTATION_LOG_DIRECTORY}/annotation_log.md"

# generate guiHive URL
IFS='/' read -r -a ehive_url_array <<< "$EHIVE_URL"
mysql_url="${ehive_url_array[2]}"
IFS=':' read -r -a mysql_url_array <<< "$mysql_url"
db_username="${mysql_url_array[0]}"
IFS='@' read -r -a host_port_array <<< "${mysql_url_array[1]}"
db_host="${host_port_array[1]}"
db_port="${mysql_url_array[2]}"
db_name="${ehive_url_array[3]}"
guihive_url="http://guihive.ebi.ac.uk:8080/versions/96/?driver=mysql&username=$db_username&host=$db_host&port=$db_port&dbname=$db_name&passwd=xxxxx"

echo "# $ANNOTATION_NAME" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "$SCIENTIFIC_NAME" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "$ASSEMBLY_ACCESSION" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "https://www.ncbi.nlm.nih.gov/assembly/${ASSEMBLY_ACCESSION}/" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "https://www.ncbi.nlm.nih.gov/data-hub/genome/${ASSEMBLY_ACCESSION}/" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "https://en.wikipedia.org/wiki/$scientific_name_underscores" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "## annotation" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "EHIVE_URL" >> "$annotation_log_path"
echo '```' >> "$annotation_log_path"
echo "$EHIVE_URL" >> "$annotation_log_path"
echo '```' >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "guiHive URL" >> "$annotation_log_path"
echo "$guihive_url" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "## $(date '+%Y-%m-%d')" >> "$annotation_log_path"
echo "" >> "$annotation_log_path"
echo "start the pipeline" >> "$annotation_log_path"
echo '```' >> "$annotation_log_path"
echo "beekeeper.pl --url \$EHIVE_URL --loop" >> "$annotation_log_path"
echo '```' >> "$annotation_log_path"
################################################################################


# commit annotation_log.md, eHive_commands.txt and updated config files
################################################################################
git add annotation_log.md eHive_commands.txt
git commit --all --message="add more and update config files"
echo
################################################################################


# create a tmux session for the annotation, start the pipeline
################################################################################
tmux_session_name=(${ANNOTATION_NAME//./_})

# create a detached tmux session
tmux new-session -d -s "$tmux_session_name" -n "pipeline"

# load environment
tmux send-keys -t "${tmux_session_name}:pipeline" "source load_environment.sh" ENTER

# start the pipeline
tmux send-keys -t "${tmux_session_name}:pipeline" "beekeeper.pl --url \$EHIVE_URL --loop" ENTER
################################################################################


# print information for the user
################################################################################
echo
echo "$ANNOTATION_NAME annotation pipeline started"
echo
echo "attach to the annotation tmux session with:"
echo "tmux attach-session -t $tmux_session_name"
echo
echo "view the pipeline in guiHive:"
echo "$guihive_url"
echo
################################################################################
