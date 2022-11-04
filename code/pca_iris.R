# Primero cargamos las librerías que vamos a utilizar
library(tidyverse)
library(glue)
library(ggthemes)
library(openxlsx)
library(ggtext)

# Echamos un vistazo a los datos de iris esta base de 
# datos viene de serie en R.
# Las primeras 9 filas:
iris %>% head(n=9)
# El número de columnas:
iris %>% ncol()
# EL número de filas:
iris %>% nrow()
# Las especies de iris y su número:
iris %>%
    group_by(Species) %>%
    count()
# Guardamos los datos en datos crudos, para que parezca
# un pipeline de verdad. xlsx no va en linux :(, usaremos
# openxlsx: fail por el momento
# write.table(iris, "data/raw/iris.csv", sep=",")
# Como vamos a hacer un pca nos interesa únicamente
# las variables cuantitativas por el momento
matrix_iris <- iris[,-5] 
# Vemos que nos hemos desecho de los grupos
matrix_iris %>% colnames()

# Vamos a usar prcomp:
pca_iris <- prcomp(matrix_iris, scale=TRUE, center=TRUE)

# Vemos el resumen del pca
resumen_pca_iris <- summary(pca_iris);resumen_pca_iris

# Vamos a calcular el % de la varianza de las primeras
# componentes:
var_pc1 <- round(resumen$importance[2,1]*100,2);var_pc1
var_pc2 <- round(resumen$importance[2,2]*100,2);var_pc2
# Varianza acumulada explicada de las dos primeras 
# componentes:
var_acumulada <- var_pc1 + var_pc2;var_acumulada

# Vamos a crear un tibble de las dos primeras com_
# ponentes, añadimos las especies también:

pc_iris <- as_tibble(pca_iris$x[,c(1,2)]) %>%
    mutate(species=iris$Species)
# Vemos las primeras filas:
pc_iris %>% head()

# Graficamos los resultados
ggiris <- pc_iris %>%
    mutate(species=factor(species,
                          levels=c("setosa","versicolor",
                                   "virginica"),
                          labels=c("Setosa", "Versicolor",
                                   "Virginica"))) %>%
    ggplot(aes(PC1,PC2,color=species, 
               fill=species)) +
    geom_point(pch=21,color="black") +
    stat_ellipse(geom="polygon",alpha=.35,
                 size=.75) +
    labs(
        title="PCA for the Species of iris",
        subtitle=glue("<span style='color:red'>?% of the acumulative varianze expalined</span>"),
        x=glue("PC1 (?% varianze explained)"),
        y=glue("PC2 (?% varianze explained)"),
        fill=NULL, color=NULL
    ) +
    scale_fill_manual(values=c("magenta","forestgreen",
                                   "blue")) +
    scale_color_manual(values=c("magenta","forestgreen",
                                    "blue")) +
    theme_classic() +
    theme(
        plot.title=element_text(hjust=.5,size=16,
                                face="bold"),
        plot.subtitle=element_markdown(hjust=.5, size=14,
                                       face="bold"),
        axis.title=element_text(size=12, face="bold"),
        axis.text=element_text(size=11, face="bold"),
        legend.background=element_rect(color="black",
                                       fill=NULL),
        legend.position=c(.4,.2),
        legend.text=element_text(size=11)
    ) 


ggsave("images/pca_iris.png", 
       width=6, height=5)

getwd()
