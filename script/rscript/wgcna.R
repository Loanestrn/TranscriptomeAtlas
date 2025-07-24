library('WGCNA')
library('DESeq2')
library('GEOquery')
library('tidyverse')
library('CorLevelPlot')
library('gridExtra')

counts_data<-read.csv("C:/Users/loane/OneDrive/Documents/Stage_ete/projetun/geo/retine_rpe.csv")

#preparer data
counts_data <- lapply(counts_data, function(col) if (is.numeric(col)) round(col) else col)
counts_data<- as.data.frame(counts_data)%>%
  column_to_rownames(var='ENSEMBL')


gsg<-goodSamplesGenes(t(counts_data))
gsg$allOK
table(gsg$goodGenes)
table(gsg$goodSamples)
data<-counts_data[gsg$goodGenes==TRUE,]

#detecter outliers
htree<-hclust(dist(t(data)),method='average')
plot(htree)

#en pca
pca<-prcomp(t(data))
pca.dat<-pca$x
pca.var<-pca$sdev^2
pca.var.percent<-round(pca.var/sum(pca.var)*100, digits=2)
pca.dat<-as.data.frame(pca.dat)
ggplot(pca.dat,aes(PC1,PC2))+
  geom_point()+
  geom_text(label=rownames(pca.dat))+
  labs(x=paste0('PC1: ',pca.var.percent[1], '%'),
       y=paste0('PC2: ',pca.var.percent[2], '%'))

#les enlever
samples.to.be.excluded<-c('SRR12807632')
data.subset<-data[,!(colnames(data)%in%samples.to.be.excluded)]

#normalisation
colData<-colData%>%
  filter(!rownames(.)%in%samples.to.be.excluded)
all(colnames(data.subset)%in% rownames(colData))
dds.wgcna<-DESeqDataSetFromMatrix(countData = data.subset, colData=colData, design=~Tissu)
assay(dds.wgcna)

#remove all gene <10 pas posible car trop peu nombreux
##dds10<-dds.wgcna[rowSums(counts(dds)>=10)]
#nrow(dds10) #12418 genes

#avoir counts normalisés
dds_norm <-vst(dds.wgcna)
norm_counts<-assay(dds_norm)%>%
  t()

#construction
power<-c(c(1:10), seq(from=12, to=50, by=2))
sft<-pickSoftThreshold(norm_counts,
                       powerVector = power,
                       networkType = 'signed',
                       verbose=5)
sft.data<-sft$fitIndices

a1<-ggplot(sft.data,aes(Power, SFT.R.sq, label=Power))+
  geom_point()+
  geom_text(nudge_y = 0.1)+
  geom_hline(yintercept = 0.8, color='red')+
  labs(x='Power', y='Scale free topology model fit, signed R^2')+
  theme_classic()
a2<-ggplot(sft.data, aes(Power, mean.k., label=Power))+
  geom_point()+
  geom_text(nudge_y = 0.1)+
  labs(x='Power', y='Mean connectivity')+
  theme_classic()
grid.arrange(a1,a2,nrow=2)
#jai pris 22

#convert matrix
norm_counts[]<- sapply(norm_counts, as.numeric)
soft_power<-22
temp_cor<-cor
cor<-WGCNA::cor

bwnet<-blockwiseModules(norm_counts,
                        maxBlockSize = 14000,
                        TOMType = 'signed',
                        power=soft_power,
                        mergeCutHeight = 0.25,
                        numericLabels = FALSE,
                        randomSeed = 1234,
                        verbose=3)
cor<-temp_cor

#modules
module_eigengenes<- bwnet$MEs
head(module_eigengenes)

table(bwnet$colors)
plotDendroAndColors(
  bwnet$dendrograms[[1]],
  cbind(bwnet$unmergedColors, bwnet$colors),
  c("unmerged", "merged"),
  dendroLabels = FALSE,
  hang = 0.03,
  addGuide = TRUE,
  guideHang = 0.05)


# preparer les fichiers 
traits <- dummy_cols(colData, select_columns = "Tissu", remove_selected_columns = TRUE)
traits$Tissu<-rownames(module_eigengenes)
rownames(traits) <- traits$Tissu
traits$Tissu<-NULL
stopifnot(identical(rownames(module_eigengenes), rownames(traits)))
traits$Sample<-NULL
traits$GSM<-NULL



# Calcul des corrélations 
nGenes<-ncol(norm_counts)
module.tait.corr<-cor(module_eigengenes, tissu.out, use = 'p')
module.tait.corr.pvals<-corPvalueStudent(module.tait.corr, nSamples)

#heatmap
heatmap_data <- merge(module_eigengenes, traits, by = "row.names")
rownames(heatmap_data) <- heatmap_data$Row.names
heatmap_data$Row.names <- NULL

CorLevelPlot(
  heatmap_data,
  x = colnames(traits),                                  
  y = colnames(module_eigengenes),                        
  col = c("blue1", "skyblue", "white", "pink", "red"))


#voir les genes associés
module.gene.mapping<-as.data.frame(bwnet$colors)
module.gene.mapping %>%
  filter(`bwnet$colors`=="orange") %>%
  rownames()
