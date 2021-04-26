# Genebuild annotation setup

Automated method of setting up and initializing a Genebuild annotation.


## annotation setup

The `annotation_setup.sh` sets up and starts a Genebuild annotation pipeline with a single command which requires just a single argument, the assembly accession of the genome assembly to be annotated.

The script creates a directory for the annotation pipeline code dependencies and another with auxiliary files for actually running the annotation pipeline.

A dedicated `enscode` directory is created for the annotation, to make it easy to potentially edit the pipeline code without affecting other running annotations. In order to preserve disk space and also make it easy to merge potential fixes in the code, it creates a [git worktree](https://git-scm.com/docs/git-worktree) for each of the `ensembl-analysis` and `ensembl-genes` repositories in the centralized `ENSCODE` clones. For all other repo dependencies a simple symlink is generated to the centralized clones, as they are a lot less likely to require code changes during an annotation.

The setup script also creates a directory for auxiliary files for the annotation, most importantly a `.envrc` file which contains all shell environment variables required by the annotation pipeline. The `.envrc` file is automatically loaded by [direnv](https://direnv.net/) and isolates the annotation pipeline state from all other annotations as well as the user system-wide shell environment configuration.

Last, the script creates a tmux session for the annotation and starts the pipeline automatically, setting it to run up to the analysis "create_rnaseq_for_layer_db".

The directory for the annotation is created by default in the `/nfs/production/panda/ensembl/<username>/annotations/` directory and has the format `<Scientific_name>-<assembly accession>` but it can be also specified as an argument.


## enscode setup

The `enscode_setup.sh` script simply creates from scratch a centralized `enscode` directory containing all git repositories that the Genebuild annotation and datachecks depend on.
