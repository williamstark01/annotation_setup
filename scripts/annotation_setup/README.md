# Genebuild annotation setup

Automated setting up and starting a Genebuild annotation.


## annotation setup

The `annotation_setup.sh` script sets up and starts a Genebuild annotation pipeline with a single command that requires just a single argument, the assembly accession of the genome assembly to be annotated.

```
bash annotation_setup.sh <assembly accession>
```

The script creates a directory for the annotation pipeline code dependencies and another with auxiliary files for actually running the annotation pipeline.

A dedicated `enscode` directory is created for the annotation, to make it easy to potentially edit the pipeline code without affecting other running annotations. In order to preserve disk space and also make it easy to merge potential fixes in the code, it creates a [git worktree](https://git-scm.com/docs/git-worktree) for each of the `ensembl-analysis` and `ensembl-genes` repositories in the centralized `ENSCODE` clones. For all other repo dependencies simple symlinks to the centralized clones are created, as they are a lot less likely to require code changes during an annotation.

The setup script also creates a directory with auxiliary files for the annotation, most importantly a `.envrc` file which contains all shell environment variables required by the annotation pipeline. The `.envrc` file is automatically loaded by [direnv](https://direnv.net/) on entering the directory and isolates the annotation pipeline state from all other annotations as well as the user system-wide shell environment configuration.

And last, the script creates a tmux session for the annotation and starts the pipeline automatically, setting it to run up to the analysis "create_rnaseq_for_layer_db".


## usage

set up and start the annotation of the genome assembly with the specified assembly accession
```
bash annotation_setup.sh <assembly accession>
```

optional arguments
```
-s|--server_set <server set>
    Specify the server set to use for the annotation. Defaults to selecting one of ["set1", "set2"] at random.

-e|--enscode_directory <ENSCODE directory>
    Specify the path of the centralized `ENSCODE` directory. Uses the path in the global `ENSCODE` environment variable by default.

-d|--directory <annotation code directory>
    Specify the path for the annotation code directory. Defaults to
    `/nfs/production/panda/ensembl/<username>/annotations/<Scientific_name>-<assembly accession>`.
```


## ENSCODE setup

The `enscode_setup.sh` script simply creates from scratch a centralized `enscode` directory and populates it with all git repositories required by the Genebuild annotation and subsequent datachecks.
