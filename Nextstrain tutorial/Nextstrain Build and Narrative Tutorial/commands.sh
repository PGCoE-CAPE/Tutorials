0.0 DEMO: Running a pathogen workflow

qlogin
ml Nextstrain-CLI/20240604

Text installtion
nextstrain shell .
augur --help
auspice --help
exit

Download the example Zika workflow repository
git clone https://github.com/nextstrain/zika-tutorial

Run the workflow
nextstrain build --cpus 1 zika-tutorial/

Visualize results
nextstrain view zika-tutorial/auspice/

rm -rf zika-tutorial


1.0 Nextstrain Install

Install Nextstrain CLI
curl -fsSL --proto '=https' https://nextstrain.org/cli/installer/linux | bash

Set up a Nextstrain runtime (We use the term “runtime” to refer to specific computing environments like Augur and Auspice)
nextstrain setup --set-default conda

2.0 Creating a pathogen workflow

2.1 Create a folder for results

git clone https://github.com/nextstrain/zika-tutorial

cd zika-tutorial

mkdir -p results/

nextstrain shell .

2.2 Index the Sequences

augur index \
  --sequences data/sequences.fasta \
  --output results/sequence_index.tsv

2.3 Filter the Sequences

augur filter \
  --sequences data/sequences.fasta \
  --sequence-index results/sequence_index.tsv \
  --metadata data/metadata.tsv \
  --exclude config/dropped_strains.txt \
  --output results/filtered.fasta \
  --group-by country year month \
  --sequences-per-group 20 \
  --min-date 2012

2.4 Align the Sequences

augur align \
  --sequences results/filtered.fasta \
  --reference-sequence config/zika_outgroup.gb \
  --output results/aligned.fasta \
  --fill-gaps

2.5 Construct the Phylogeny

augur tree \
  --alignment results/aligned.fasta \
  --output results/tree_raw.nwk

2.6 Get a Time-Resolved Tree

augur refine \
  --tree results/tree_raw.nwk \
  --alignment results/aligned.fasta \
  --metadata data/metadata.tsv \
  --output-tree results/tree.nwk \
  --output-node-data results/branch_lengths.json \
  --timetree \
  --coalescent opt \
  --date-confidence \
  --date-inference marginal \
  --clock-filter-iqd 4

2.7 Annotate the Phylogeny: Reconstruct Ancestral Traits

augur traits \
  --tree results/tree.nwk \
  --metadata data/metadata.tsv \
  --output-node-data results/traits.json \
  --columns region country \
  --confidence

2.8 Annotate the Phylogeny: Infer Ancestral Sequences

augur ancestral \
  --tree results/tree.nwk \
  --alignment results/aligned.fasta \
  --output-node-data results/nt_muts.json \
  --inference joint

2.9 Annotate the Phylogeny: Identify Amino-Acid Mutations

augur translate \
  --tree results/tree.nwk \
  --ancestral-sequences results/nt_muts.json \
  --reference-sequence config/zika_outgroup.gb \
  --output-node-data results/aa_muts.json

2.10 Export the Results

augur export v2 \
  --tree results/tree.nwk \
  --metadata data/metadata.tsv \
  --node-data results/branch_lengths.json \
              results/traits.json \
              results/nt_muts.json \
              results/aa_muts.json \
  --colors config/colors.tsv \
  --lat-longs config/lat_longs.tsv \
  --auspice-config config/auspice_config.json \
  --output auspice/zika.json


