# asdf d
load("datosLimpios.RData")


#  ejericio 1 -----------------
nrow(datosLimpios)

summary(datosLimpios)

# media aclaracion
# desvio aclaracion

media_name_area = mean(datosLimpios$Name.Area)
sd_name_area = sd(datosLimpios$Name.Area)

umbral = media_name_area + 3*sd_name_area

debajo_umbral = datosLimpios$Name.Area < umbral

datos_filtrados = datosLimpios[debajo_umbral,]


### luego de filtrar  -----------

datos_hombres = datos_filtrados[ datos_filtrados$Sex == "M" ,]
datos_mujeres = datos_filtrados[ datos_filtrados$Sex == "F" ,]

datos_hombres$ratio = datos_hombres$Sign.Area / datos_hombres$Name.Area

datos_mujeres$ratio = datos_mujeres$Sign.Area / datos_mujeres$Name.Area

#### correlaciones ----------


a = 1
a = "carambola"
a = 2




cor_ratio_npi_h = cor(datos_hombres$ratio,datos_hombres$NPI16TOTAL,use = "complete.obs")

cor_ratio_npi_m = cor(datos_mujeres$ratio,datos_mujeres$NPI16TOTAL,use = "complete.obs")


cor_ratio_ad_m


resutlado = 12

cor(datos_hombres$NPI16TOTAL,datos_hombres$ratio,use = "pairwise.complete.obs")


# ejercicio parte 2 ---------