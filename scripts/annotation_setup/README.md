# Genebuild annotation setup

Automated method of setting up and initializing a Genebuild annotation.


## annotation setup

The `annotation_setup.sh` takes a single required argument, the assembly accession, and generates a directory and file structure for the annotation to be initialized with a single command.

A dedicated `enscode` directory is generated for the annotation to make it possible to potentially edit the code without affecting other running annotations. In order to preserve disk space and also make it easy to merge potential fixes in the code, it creates a git [worktree](https://git-scm.com/docs/git-worktree) for `ensembl-analysis` and `ensembl-genes` that are connected to the centralized `enscode` clones for these repositories. For all other repo dependencies a simple symlink is generated to the centralized clones, as they are a lot less likely to require code changes during an annotation.

Furthermore, the setup script generates a `.envrc` file with all environment variables required by the annotation pipeline, which is automatically loaded by [direnv](https://direnv.net/) and isolates the annotation state from all other annotations and the user system-wide environment configuration.


## enscode setup

The `enscode_setup.sh` script simply creates from scratch a centralized `enscode` directory containing all git repositories that the Genebuild annotation and datachecks depend on.
