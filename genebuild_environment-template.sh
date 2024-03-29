# Genebuild annotation pipeline execution environment


# annotation details and directory paths
################################################################################
export ASSEMBLY_ACCESSION="ASSEMBLY_ACCESSION_value"
export SCIENTIFIC_NAME="SCIENTIFIC_NAME_value"
export CLADE="CLADE_value"

export ANNOTATION_NAME="ANNOTATION_NAME_value"

export ANNOTATION_CODE_DIRECTORY="ANNOTATION_CODE_DIRECTORY_value"
export ANNOTATION_LOG_DIRECTORY="ANNOTATION_LOG_DIRECTORY_value"
export ANNOTATION_DATA_DIRECTORY="ANNOTATION_DATA_DIRECTORY_value"

export ENSCODE="ENSCODE_value"

export SERVER_SET="SERVER_SET_value"

export EHIVE_URL=EHIVE_URL_value

export EHIVE_PASS="ensembl"
################################################################################


# genebuild.sh (complete copy)
################################################################################
#export GB_HOME=/nfs/production/flicek/ensembl/genebuild
#export ENSEMBL_ROOT_DIR=/hps/software/users/ensembl/repositories/$USER
#GB_REPO=/hps/software/users/ensembl/repositories/genebuild

#if [[ -n "$LOCAL_PYENV" ]] && [[ -e "/hps/software/users/ensembl/ensw/latest/envs/minimal.sh" ]]; then
#  . /hps/software/users/ensembl/ensw/latest/envs/minimal.sh
#elif [[ -e "/hps/software/users/ensembl/ensw/latest/envs/essential.sh" ]]; then
#  . /hps/software/users/ensembl/ensw/latest/envs/essential.sh
#fi

# minimal.sh (complete copy)
################################################################################
export ENSEMBL_SOFTWARE_HOME=/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge

# obsolete fix
#if [ -f /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/bash-fixes.sh ]; then
#  . /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/bash-fixes.sh
#fi

#if [ -f /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/linuxbrew.sh ]; then
#  . /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/linuxbrew.sh
#fi
# Homebrew (ex Linuxbrew)
################################################################################
export HOMEBREW_ENSEMBL_MOONSHINE_ARCHIVE=/hps/software/users/ensembl/ensw/ENSEMBL_MOONSHINE_ARCHIVE
export ENSEMBL_MOONSHINE_ARCHIVE=/hps/software/users/ensembl/ensw/ENSEMBL_MOONSHINE_ARCHIVE

export LINUXBREW_HOME=/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/linuxbrew
export PATH="$LINUXBREW_HOME/bin:$LINUXBREW_HOME/sbin:$PATH"
export MANPATH="$LINUXBREW_HOME/share/man:$MANPATH"
export INFOPATH="$LINUXBREW_HOME/share/info:$INFOPATH"
################################################################################

#if [ -f /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/plenv.sh ]; then
#  . /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/plenv.sh
#fi
# plenv
################################################################################
PLENV_ROOT="/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/plenv"
if [[ -d "$PLENV_ROOT" ]]; then
    export PLENV_ROOT
    export HOMEBREW_PLENV_ROOT="$PLENV_ROOT"
    export PATH="${PLENV_ROOT}/bin:$PATH"
    eval "$(plenv init -)"
fi

# Only run if we have brew
brew_root=/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/linuxbrew
if [ -d $brew_root ]; then
  brew_htslib=$brew_root/opt/htslib
  if [ -d $brew_htslib ]; then
    export HTSLIB_DIR=${brew_htslib}
  fi
fi
################################################################################

#if [ -f /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/mysql-cmds.sh ]; then
#  . /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/mysql-cmds.sh
#fi
# MySQL commands
# https://www.ebi.ac.uk/seqdb/confluence/display/ENS/MySQL+commands
################################################################################
mysql_cmd_dir="/hps/software/users/ensembl/ensw/mysql-cmds"
if [[ -d "$mysql_cmd_dir" ]]; then
  export PATH="${mysql_cmd_dir}/ensembl/bin:$PATH"
fi
################################################################################

export GB_SCRATCH=/hps/nobackup/flicek/ensembl/genebuild
export BLASTDB_DIR=$GB_SCRATCH/blastdb
export REPEATMODELER_DIR=$GB_SCRATCH/custom_repeat_libraries/repeatmodeler
export LSB_DEFAULTQUEUE="production"
if [[ -n "$LINUXBREW_HOME" ]];then
  if [[ -z "$WISECONFIGDIR" ]]; then
    export PATH="/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/linuxbrew/opt/exonerate09/bin:$PATH"
  fi
  export BIOPERL_LIB="/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/linuxbrew/opt/bioperl-169/libexec"
  export WISECONFIGDIR="/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/linuxbrew/share/genewise"
  export GBLAST_PATH="/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/linuxbrew/bin"
fi

if [[ -d "/nfs/production/flicek/ensembl/production/ensemblftp/data_files" ]];then
  export FTP_DIR="/nfs/production/flicek/ensembl/production/ensemblftp/data_files"
fi

#export HIVE_EMAIL="$USER@ebi.ac.uk"
#export ENSCODE=$ENSEMBL_ROOT_DIR
#export GENEBUILDER_ID=0
export PATH="/hps/software/users/ensembl/genebuild/bin:$PATH"

# # Tokens for different services
# # webhooks for Slack to send notification to any channel
# export SLACK_GENEBUILD='T0F48FDPE/B9B6N48LR/0zjnSpXiK4OlLKB39NutLGCP'
# export GSHEETS_CREDENTIALS="$GB_REPO/ensembl-common/private/credentials.json"

#alias dbhc="$GB_REPO/ensembl-common/scripts/dbhc.sh"
#alias dbcopy="$GB_REPO/ensembl-common/scripts/dbcopy.sh"
#alias run_testsuite="$GB_REPO/ensembl-common/scripts/run_testsuite.sh"

#alias mkgbdir="mkdir -m 2775"

reload_ensembl_release() {
  EVERSION=`mysql-ens-meta-prod-1 ensembl_metadata -NB -e "SELECT ensembl_version FROM data_release WHERE is_current = 1 ORDER BY ensembl_version DESC LIMIT 1"`
  if [[ $EVERSION -gt ${ENSEMBL_RELEASE:-0} ]]; then
    export ENSEMBL_RELEASE=$EVERSION
  elif [[ $EVERSION -lt $ENSEMBL_RELEASE ]];then
    echo "Something is wrong: ENSEMBL_RELEASE=$ENSEMBL_RELEASE and ensembl_production_$EVERSION"
    return 1
  fi
}

reload_ensembl_release
################################################################################


# PERL5LIB
################################################################################
# pipeline dependencies
PERL5LIB="${ENSCODE}/ensembl-analysis/modules"
PERL5LIB="${PERL5LIB}:${ENSCODE}/ensembl-compara/modules"
PERL5LIB="${PERL5LIB}:${ENSCODE}/ensembl-hive/modules"
PERL5LIB="${PERL5LIB}:${ENSCODE}/ensembl-io/modules"
PERL5LIB="${PERL5LIB}:${ENSCODE}/ensembl-killlist/modules"
PERL5LIB="${PERL5LIB}:${ENSCODE}/ensembl-production/modules"
PERL5LIB="${PERL5LIB}:${ENSCODE}/ensembl-taxonomy/modules"
PERL5LIB="${PERL5LIB}:${ENSCODE}/ensembl-variation/modules"
PERL5LIB="${PERL5LIB}:${ENSCODE}/ensembl/modules"

# datachecks dependencies
PERL5LIB="${PERL5LIB}:${ENSCODE}/ensembl-datacheck/lib"
PERL5LIB="${PERL5LIB}:${ENSCODE}/ensembl-metadata/modules"
PERL5LIB="${PERL5LIB}:${ENSCODE}/ensembl-orm/modules"

# BioPerl
BIOPERL_LIB="/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/linuxbrew/opt/bioperl-169/libexec"

PERL5LIB="${PERL5LIB}:${BIOPERL_LIB}"

export PERL5LIB
################################################################################


# Python
################################################################################
PYTHONPATH="${ENSCODE}/ensembl-genes/ensembl_genes"
export PYTHONPATH

export PYENV_VERSION="genebuild"
################################################################################


# PATH
################################################################################
PATH="${PATH}:${ENSCODE}/ensembl-compara/scripts/pipeline"
PATH="${PATH}:${ENSCODE}/ensembl-hive/scripts"
export PATH
################################################################################


# MySQL servers connection details
################################################################################
export GBS1="mysql-ens-genebuild-prod-1"
export GBS2="mysql-ens-genebuild-prod-2"
export GBS3="mysql-ens-genebuild-prod-3"
export GBS4="mysql-ens-genebuild-prod-4"
export GBS5="mysql-ens-genebuild-prod-5"
export GBS6="mysql-ens-genebuild-prod-6"
export GBS7="mysql-ens-genebuild-prod-7"

export GBP1="4527"
export GBP2="4528"
export GBP3="4529"
export GBP4="4530"
export GBP5="4531"
export GBP6="4532"
export GBP7="4533"
################################################################################
