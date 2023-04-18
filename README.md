# JMF independent workflows
This repository contains dependency-independent workflows that can be shared and used on Joint Microbiome Facility (University of Vienna and Medical University of Vienna) generated data.

These workflows are designed to be run on a SLURM-based server system with snakemake but should be able to run on any linux system as all of the dependencies are installed using bioconda through snakemake.

For reproducibility these directories are designed around snakemake's directory structure (found here: https://snakemake.readthedocs.io/en/stable/snakefiles/deployment.html) 

That looks like this:
├── .gitignore
├── README.md
├── LICENSE.md
├── **workflow**
│   ├── **rules**
|   │   ├── module1.smk
|   │   └── module2.smk
│   ├── **envs**
|   │   ├── tool1.yaml
|   │   └── tool2.yaml
│   ├── **scripts**
|   │   ├── script1.py
|   │   └── script2.R
│   ├── notebooks
|   │   ├── notebook1.py.ipynb
|   │   └── notebook2.r.ipynb
│   ├── report
|   │   ├── plot1.rst
|   │   └── plot2.rst
|   └── **Snakefile**
├── **config**
│   ├── **config.yaml**
│   └── some-sheet.tsv
├── results
└── resources



In general this can be run like this: 

`
#module load conda
#module load snakemake
snakemake -cores <threads> -s <snakemake workflow/rule -j10>
`


More workflows will be added soon, along with more description on how to use them!

Please feel free to share comments/issues/suggestions with me in anyway!
