# vim: set filetype=sh :

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

# minimal.sh
################################################################################
export ENSEMBL_SOFTWARE_HOME=/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge

if [ -f /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/bash-fixes.sh ]; then
  . /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/bash-fixes.sh
fi
if [ -f /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/linuxbrew.sh ]; then
  . /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/linuxbrew.sh
fi
if [ -f /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/plenv.sh ]; then
  . /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/plenv.sh
fi
if [ -f /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/mysql-cmds.sh ]; then
  . /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/mysql-cmds.sh
fi
################################################################################

### plenv
PLENV_ROOT="/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/plenv"
if [[ -d "$PLENV_ROOT" ]]; then
    export PLENV_ROOT
    #export HOMEBREW_PLENV_ROOT="$PLENV_ROOT"
    export PATH="${PLENV_ROOT}/bin:$PATH"
    eval "$(plenv init -)"
fi

# genebuild.sh
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

if [[ -d "/nfs/production/panda/ensembl/production/ensemblftp/data_files" ]];then
  export FTP_DIR="/nfs/production/panda/ensembl/production/ensemblftp/data_files"
fi

################################################################################
# # Homebrew (Linuxbrew)
# ################################################################################
# # /hps/software/users/ensembl/ensw/latest/envs/minimal.sh
# # /hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/envs/linuxbrew.sh
# export ENSEMBL_SOFTWARE_HOME=/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge
# 
# export HOMEBREW_ENSEMBL_MOONSHINE_ARCHIVE=/hps/software/users/ensembl/ensw/ENSEMBL_MOONSHINE_ARCHIVE
# export ENSEMBL_MOONSHINE_ARCHIVE=/hps/software/users/ensembl/ensw/ENSEMBL_MOONSHINE_ARCHIVE
# 
#export LINUXBREW_HOME=/hps/software/users/ensembl/ensw/C8-MAR21-sandybridge/linuxbrew
#export PATH="$LINUXBREW_HOME/bin:$LINUXBREW_HOME/sbin:$PATH"
#export MANPATH="$LINUXBREW_HOME/share/man:$MANPATH"
#export INFOPATH="$LINUXBREW_HOME/share/info:$INFOPATH"
# ################################################################################


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


# PYTHONPATH
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
