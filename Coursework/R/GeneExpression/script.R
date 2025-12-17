# GeneExpression Coding Challenge
# Author: Izan

# loading packages
library(dplyr)
library(ggplot2)
library(readr)

#  in the terminal i cant use file.choose so i pass the file paths in as arguments
# arg [1] refers to the first file path and [2] refers to second
args <- commandArgs(trailingOnly = TRUE)

# if files paths are passed in itll use those
# if not itll use my local files in the repo
G_vs_D_filepath <- if (length(args) >= 1) args[1] else "Datasets/G_vs_D.deseq2.results.tsv"
I_vs_E_filepath <- if (length(args) >= 2) args[2] else "Datasets/I_vs_E.deseq2.results.tsv"

#  checking the input files actually exist otherwise readtsv will fail
stopifnot(file.exists(G_vs_D_filepath))
stopifnot(file.exists(I_vs_E_filepath))

# reading in the two DESeq2 results files into dataframes
G_vs_D <- read_tsv(G_vs_D_filepath)
I_vs_E <- read_tsv(I_vs_E_filepath)

# checking column names to see if loaded
names(G_vs_D)
names(I_vs_E)

# checking rows
head(G_vs_D)
head(I_vs_E)

# setting thresholds based on common cutoffs for DEseq2
padj_cutoff <- 0.05
log2fc_cutoff <- 1

# summary statistics

# making a function to summarise the table the same way per comparison
summarise_results <- function(df, label){
# removing all rows where there are NA values to stop any errors
  clean_results <- df %>%
    filter(!is.na(gene_id),
           !is.na(baseMean),
           !is.na(log2FoldChange),
           !is.na(pvalue),
           !is.na(padj))

# Significant UP genes, so padj below cutoff, bc upregulated we use + log2foldchange
sig_up <- clean_results %>%
  filter(padj < padj_cutoff, log2FoldChange >= log2fc_cutoff)
# Significant Downregulated genes, so padj below cut off and negative log2foldchange
sig_down <- clean_results %>%
  filter(padj < padj_cutoff, log2FoldChange <= -log2fc_cutoff)

# printing results
cat("\n---", label, "---\n")
cat("Total genes:", nrow(clean_results), "\n")
cat("Significant Up:", nrow(sig_up), "\n")
cat("Significant Down:", nrow(sig_down), "\n")

# using baser summary on the main columns for basic statistics like min/median/mean
# summary of log2fc
cat("\nlog2FoldChange summary:\n")
print(summary(clean_results$log2FoldChange))

# summary of pvalue
cat("\npvalue summary:\n")
print(summary(clean_results$pvalue))

# summary of padj
cat("\npadj summary:\n")
print(summary(clean_results$padj))

# returning the useful data like filtered results and significant sets with thresholds
return(list(all = clean_results, up_genes = sig_up, down_genes = sig_down))
}

# running functions to compare
G_vs_D_results <- summarise_results(G_vs_D, "G_vs_D")
I_vs_E_results <- summarise_results(I_vs_E, "I_vs_E")

# creating plots
# Volcano plot
# using the cleaned results returned by the summary function
G_vs_D_clean <- G_vs_D_results$all
I_vs_E_clean <- I_vs_E_results$all
# first labelling each gene as significant or not significant based on our cut off 
G_vs_D_clean$sig <- ifelse(G_vs_D_clean$padj < padj_cutoff &
                             abs(G_vs_D_clean$log2FoldChange) >= log2fc_cutoff,
                           "significant", "not significant")

I_vs_E_clean$sig <- ifelse(I_vs_E_clean$padj < padj_cutoff &
                             abs(I_vs_E_clean$log2FoldChange) >= log2fc_cutoff,
                           "significant", "not significant")

# creating the volcano plot for G vs D
# I'm plotting -log10(padj) because the values are small and dont plot nicely
# This makes it more readable bc smaller/more significant padj appear higher
ggplot(data = G_vs_D_clean, aes(x = log2FoldChange, y = -log10(padj), colour = sig)) +
  geom_point() +
  labs(
  title = "Volcano plot of Gene Expression (G vs D)",
  x = "log2 fold change",
  y = "-log10(adjusted p-value)",
  colour = "Significance"
  )

# ggsave("G_vs_D_volcano.png")

# volcano plot for I vs E
ggplot(data = I_vs_E_clean, aes(x = log2FoldChange, y = -log10(padj), colour = sig)) +
  geom_point() +
  labs(
  title = "Volcano plot of Gene Expression (I vs E)",
  x = "log2 fold change",
  y = "-log10(adjusted p-value)",
  colour = "Significance"
  )
#ggsave("I_vs_E_volcano.png")

# creating MA plot of Mean expression vs log2 fold change

# I will use log10 on these bc some of the values vary a lot so it plots badly
# MA plot for G vs D
ggplot(data = G_vs_D_clean, aes(x = log10(baseMean), y = log2FoldChange, colour = sig)) +
  geom_point() +
  labs(
    title  = "MA plot of Log2 Fold Change vs Mean Expression (G vs D",
    x      = "log10(baseMean)",
    y      = "log2 fold change",
    colour = "Significance"
  )
#ggsave("G_vs_D_MA.png")

# MA plot for I vs E
ggplot(data = I_vs_E_clean, aes(x = log10(baseMean), y = log2FoldChange, colour = sig)) +
  geom_point() +
  labs(
    title  = "MA plot of Log2 Fold Change vs Mean Expression (I vs E)",
    x      = "log10(baseMean)",
    y      = "log2 fold change",
    colour = "Significance"
  )
# ggsave("I_vs_E_MA.png")

# creating histogram to depict distribution of p values across genes
# histogram for g vs d
ggplot(data = G_vs_D_clean, aes(x = pvalue)) +
  geom_histogram() +
  labs(
    title = "Distribution of p-values (G vs D)",
    x = "p-value",
    y = "Number of genes"
  )

#ggsave("G_vs_D_pvalue_hist.png")

# histogram for i vs e
ggplot(data = I_vs_E_clean, aes(x = pvalue)) +
  geom_histogram() +
  labs(
    title = " Distribution of P-values(I vs E)",
    x = "p-value",
    y = "Number of genes"
  )
# ggsave("I_vs_E_pvalue_hist.png")

# heatmap of top differentially expressed genes

n_top_genes <- 20 # pulling 20 most sig genes
# picking top genes by smallest padj
top_G <- G_vs_D_clean %>%
  arrange(padj) %>% # gets smallest padj(most sig) first
  head(n_top_genes)

top_I <- I_vs_E_clean %>%
  arrange(padj) %>%
  head(n_top_genes)

# combines the gene ids to include top genes from both
top_genes <- unique(c(top_G$gene_id, top_I$gene_id))

# trimming this down to only keep the columns needed
G_trimmed <- G_vs_D_clean %>%
  select(gene_id, log2FoldChange)
I_trimmed <- I_vs_E_clean %>%
  select(gene_id, log2FoldChange)
# checking the new columns
names(G_trimmed)
names(I_trimmed)
# before i run merge, im going to rename the log2fc columns
# otherwise r automatically renames them and its unclear
names(G_trimmed)[2] <- "G_vs_D_log2FC" # getting the column names&selecting 2nd one
names(I_trimmed)[2] <- "I_vs_E_log2FC"

# double checking 
names(G_trimmed)
names(I_trimmed)

# merging using gene_id so gene lines up in same row
# all = true means it will keep genes that are in either top list
heat_df <- merge(G_trimmed, I_trimmed, by = "gene_id", all = TRUE)

# keeping only the top genes
heat_df <- heat_df %>%
  filter(gene_id %in% top_genes)

# have to turn this into a numeric matrix bc heatmap() expects one
heat_matrix <- as.matrix(heat_df[, c("G_vs_D_log2FC", "I_vs_E_log2FC")])
row.names(heat_matrix) <- heat_df$gene_id # using geneid as row labels

# handling missing values, some genes could be present in one but not other
# so they will appear as NA in the merged table
# here im replacing NA with 0 so we dont get errors
# might be biologically questionable as NA = missing not no fold change
heat_matrix[is.na(heat_matrix)] <- 0

# using baser heatmap
# making column headers
colnames(heat_matrix) <- c("G vs D", "I vs E")

#png("heatmap_top_genes.png", width = 1200, height = 1100)
par(oma = c(0, 0, 4, 0))  # more space for big title

colours <- colorRampPalette(c("#2EC4B6", "#FFF7E6", "#FF6FB1"))(50)#base colours were bad
heatmap(heat_matrix,
        scale = "none",
        col = colours,
        margins = c(10, 12), # need this so labels dont cut off
        cexRow = 1.2, # bigger text
        cexCol = 1.6, # bigger text
        Colv = NA, # stops columns clustering
        Rowv = TRUE    # clusters rows
)

# using main kept producing rlly small title so trying mtext
mtext("Heatmap of top DE genes (log2FC)",
      side = 3, outer = TRUE, line = 1, cex = 2.4, font = 2)  # bigger title
#dev.off()

# basic analysis
# finding intersection of significant genes btwn the two
common_up <- intersect(G_vs_D_results$up_genes$gene_id, I_vs_E_results$up_genes$gene_id)
common_down <- intersect(G_vs_D_results$down_genes$gene_id, I_vs_E_results$down_genes$gene_id)

# printing 
cat("Common upregulated genes in both comparisons:", length(common_up), "\n")
cat("Common downregulated genes in both comparisons:", length(common_down), "\n")

# saving significant gene lists to csv files
write_csv(G_vs_D_results$up_genes,   "G_vs_D_sig_up.csv")
write_csv(G_vs_D_results$down_genes, "G_vs_D_sig_down.csv")

write_csv(I_vs_E_results$up_genes,   "I_vs_E_sig_up.csv")
write_csv(I_vs_E_results$down_genes, "I_vs_E_sig_down.csv")