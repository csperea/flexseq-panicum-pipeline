# Step 1: Quality control on raw reads


rule fastqc_raw:
    input:
        r1 = lambda wc: f"{config['data_dir']}/{config['samples'][wc.sample]}_R1_001.fastq.gz",
        r2 = lambda wc: f"{config['data_dir']}/{config['samples'][wc.sample]}_R2_001.fastq.gz",
    output:
        html_r1 = "results/qc/fastqc/{sample}_R1_fastqc.html",
        zip_r1  = "results/qc/fastqc/{sample}_R1_fastqc.zip",
        html_r2 = "results/qc/fastqc/{sample}_R2_fastqc.html",
        zip_r2  = "results/qc/fastqc/{sample}_R2_fastqc.zip",
    params:
        outdir = "results/qc/fastqc",
    log:
        "logs/fastqc/{sample}.log",
    threads: 2
    conda:
        "../envs/qc.yaml"
    shell:
        """
        fastqc --threads {threads} --outdir {params.outdir} \
            {input.r1} {input.r2} > {log} 2>&1
        # FastQC names outputs after the input filename; rename to sample-based names
        mv {params.outdir}/$(basename {input.r1} .fastq.gz)_fastqc.html {output.html_r1}
        mv {params.outdir}/$(basename {input.r1} .fastq.gz)_fastqc.zip  {output.zip_r1}
        mv {params.outdir}/$(basename {input.r2} .fastq.gz)_fastqc.html {output.html_r2}
        mv {params.outdir}/$(basename {input.r2} .fastq.gz)_fastqc.zip  {output.zip_r2}
        """


rule multiqc_raw:
    input:
        expand("results/qc/fastqc/{sample}_{read}_fastqc.zip",
               sample=SAMPLES, read=["R1", "R2"]),
    output:
        "results/qc/multiqc_raw/multiqc_report.html",
    params:
        indir  = "results/qc/fastqc",
        outdir = "results/qc/multiqc_raw",
    log:
        "logs/multiqc_raw.log",
    conda:
        "../envs/qc.yaml"
    shell:
        "multiqc {params.indir} --outdir {params.outdir} --force > {log} 2>&1"
