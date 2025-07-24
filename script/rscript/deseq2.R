# Function to load or install a CRAN package
load_cran_library <- function(package_name) {
   if (!require(package_name, character.only = TRUE)) {
      install.packages(package_name, dependencies = TRUE)
      library(package_name, character.only = TRUE)
   }
}

# Function to load or install a Bioconductor package
load_bioconductor_library <- function(package_name) {
   if (!requireNamespace(package_name, quietly = TRUE)) {
      if (!requireNamespace("BiocManager", quietly = TRUE)) {
         install.packages("BiocManager")
      }
      BiocManager::install(package_name)
   }
   library(package_name, character.only = TRUE)
}

load_bioconductor_library('airway')
load_bioconductor_library('DESeq2')
load_cran_library('tidyverse')
load_bioconductor_library('org.Hs.eg.db')
load_bioconductor_library('EnhancedVolcano')

input="/home/sturny/stageLGM/TranscriptomeAtlas/benchmarks/data/1_input"
output= "/home/sturny/stageLGM/TranscriptomeAtlas/benchmarks/data/output/resultats_R"

#preparer les donnees

counts_data<-read.csv(file.path(input,"retine_rpe.csv"))
colData<-read.csv(file.path(input,"metadata","metadata.csv"))
rownames(counts_data) <- counts_data$ENSEMBL 
counts_data$ENSEMBL <- NULL
rownames(colData) <- colData$SRR
colData$SRR <- NULL  
counts_data<-round(counts_data)
all(colnames(counts_data)%in% rownames(colData))
all(colnames(counts_data)==rownames(colData))

dds<-DESeqDataSetFromMatrix(countData=counts_data, colData=colData, design=~Tissu)
keep<-rowSums(counts(dds))>=10
dds<-dds[keep,]

#run dds

dds <- DESeq(dds)
res<- results(dds)
res
write.csv(as.data.frame(res), file = file.path(output,"resultats_deseq2.csv"))

#contrast
resultsNames(dds)
PVSC<-results(dds, contrast=c('Tissu', 'periphery', 'centre'))
PVSR<-results(dds, contrast=c('Tissu', 'periphery', 'RPE'))
RVSC<-results(dds, contrast=c('Tissu', 'RPE', 'centre'))

#plotMA
plotMA(PVSC)
plotMA(PVSR)
plotMA(RVSC)

#symboles
PVSC.df<-as.data.frame(PVSC)
PVSC.df$symbol<-mapIds(org.Hs.eg.db, keys=rownames(PVSC.df), keytype='ENSEMBL', column= 'SYMBOL')
PVSC.df
PVSR.df<-as.data.frame(PVSR)
PVSR.df$symbol<-mapIds(org.Hs.eg.db, keys=rownames(PVSR.df), keytype='ENSEMBL', column= 'SYMBOL')
RVSC.df<-as.data.frame(RVSC)
RVSC.df$symbol<-mapIds(org.Hs.eg.db, keys=rownames(RVSC.df), keytype='ENSEMBL', column= 'SYMBOL')

#PCA
vsd <- vst(dds, blind = TRUE)
plotPCA(vsd, intgroup = "Tissu")
sig_df1 <- PVSC.df[which(PVSC.df$padj < 0.05 & abs(PVSC.df$log2FoldChange) > 1), ]
sig_df2 <- PVSR.df[which(PVSR.df$padj < 0.05 & abs(PVSR.df$log2FoldChange) > 1), ]
sig_df3 <- RVSC.df[which(RVSC.df$padj < 0.05 & abs(RVSC.df$log2FoldChange) > 1), ]
write.csv(as.data.frame(sig_df1), file = file.path(output,"periphery_centre_R.csv"))
write.csv(as.data.frame(sig_df2), file =  file.path(output,"periphery_RPE_R.csv"))
write.csv(as.data.frame(sig_df3), file = file.path(output, "RPE_centre_R.csv"))



#volcanoplot 
EnhancedVolcano(sig_df1,
                x = 'log2FoldChange',
                y = 'padj',
                lab = sig_df1$symbol,                 
                selectLab = sig_df1$symbol,           
                xlim = c(-10, 2),
                ylim = c(1, 4))


EnhancedVolcano(sig_df2,
                x = 'log2FoldChange',
                y = 'padj',
                lab = sig_df2$symbol,                 
                selectLab = sig_df2$symbol,           
                xlim = c(-10, 15),
                ylim = c(0, 30))

EnhancedVolcano(sig_df3,
                x = 'log2FoldChange',
                y = 'padj',
                lab = sig_df3$symbol,                 
                selectLab = sig_df3$symbol,           
                xlim = c(-15, 10),
                ylim = c(0, 30))

