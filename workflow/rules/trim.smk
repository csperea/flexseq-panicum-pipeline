# Step 2: Adapter and quality trimming with fastp


rule fastp:
    input:
        r1 = lambda wc: f"{config['data_dir']}/{config['samples'][wc.sample]}_R1_001.fastq.gz",
        r2 = lambda wc: f"{config['data_dir']}/{config['samples'][wc.sample]}_R2_001.fastq.gz",
    output:
        r1   = "results/trimmed/{sample}_R1.fastq.gz",
        r2   = "results/trimmed/{sample}_R2.fastq.gz",
        html = "results/qc/fastp/{sample}_fastp.html",
        json = "results/qc/fastp/{sample}_fastp.json",
    params:
        min_len   = config["fastp"]["min_length"],
        qual      = config["fastp"]["qualified_quality_phred"],
        win_size  = config["fastp"]["cut_window_size"],
        win_qual  = config["fastp"]["cut_mean_quality"],
        poly_g    = "--trim_poly_g" if config["fastp"]["trim_poly_g"] else "",
    log:
        "logs/fastp/{sample}.log",
    threads: 4
    conda:
        "../envs/trim.yaml"
    shell:
        """
        fastp \
            --in1 {input.r1} --in2 {input.r2} \
            --out1 {output.r1} --out2 {output.r2} \
            --html {output.html} --json {output.json} \
            --detect_adapter_for_pe \
            {params.poly_g} \
            --cut_right \
            --cut_window_size {params.win_size} \
            --cut_mean_quality {params.win_qual} \
            --qualified_quality_phred {params.qual} \
            --length_required {params.min_len} \
            --thread {threads} \
            2> {log}
        """


rule multiqc_trimmed:
    input:
        expand("results/qc/fastp/{sample}_fastp.json", sample=SAMPLES),
    output:
        "results/qc/multiqc_trimmed/multiqc_report.html",
    params:
        indir  = "results/qc/fastp",
        outdir = "results/qc/multiqc_trimmed",
    log:
        "logs/multiqc_trimmed.log",
    conda:
        "../envs/qc.yaml"
    shell:
        "multiqc {params.indir} --outdir {params.outdir} --force > {log} 2>&1"
