# flexseq-panicum-pipeline

Snakemake pipeline for processing LGC FlexSeq amplicon sequencing data from *Panicum maximum* (Guinea Grass) — from raw FASTQ to filtered multi-sample VCF.

## Overview

**Input:** Paired-end FASTQ files (21 samples, LGC/RAPiD-Genomics FlexSeq)  
**Reference:** Guinea Grass 4-haplotype chromosomal assembly (*P. maximum*, tetraploid)  
**Output:** Filtered multi-sample VCF ready for GWAS / population genomics

## Pipeline steps

1. **QC** — FastQC + MultiQC on raw reads
2. **Trimming** — adapter and quality trimming with fastp
3. **Alignment** — bwa-mem2 against the 4-haplotype reference
4. **Variant calling** — FreeBayes joint calling (ploidy=4)
5. **Filtering** — bcftools filter on QUAL, depth, and missing data

## Usage

```bash
# Dry run (check what will be executed)
conda activate snakemake
snakemake --snakefile workflow/Snakefile --use-conda -n

# Run locally
snakemake --snakefile workflow/Snakefile --use-conda --cores 8

# Run on SLURM cluster
snakemake --snakefile workflow/Snakefile --use-conda \
    --executor slurm --jobs 21
```

## Configuration

All parameters are in `config/config.yaml`:
- Sample list and file prefixes
- Paths to data and reference
- fastp, bwa-mem2, FreeBayes, and filtering parameters

## Requirements

- Conda / Mamba
- Snakemake ≥ 9.0
- Per-rule environments are defined in `workflow/envs/` and created automatically by Snakemake
