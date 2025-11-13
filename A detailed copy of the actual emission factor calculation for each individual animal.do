*The emission factors for livestock were calculated using the "Animal GHG emission factors.dta" dataset, following the IPCC Tier 2 methodology.


use "F:\Desktop\Animal GHG emission factors.dta",clear


***GE***


gen Cfi=0.322*other_cattle+0.386*female_cattle+0.370*male_cattle if animal==1
replace Cfi=0.236*little_sheep+0.217*big_sheep if animal==2

gen NEm=Cfi*(animal_weight^0.75)



gen walk= ((harea*667)^0.5 )*(2^0.5)

gen fangmufs=1 if walk<=1000
replace fangmufs=2 if walk>1000 & walk<5000
replace fangmufs=3 if walk>=5000 

gen Ca11=0.0067 if animal==2 & fangmufs==1
gen Ca12=0.0107 if animal==2 & fangmufs==2
gen Ca13=0.024  if animal==2 & fangmufs==3

gen Ca21=0    if animal==1 & fangmufs==1
gen Ca22=0.17 if animal==1 & fangmufs==2
gen Ca23=0.36 if animal==1 & fangmufs==3

replace Ca=Ca11 if Ca11!=.
replace Ca=Ca12 if Ca12!=.
replace Ca=Ca13 if Ca13!=.
replace Ca=Ca21 if Ca21!=.
replace Ca=Ca22 if Ca22!=.
replace Ca=Ca23 if Ca23!=.

gen NEa=Ca*NEm if animal==1
replace NEa=Ca*animal_weight if animal==2



gen WG_cattle=(animal_weight-38.7)/age_bigcattle if animal==1 & animal_weight>485 & animal_weight<=750   
replace WG_cattle=(animal_weight-38.7)/age_smallcattle if animal==1 & animal_weight>100 & animal_weight<=485
gen WG_sheep=(animal_weight-2.67)/age_bigsheep if animal==2 & animal_weight>46 & animal_weight<=90 
replace WG_sheep=(animal_weight-2.67)/age_smallsheep if animal==2 & animal_weight<46 & animal_weight>=15

xtile group1=WG_cattle,n(100)
bysort group1: sum WG_cattle
replace WG_cattle=. if group1>=0 & group1<=17
replace WG_cattle=. if group1>=26 & group1<=100
bysort village:egen WG_cattle_mean=mean(WG_cattle) if animal==1
replace WG_cattle=WG_cattle_mean if animal==1 & WG_cattle==.
bysort county:egen WG_cattle_mean1=mean(WG_cattle) if animal==1
replace WG_cattle=WG_cattle_mean1 if animal==1 & WG_cattle==.

xtile group2=WG_sheep,n(100)
bysort group2: sum WG_sheep
replace WG_sheep=. if group2>=0 & group2<=49
replace WG_sheep=. if group2>=79 & group2<=100
bysort village:egen WG_sheep_mean=mean(WG_sheep) if animal==2
replace WG_sheep=WG_sheep_mean if animal==2 & WG_sheep==.

 
gen NEg=22.02*((animal_weight/568))^0.75*((WG_cattle)^1.097) if animal==1  
replace NEg=(WG_sheep*(wgborn-15)*((2.5*male_sheep+2.1*female_sheep+4.4*other_sheep)+0.5*(0.35*male_sheep+0.45*female_sheep+0.32*other_sheep)*(wgborn+15)))/365 if animal==2  


bys 村代码 animal:egen mean_neg=mean(NEg==.)
replace NEg=mean_neg if NEg==.

gen milk=5

gen NEl=milk*(1.47+0.4*(4/100))*renshen*(60/365)*(2/3) if animal==1  
replace NEl=0 if animal==1 & animal_weight>100 & animal_weight<=485
replace NEl=((5*12.33)/365)*4.6*renshen*(60/365) if animal==2 
replace NEl=0 if animal==2 & animal_weight<46 & animal_weight>=15



gen hours=0
gen NEwork=0.1*NEm*hours if animal==1 
replace NEwork=0 if animal==2



gen Prwool=0
replace NEwool=(24*Prwool)/365 if animal==2
replace NEwool=0 if animal==1

 
gen Cp=0.1 if animal==1
replace Cp=0.077 if animal==2

gen NEp=Cp*NEm*renshen*(281/365)*(2/3)  if animal==1
replace NEp=Cp*NEm*renshen*(147/365)  if animal==2


gen DE=62     if siweizhiliang==1 & animal==1
replace DE=(62+71)/2 if siweizhiliang==2 & animal==1
replace DE=72        if siweizhiliang==3 & animal==1
replace DE=(45+55)/2 if siweizhiliang==1 & animal==2
replace DE=(55+80)/2 if siweizhiliang==2 & animal==2
replace DE=(72+85)/2 if siweizhiliang==3 & animal==2

gen REM=(1.123-((4.092*(10^(-3)))*DE))+((1.126*(10^(-5)))*(DE^2))-(25.4/DE) 


gen REG=(1.164-((5.16*(10^(-3)))*DE))+((1.308*(10^(-5)))*(DE^2))-(37.4/DE)





gen GE=(((NEm+NEa+NEl+NEwork+NEp)/REM)+((NEg+NEwool)/REG))/(DE/100)
*gen GE=(((NEm+NEa)/REM)+((NEg)/REG))/(DE/100)


***calculation GE***


***EFcd**

gen YM=7.0 if DE==62
replace YM=6.3 if DE==(62+71)/2
replace YM=4.0 if DE==72
replace YM=7.6 if DE==(45+55)/2 
replace YM=6.7 if DE==(55+80)/2
replace YM=5.8 if DE==(72+85)/2

gen EFcd=(GE*(YM/100)*365)/55.65



gen EFcd_cattle=EFcd if animal==1
gen EFcd_sheep=EFcd if animal==2

***EFcd***


***EFfb***

gen VS=((GE*(1-(DE/100)))+(0.04*GE))*((1-0.06)/18.45)

gen B0=0.18 if animal==1
replace B0=0.19 if animal==2


gen EFfb=VS*365*(B0*0.67*((2/100)*0.06+(1/100)*0.64+(0.47/100)*0.28+(10/100)*0.02))  if animal==1
replace EFfb=VS*365*(B0*0.67*((2/100)*0.17+(1/100)*0.03+(0.47/100)*0.8)) if animal==2


gen EFfb_cattle=EFfb if animal==1
gen EFfb_sheep=EFfb if animal==2


***EFfb***




***EF_N2O***
gen CP=13.5
gen N_intake=(GE/18.45)*(CP/100/6.25)

gen N_retention=WG_cattle*(268-(7.03*NEg/0.8))/1000/6.25 if animal==1
replace N_retention=WG_sheep*(268-(7.03*NEg/0.3))/1000/6.25 if animal==2

gen Nex=N_intake*(1-N_retention)*365


gen EF_N2Odirect=(Nex*(0.06*0.01+0.64*0.005+0.28*0.004+0.02*0.01))*(44/28)  if animal==1
gen EF_N2Oleach= (Nex*(0.06*0.01+0.64*0.005+0.28*0.004+0.02*0.01))*0.24*0.01*(44/28)  if animal==1
gen EF_N2Ogas=   (Nex*(0.06*0.01+0.64*0.005+0.28*0.004+0.02*0.01))*0.21*0.011*(44/28)  if animal==1

replace EF_N2Odirect=(Nex*(0.17*0.01+0.03*0.02+0.8*0.003))*(44/28)   if animal==2
replace EF_N2Oleach= (Nex*(0.17*0.01+0.03*0.02+0.8*0.003))*0.24*0.010*(44/28)   if animal==2
replace EF_N2Ogas=   (Nex*(0.17*0.01+0.03*0.02+0.8*0.003))*0.21*0.011*(44/28)   if animal==2




gen EF_N2O=EF_N2Odirect+EF_N2Oleach+EF_N2Ogas


gen EF_N2O_cattle=EF_N2O if animal==1
gen EF_N2O_sheep=EF_N2O if animal==2

***EF_N2O***

gen emission =EFcd*25+EFfb*25+EF_N2O*298
sum EFcd_cattle EFcd_sheep EFfb_cattle EFfb_sheep EF_N2O_cattle EF_N2O_sheep


***One-dimensional***
bysort animal:egen EF1cd_mean=mean(EFcd)
bysort animal:egen EF1fb_mean=mean(EFfb)
bysort animal:egen EF1_N2O_mean=mean(EF_N2O)

tab EF1cd_mean,m
tab EF1fb_mean,m
tab EF1_N2O_mean,m

***One-dimensional***

***Two-dimensional***

*（1）Adult Livestock Young Livestock
*11 = Calf, 12 = Adult Cattle, 21 = Lamb, 22 = Adult Sheep
replace shengchudaxiao=11 if animal==1 & animal_weight<485
replace shengchudaxiao=12 if animal==1 & animal_weight>=485
replace shengchudaxiao=21 if animal==2 & animal_weight<46
replace shengchudaxiao=22 if animal==2 & animal_weight>=46

bysort shengchudaxiao:egen EF1cd_mean1=mean(EFcd)
bysort shengchudaxiao:egen EF1fb_mean1=mean(EFfb)
bysort shengchudaxiao:egen EF1_N2O_mean1=mean(EF_N2O)

bys animal :sum EFcd EFfb EF_N2O


*(2) Feeding Quality  
* 1 = Low Quality  2 = Medium Quality  3 = High Quality
bysort animal siweizhiliang:egen EFcd_mean2=mean(EFcd)
bysort animal siweizhiliang:egen EFfb_mean2=mean(EFfb)
bysort animal siweizhiliang:egen EF_N2O_mean2=mean(EF_N2O)

bys animal siweizhiliang :sum EFcd EFfb EF_N2O


*(3) Grazing Method  
* 1 = Stall-feeding  2 = Plain Grazing  3 = Hilly Grazing

bysort animal fangmufs:egen EFcd_mean3=mean(EFcd)
bysort animal fangmufs:egen EFfb_mean3=mean(EFfb)
bysort animal fangmufs:egen EF_N2O_mean3=mean(EF_N2O)

tab animal fangmufs,m
tab fangmufs EFcd_mean3,m
tab fangmufs EFfb_mean3,m
tab fangmufs EF_N2O_mean3,m
bys animal fangmufs :sum EFcd EFfb EF_N2O

*(4) Grassland Type  
* 1 = Desert Steppe  2 = Typical Steppe  3 = Meadow Steppe
replace county=3 if county==4
bysort county animal:egen EFcd_mean4=mean(EFcd)
bysort county animal:egen EFfb_mean4=mean(EFfb)
bysort county animal:egen EF_N2O_mean4=mean(EF_N2O)

tab county EFcd_mean4,m
tab county EFfb_mean4,m
tab county EF_N2O_mean4,m

bys animal county :sum EFcd EFfb EF_N2O

***Two-dimensional***


***Three-dimensional***
*(1) Grazing Method  
* 11 = Calf  
* 12 = Adult Cattle  
* 21 = Lamb  
* 22 = Adult Sheep  
* 1 = Low Quality  2 = Medium Quality  3 = High Quality  
* 1 = Stall-feeding  2 = Plain Grazing  3 = Hilly Grazing  

* 1111 = Calf, Low Quality, Stall-feeding  
* 1112 = Calf, Low Quality, Plain Grazing  
* 1113 = Calf, Low Quality, Hilly Grazing  
* 1121 = Calf, Medium Quality, Stall-feeding  
* 1122 = Calf, Medium Quality, Plain Grazing  
* 1123 = Calf, Medium Quality, Hilly Grazing  
* 1131 = Calf, High Quality, Stall-feeding  
* 1132 = Calf, High Quality, Plain Grazing  
* 1133 = Calf, High Quality, Hilly Grazing  

replace FMFS=1111 if shengchudaxiao==11&siweizhiliang==1&fangmufs==1
replace FMFS=1112 if shengchudaxiao==11&siweizhiliang==1&fangmufs==2
replace FMFS=1113 if shengchudaxiao==11&siweizhiliang==1&fangmufs==3
replace FMFS=1121 if shengchudaxiao==11&siweizhiliang==2&fangmufs==1
replace FMFS=1122 if shengchudaxiao==11&siweizhiliang==2&fangmufs==2
replace FMFS=1123 if shengchudaxiao==11&siweizhiliang==2&fangmufs==3
replace FMFS=1131 if shengchudaxiao==11&siweizhiliang==3&fangmufs==1
replace FMFS=1132 if shengchudaxiao==11&siweizhiliang==3&fangmufs==2
replace FMFS=1133 if shengchudaxiao==11&siweizhiliang==3&fangmufs==3

* 1211 = Adult Cattle, Low Quality, Stall-feeding  
* 1212 = Adult Cattle, Low Quality, Plain Grazing  
* 1213 = Adult Cattle, Low Quality, Hilly Grazing  
* 1221 = Adult Cattle, Medium Quality, Stall-feeding  
* 1222 = Adult Cattle, Medium Quality, Plain Grazing  
* 1223 = Adult Cattle, Medium Quality, Hilly Grazing  
* 1231 = Adult Cattle, High Quality, Stall-feeding  
* 1232 = Adult Cattle, High Quality, Plain Grazing  
* 1233 = Adult Cattle, High Quality, Hilly Grazing

replace FMFS=1211 if shengchudaxiao==12&siweizhiliang==1&fangmufs==1
replace FMFS=1212 if shengchudaxiao==12&siweizhiliang==1&fangmufs==2
replace FMFS=1213 if shengchudaxiao==12&siweizhiliang==1&fangmufs==3
replace FMFS=1221 if shengchudaxiao==12&siweizhiliang==2&fangmufs==1
replace FMFS=1222 if shengchudaxiao==12&siweizhiliang==2&fangmufs==2
replace FMFS=1223 if shengchudaxiao==12&siweizhiliang==2&fangmufs==3
replace FMFS=1231 if shengchudaxiao==12&siweizhiliang==3&fangmufs==1
replace FMFS=1232 if shengchudaxiao==12&siweizhiliang==3&fangmufs==2
replace FMFS=1233 if shengchudaxiao==12&siweizhiliang==3&fangmufs==3

* 2111 = Lamb, Low Quality, Stall-feeding  
* 2112 = Lamb, Low Quality, Plain Grazing  
* 2113 = Lamb, Low Quality, Hilly Grazing  
* 2121 = Lamb, Medium Quality, Stall-feeding  
* 2122 = Lamb, Medium Quality, Plain Grazing  
* 2123 = Lamb, Medium Quality, Hilly Grazing  
* 2131 = Lamb, High Quality, Stall-feeding  
* 2132 = Lamb, High Quality, Plain Grazing  
* 2133 = Lamb, High Quality, Hilly Grazing

replace FMFS=2111 if shengchudaxiao==21&siweizhiliang==1&fangmufs==1
replace FMFS=2112 if shengchudaxiao==21&siweizhiliang==1&fangmufs==2
replace FMFS=2113 if shengchudaxiao==21&siweizhiliang==1&fangmufs==3
replace FMFS=2121 if shengchudaxiao==21&siweizhiliang==2&fangmufs==1
replace FMFS=2122 if shengchudaxiao==21&siweizhiliang==2&fangmufs==2
replace FMFS=2123 if shengchudaxiao==21&siweizhiliang==2&fangmufs==3
replace FMFS=2131 if shengchudaxiao==21&siweizhiliang==3&fangmufs==1
replace FMFS=2132 if shengchudaxiao==21&siweizhiliang==3&fangmufs==2
replace FMFS=2133 if shengchudaxiao==21&siweizhiliang==3&fangmufs==3


* 2211 = Adult Sheep, Low Quality, Stall-feeding  
* 2212 = Adult Sheep, Low Quality, Plain Grazing  
* 2213 = Adult Sheep, Low Quality, Hilly Grazing  
* 2221 = Adult Sheep, Medium Quality, Stall-feeding  
* 2222 = Adult Sheep, Medium Quality, Plain Grazing  
* 2223 = Adult Sheep, Medium Quality, Hilly Grazing  
* 2231 = Adult Sheep, High Quality, Stall-feeding  
* 2232 = Adult Sheep, High Quality, Plain Grazing  
* 2233 = Adult Sheep, High Quality, Hilly Grazing

replace FMFS=2211 if shengchudaxiao==22&siweizhiliang==1&fangmufs==1
replace FMFS=2212 if shengchudaxiao==22&siweizhiliang==1&fangmufs==2
replace FMFS=2213 if shengchudaxiao==22&siweizhiliang==1&fangmufs==3
replace FMFS=2221 if shengchudaxiao==22&siweizhiliang==2&fangmufs==1
replace FMFS=2222 if shengchudaxiao==22&siweizhiliang==2&fangmufs==2
replace FMFS=2223 if shengchudaxiao==22&siweizhiliang==2&fangmufs==3
replace FMFS=2231 if shengchudaxiao==22&siweizhiliang==3&fangmufs==1
replace FMFS=2232 if shengchudaxiao==22&siweizhiliang==3&fangmufs==2
replace FMFS=2233 if shengchudaxiao==22&siweizhiliang==3&fangmufs==3


bysort FMFS:egen EF1cd_mean5=mean(EFcd)
bysort FMFS:egen EF1fb_mean5=mean(EFfb)
bysort FMFS:egen EF1_N2O_mean5=mean(EF_N2O)

bys FMFS:sum EFcd EFfb  EF_N2O


*(2) Grassland Type  
* 11 = Calf  
* 12 = Adult Cattle  
* 21 = Lamb  
* 22 = Adult Sheep  
* 1 = Low Quality  2 = Medium Quality  3 = High Quality  
* 1 = Desert Steppe  2 = Typical Steppe  3 = Meadow Steppe  

* 1111 = Calf, Low Quality, Desert Steppe  
* 1112 = Calf, Low Quality, Typical Steppe  
* 1113 = Calf, Low Quality, Meadow Steppe  
* 1121 = Calf, Medium Quality, Desert Steppe  
* 1122 = Calf, Medium Quality, Typical Steppe  
* 1123 = Calf, Medium Quality, Meadow Steppe  
* 1131 = Calf, High Quality, Desert Steppe  
* 1132 = Calf, High Quality, Typical Steppe  
* 1133 = Calf, High Quality, Meadow Steppe

replace CDLX=1111 if shengchudaxiao==11&siweizhiliang==1&county==1
replace CDLX=1112 if shengchudaxiao==11&siweizhiliang==1&county==2
replace CDLX=1113 if shengchudaxiao==11&siweizhiliang==1&county==3
replace CDLX=1121 if shengchudaxiao==11&siweizhiliang==2&county==1
replace CDLX=1122 if shengchudaxiao==11&siweizhiliang==2&county==2
replace CDLX=1123 if shengchudaxiao==11&siweizhiliang==2&county==3
replace CDLX=1131 if shengchudaxiao==11&siweizhiliang==3&county==1
replace CDLX=1132 if shengchudaxiao==11&siweizhiliang==3&county==2
replace CDLX=1133 if shengchudaxiao==11&siweizhiliang==3&county==3

* 1211 = Adult Cattle, Low Quality, Desert Steppe  
* 1212 = Adult Cattle, Low Quality, Typical Steppe  
* 1213 = Adult Cattle, Low Quality, Meadow Steppe  
* 1221 = Adult Cattle, Medium Quality, Desert Steppe  
* 1222 = Adult Cattle, Medium Quality, Typical Steppe  
* 1223 = Adult Cattle, Medium Quality, Meadow Steppe  
* 1231 = Adult Cattle, High Quality, Desert Steppe  
* 1232 = Adult Cattle, High Quality, Typical Steppe  
* 1233 = Adult Cattle, High Quality, Meadow Steppe

replace CDLX=1211 if shengchudaxiao==12&siweizhiliang==1&county==1
replace CDLX=1212 if shengchudaxiao==12&siweizhiliang==1&county==2
replace CDLX=1213 if shengchudaxiao==12&siweizhiliang==1&county==3
replace CDLX=1221 if shengchudaxiao==12&siweizhiliang==2&county==1
replace CDLX=1222 if shengchudaxiao==12&siweizhiliang==2&county==2
replace CDLX=1223 if shengchudaxiao==12&siweizhiliang==2&county==3
replace CDLX=1231 if shengchudaxiao==12&siweizhiliang==3&county==1
replace CDLX=1232 if shengchudaxiao==12&siweizhiliang==3&county==2
replace CDLX=1233 if shengchudaxiao==12&siweizhiliang==3&county==3

* 2111 = Lamb, Low Quality, Desert Steppe  
* 2112 = Lamb, Low Quality, Typical Steppe  
* 2113 = Lamb, Low Quality, Meadow Steppe  
* 2121 = Lamb, Medium Quality, Desert Steppe  
* 2122 = Lamb, Medium Quality, Typical Steppe  
* 2123 = Lamb, Medium Quality, Meadow Steppe  
* 2131 = Lamb, High Quality, Desert Steppe  
* 2132 = Lamb, High Quality, Typical Steppe  
* 2133 = Lamb, High Quality, Meadow Steppe

replace CDLX=2111 if shengchudaxiao==21&siweizhiliang==1&county==1
replace CDLX=2112 if shengchudaxiao==21&siweizhiliang==1&county==2
replace CDLX=2113 if shengchudaxiao==21&siweizhiliang==1&county==3
replace CDLX=2121 if shengchudaxiao==21&siweizhiliang==2&county==1
replace CDLX=2122 if shengchudaxiao==21&siweizhiliang==2&county==2
replace CDLX=2123 if shengchudaxiao==21&siweizhiliang==2&county==3
replace CDLX=2131 if shengchudaxiao==21&siweizhiliang==3&county==1
replace CDLX=2132 if shengchudaxiao==21&siweizhiliang==3&county==2
replace CDLX=2133 if shengchudaxiao==21&siweizhiliang==3&county==3

* 2211 = Adult Sheep, Low Quality, Desert Steppe  
* 2212 = Adult Sheep, Low Quality, Typical Steppe  
* 2213 = Adult Sheep, Low Quality, Meadow Steppe  
* 2221 = Adult Sheep, Medium Quality, Desert Steppe  
* 2222 = Adult Sheep, Medium Quality, Typical Steppe  
* 2223 = Adult Sheep, Medium Quality, Meadow Steppe  
* 2231 = Adult Sheep, High Quality, Desert Steppe  
* 2232 = Adult Sheep, High Quality, Typical Steppe  
* 2233 = Adult Sheep, High Quality, Meadow Steppe

replace CDLX=2211 if shengchudaxiao==22&siweizhiliang==1&county==1
replace CDLX=2212 if shengchudaxiao==22&siweizhiliang==1&county==2
replace CDLX=2213 if shengchudaxiao==22&siweizhiliang==1&county==3
replace CDLX=2221 if shengchudaxiao==22&siweizhiliang==2&county==1
replace CDLX=2222 if shengchudaxiao==22&siweizhiliang==2&county==2
replace CDLX=2223 if shengchudaxiao==22&siweizhiliang==2&county==3
replace CDLX=2231 if shengchudaxiao==22&siweizhiliang==3&county==1
replace CDLX=2232 if shengchudaxiao==22&siweizhiliang==3&county==2
replace CDLX=2233 if shengchudaxiao==22&siweizhiliang==3&county==3


bysort CDLX:egen EF1cd_mean6=mean(EFcd)
bysort CDLX:egen EF1fb_mean6=mean(EFfb)
bysort CDLX:egen EF1_N2O_mean6=mean(EF_N2O)

bys CDLX:sum EFcd EFfb  EF_N2O

***Three-dimensional***

***Four-dimensional***
* 1 = Desert Steppe  2 = Typical Steppe  3 = Meadow Steppe  
* 11 = Calf  12 = Adult Cattle  21 = Lamb  22 = Adult Sheep  
* 1 = Low Quality  2 = Medium Quality  3 = High Quality  
* 1 = Stall-feeding  2 = Plain Grazing  3 = Hilly Grazing  

*(1) Grazing Methods under Desert Steppe  
* 11111 = Desert Steppe, Calf, Low Quality, Stall-feeding  
* 11112 = Desert Steppe, Calf, Low Quality, Plain Grazing  
* 11113 = Desert Steppe, Calf, Low Quality, Hilly Grazing  
* 11121 = Desert Steppe, Calf, Medium Quality, Stall-feeding  
* 11122 = Desert Steppe, Calf, Medium Quality, Plain Grazing  
* 11123 = Desert Steppe, Calf, Medium Quality, Hilly Grazing  
* 11131 = Desert Steppe, Calf, High Quality, Stall-feeding  
* 11132 = Desert Steppe, Calf, High Quality, Plain Grazing  
* 11133 = Desert Steppe, Calf, High Quality, Hilly Grazing

replace caoyuan_FMFS=11111 if county==1 & FMFS==1111
replace caoyuan_FMFS=11112 if county==1 & FMFS==1112
replace caoyuan_FMFS=11113 if county==1 & FMFS==1113
replace caoyuan_FMFS=11121 if county==1 & FMFS==1121
replace caoyuan_FMFS=11122 if county==1 & FMFS==1122
replace caoyuan_FMFS=11123 if county==1 & FMFS==1123
replace caoyuan_FMFS=11131 if county==1 & FMFS==1131
replace caoyuan_FMFS=11132 if county==1 & FMFS==1132
replace caoyuan_FMFS=11133 if county==1 & FMFS==1133

* 11211 = Desert Steppe, Adult Cattle, Low Quality, Stall-feeding  
* 11212 = Desert Steppe, Adult Cattle, Low Quality, Plain Grazing  
* 11213 = Desert Steppe, Adult Cattle, Low Quality, Hilly Grazing  
* 11221 = Desert Steppe, Adult Cattle, Medium Quality, Stall-feeding  
* 11222 = Desert Steppe, Adult Cattle, Medium Quality, Plain Grazing  
* 11223 = Desert Steppe, Adult Cattle, Medium Quality, Hilly Grazing  
* 11231 = Desert Steppe, Adult Cattle, High Quality, Stall-feeding  
* 11232 = Desert Steppe, Adult Cattle, High Quality, Plain Grazing  
* 11233 = Desert Steppe, Adult Cattle, High Quality, Hilly Grazing

replace caoyuan_FMFS=11211 if county==1 & FMFS==1211
replace caoyuan_FMFS=11212 if county==1 & FMFS==1212
replace caoyuan_FMFS=11213 if county==1 & FMFS==1213
replace caoyuan_FMFS=11221 if county==1 & FMFS==1221
replace caoyuan_FMFS=11222 if county==1 & FMFS==1222
replace caoyuan_FMFS=11223 if county==1 & FMFS==1223
replace caoyuan_FMFS=11231 if county==1 & FMFS==1231
replace caoyuan_FMFS=11232 if county==1 & FMFS==1232
replace caoyuan_FMFS=11233 if county==1 & FMFS==1233

* 12111 = Desert Steppe, Lamb, Low Quality, Stall-feeding  
* 12112 = Desert Steppe, Lamb, Low Quality, Plain Grazing  
* 12113 = Desert Steppe, Lamb, Low Quality, Hilly Grazing  
* 12121 = Desert Steppe, Lamb, Medium Quality, Stall-feeding  
* 12122 = Desert Steppe, Lamb, Medium Quality, Plain Grazing  
* 12123 = Desert Steppe, Lamb, Medium Quality, Hilly Grazing  
* 12131 = Desert Steppe, Lamb, High Quality, Stall-feeding  
* 12132 = Desert Steppe, Lamb, High Quality, Plain Grazing  
* 12133 = Desert Steppe, Lamb, High Quality, Hilly Grazing

replace caoyuan_FMFS=12111 if county==1 & FMFS==2111
replace caoyuan_FMFS=12112 if county==1 & FMFS==2112
replace caoyuan_FMFS=12113 if county==1 & FMFS==2113
replace caoyuan_FMFS=12121 if county==1 & FMFS==2121
replace caoyuan_FMFS=12122 if county==1 & FMFS==2122
replace caoyuan_FMFS=12123 if county==1 & FMFS==2123
replace caoyuan_FMFS=12131 if county==1 & FMFS==2131
replace caoyuan_FMFS=12132 if county==1 & FMFS==2132
replace caoyuan_FMFS=12133 if county==1 & FMFS==2133


* 12211 = Desert Steppe, Adult Sheep, Low Quality, Stall-feeding  
* 12212 = Desert Steppe, Adult Sheep, Low Quality, Plain Grazing  
* 12213 = Desert Steppe, Adult Sheep, Low Quality, Hilly Grazing  
* 12221 = Desert Steppe, Adult Sheep, Medium Quality, Stall-feeding  
* 12222 = Desert Steppe, Adult Sheep, Medium Quality, Plain Grazing  
* 12223 = Desert Steppe, Adult Sheep, Medium Quality, Hilly Grazing  
* 12231 = Desert Steppe, Adult Sheep, High Quality, Stall-feeding  
* 12232 = Desert Steppe, Adult Sheep, High Quality, Plain Grazing  
* 12233 = Desert Steppe, Adult Sheep, High Quality, Hilly Grazing

replace caoyuan_FMFS=12211 if county==1 & FMFS==2211
replace caoyuan_FMFS=12212 if county==1 & FMFS==2212
replace caoyuan_FMFS=12213 if county==1 & FMFS==2213
replace caoyuan_FMFS=12221 if county==1 & FMFS==2221
replace caoyuan_FMFS=12222 if county==1 & FMFS==2222
replace caoyuan_FMFS=12223 if county==1 & FMFS==2223
replace caoyuan_FMFS=12231 if county==1 & FMFS==2231
replace caoyuan_FMFS=12232 if county==1 & FMFS==2232
replace caoyuan_FMFS=12233 if county==1 & FMFS==2233



*(2) Grazing Methods under Typical Steppe  
* 21111 = Typical Steppe, Calf, Low Quality, Stall-feeding  
* 21112 = Typical Steppe, Calf, Low Quality, Plain Grazing  
* 21113 = Typical Steppe, Calf, Low Quality, Hilly Grazing  
* 21121 = Typical Steppe, Calf, Medium Quality, Stall-feeding  
* 21122 = Typical Steppe, Calf, Medium Quality, Plain Grazing  
* 21123 = Typical Steppe, Calf, Medium Quality, Hilly Grazing  
* 21131 = Typical Steppe, Calf, High Quality, Stall-feeding  
* 21132 = Typical Steppe, Calf, High Quality, Plain Grazing  
* 21133 = Typical Steppe, Calf, High Quality, Hilly Grazing

replace caoyuan_FMFS=21111 if county==2 & FMFS==1111
replace caoyuan_FMFS=21112 if county==2 & FMFS==1112
replace caoyuan_FMFS=21113 if county==2 & FMFS==1113
replace caoyuan_FMFS=21121 if county==2 & FMFS==1121
replace caoyuan_FMFS=21122 if county==2 & FMFS==1122
replace caoyuan_FMFS=21123 if county==2 & FMFS==1123
replace caoyuan_FMFS=21131 if county==2 & FMFS==1131
replace caoyuan_FMFS=21132 if county==2 & FMFS==1132
replace caoyuan_FMFS=21133 if county==2 & FMFS==1133

* 21211 = Typical Steppe, Adult Cattle, Low Quality, Stall-feeding  
* 21212 = Typical Steppe, Adult Cattle, Low Quality, Plain Grazing  
* 21213 = Typical Steppe, Adult Cattle, Low Quality, Hilly Grazing  
* 21221 = Typical Steppe, Adult Cattle, Medium Quality, Stall-feeding  
* 21222 = Typical Steppe, Adult Cattle, Medium Quality, Plain Grazing  
* 21223 = Typical Steppe, Adult Cattle, Medium Quality, Hilly Grazing  
* 21231 = Typical Steppe, Adult Cattle, High Quality, Stall-feeding  
* 21232 = Typical Steppe, Adult Cattle, High Quality, Plain Grazing  
* 21233 = Typical Steppe, Adult Cattle, High Quality, Hilly Grazing

replace caoyuan_FMFS=21211 if county==2 & FMFS==1211
replace caoyuan_FMFS=21212 if county==2 & FMFS==1212
replace caoyuan_FMFS=21213 if county==2 & FMFS==1213
replace caoyuan_FMFS=21221 if county==2 & FMFS==1221
replace caoyuan_FMFS=21222 if county==2 & FMFS==1222
replace caoyuan_FMFS=21223 if county==2 & FMFS==1223
replace caoyuan_FMFS=21231 if county==2 & FMFS==1231
replace caoyuan_FMFS=21232 if county==2 & FMFS==1232
replace caoyuan_FMFS=21233 if county==2 & FMFS==1233

* 22111 = Typical Steppe, Lamb, Low Quality, Stall-feeding  
* 22112 = Typical Steppe, Lamb, Low Quality, Plain Grazing  
* 22113 = Typical Steppe, Lamb, Low Quality, Hilly Grazing  
* 22121 = Typical Steppe, Lamb, Medium Quality, Stall-feeding  
* 22122 = Typical Steppe, Lamb, Medium Quality, Plain Grazing  
* 22123 = Typical Steppe, Lamb, Medium Quality, Hilly Grazing  
* 22131 = Typical Steppe, Lamb, High Quality, Stall-feeding  
* 22132 = Typical Steppe, Lamb, High Quality, Plain Grazing  
* 22133 = Typical Steppe, Lamb, High Quality, Hilly Grazing

replace caoyuan_FMFS=22111 if county==2 & FMFS==2111
replace caoyuan_FMFS=22112 if county==2 & FMFS==2112
replace caoyuan_FMFS=22113 if county==2 & FMFS==2113
replace caoyuan_FMFS=22121 if county==2 & FMFS==2121
replace caoyuan_FMFS=22122 if county==2 & FMFS==2122
replace caoyuan_FMFS=22123 if county==2 & FMFS==2123
replace caoyuan_FMFS=22131 if county==2 & FMFS==2131
replace caoyuan_FMFS=22132 if county==2 & FMFS==2132
replace caoyuan_FMFS=22133 if county==2 & FMFS==2133

* 22211 = Typical Steppe, Adult Sheep, Low Quality, Stall-feeding  
* 22212 = Typical Steppe, Adult Sheep, Low Quality, Plain Grazing  
* 22213 = Typical Steppe, Adult Sheep, Low Quality, Hilly Grazing  
* 22221 = Typical Steppe, Adult Sheep, Medium Quality, Stall-feeding  
* 22222 = Typical Steppe, Adult Sheep, Medium Quality, Plain Grazing  
* 22223 = Typical Steppe, Adult Sheep, Medium Quality, Hilly Grazing  
* 22231 = Typical Steppe, Adult Sheep, High Quality, Stall-feeding  
* 22232 = Typical Steppe, Adult Sheep, High Quality, Plain Grazing  
* 22233 = Typical Steppe, Adult Sheep, High Quality, Hilly Grazing

replace caoyuan_FMFS=22211 if county==2 & FMFS==2211
replace caoyuan_FMFS=22212 if county==2 & FMFS==2212
replace caoyuan_FMFS=22213 if county==2 & FMFS==2213
replace caoyuan_FMFS=22221 if county==2 & FMFS==2221
replace caoyuan_FMFS=22222 if county==2 & FMFS==2222
replace caoyuan_FMFS=22223 if county==2 & FMFS==2223
replace caoyuan_FMFS=22231 if county==2 & FMFS==2231
replace caoyuan_FMFS=22232 if county==2 & FMFS==2232
replace caoyuan_FMFS=22233 if county==2 & FMFS==2233


*(3) Grazing Methods under Meadow Steppe  
* 31111 = Meadow Steppe, Calf, Low Quality, Stall-feeding  
* 31112 = Meadow Steppe, Calf, Low Quality, Plain Grazing  
* 31113 = Meadow Steppe, Calf, Low Quality, Hilly Grazing  
* 31121 = Meadow Steppe, Calf, Medium Quality, Stall-feeding  
* 31122 = Meadow Steppe, Calf, Medium Quality, Plain Grazing  
* 31123 = Meadow Steppe, Calf, Medium Quality, Hilly Grazing  
* 31131 = Meadow Steppe, Calf, High Quality, Stall-feeding  
* 31132 = Meadow Steppe, Calf, High Quality, Plain Grazing  
* 31133 = Meadow Steppe, Calf, High Quality, Hilly Grazing

replace caoyuan_FMFS=31111 if county==3 & FMFS==1111
replace caoyuan_FMFS=31112 if county==3 & FMFS==1112
replace caoyuan_FMFS=31113 if county==3 & FMFS==1113
replace caoyuan_FMFS=31121 if county==3 & FMFS==1121
replace caoyuan_FMFS=31122 if county==3 & FMFS==1122
replace caoyuan_FMFS=31123 if county==3 & FMFS==1123
replace caoyuan_FMFS=31131 if county==3 & FMFS==1131
replace caoyuan_FMFS=31132 if county==3 & FMFS==1132
replace caoyuan_FMFS=31133 if county==3 & FMFS==1133

* 31211 = Meadow Steppe, Adult Cattle, Low Quality, Stall-feeding  
* 31212 = Meadow Steppe, Adult Cattle, Low Quality, Plain Grazing  
* 31213 = Meadow Steppe, Adult Cattle, Low Quality, Hilly Grazing  
* 31221 = Meadow Steppe, Adult Cattle, Medium Quality, Stall-feeding  
* 31222 = Meadow Steppe, Adult Cattle, Medium Quality, Plain Grazing  
* 31223 = Meadow Steppe, Adult Cattle, Medium Quality, Hilly Grazing  
* 31231 = Meadow Steppe, Adult Cattle, High Quality, Stall-feeding  
* 31232 = Meadow Steppe, Adult Cattle, High Quality, Plain Grazing  
* 31233 = Meadow Steppe, Adult Cattle, High Quality, Hilly Grazing

replace caoyuan_FMFS=31211 if county==3 & FMFS==1211
replace caoyuan_FMFS=31212 if county==3 & FMFS==1212
replace caoyuan_FMFS=31213 if county==3 & FMFS==1213
replace caoyuan_FMFS=31221 if county==3 & FMFS==1221
replace caoyuan_FMFS=31222 if county==3 & FMFS==1222
replace caoyuan_FMFS=31223 if county==3 & FMFS==1223
replace caoyuan_FMFS=31231 if county==3 & FMFS==1231
replace caoyuan_FMFS=31232 if county==3 & FMFS==1232
replace caoyuan_FMFS=31233 if county==3 & FMFS==1233

* 32111 = Meadow Steppe, Lamb, Low Quality, Stall-feeding  
* 32112 = Meadow Steppe, Lamb, Low Quality, Plain Grazing  
* 32113 = Meadow Steppe, Lamb, Low Quality, Hilly Grazing  
* 32121 = Meadow Steppe, Lamb, Medium Quality, Stall-feeding  
* 32122 = Meadow Steppe, Lamb, Medium Quality, Plain Grazing  
* 32123 = Meadow Steppe, Lamb, Medium Quality, Hilly Grazing  
* 32131 = Meadow Steppe, Lamb, High Quality, Stall-feeding  
* 32132 = Meadow Steppe, Lamb, High Quality, Plain Grazing  
* 32133 = Meadow Steppe, Lamb, High Quality, Hilly Grazing

replace caoyuan_FMFS=32111 if county==3 & FMFS==2111
replace caoyuan_FMFS=32112 if county==3 & FMFS==2112
replace caoyuan_FMFS=32113 if county==3 & FMFS==2113
replace caoyuan_FMFS=32121 if county==3 & FMFS==2121
replace caoyuan_FMFS=32122 if county==3 & FMFS==2122
replace caoyuan_FMFS=32123 if county==3 & FMFS==2123
replace caoyuan_FMFS=32131 if county==3 & FMFS==2131
replace caoyuan_FMFS=32132 if county==3 & FMFS==2132
replace caoyuan_FMFS=32133 if county==3 & FMFS==2133

* 32211 = Meadow Steppe, Adult Sheep, Low Quality, Stall-feeding  
* 32212 = Meadow Steppe, Adult Sheep, Low Quality, Plain Grazing  
* 32213 = Meadow Steppe, Adult Sheep, Low Quality, Hilly Grazing  
* 32221 = Meadow Steppe, Adult Sheep, Medium Quality, Stall-feeding  
* 32222 = Meadow Steppe, Adult Sheep, Medium Quality, Plain Grazing  
* 32223 = Meadow Steppe, Adult Sheep, Medium Quality, Hilly Grazing  
* 32231 = Meadow Steppe, Adult Sheep, High Quality, Stall-feeding  
* 32232 = Meadow Steppe, Adult Sheep, High Quality, Plain Grazing  
* 32233 = Meadow Steppe, Adult Sheep, High Quality, Hilly Grazing

replace caoyuan_FMFS=32211 if county==3 & FMFS==2211
replace caoyuan_FMFS=32212 if county==3 & FMFS==2212
replace caoyuan_FMFS=32213 if county==3 & FMFS==2213
replace caoyuan_FMFS=32221 if county==3 & FMFS==2221
replace caoyuan_FMFS=32222 if county==3 & FMFS==2222
replace caoyuan_FMFS=32223 if county==3 & FMFS==2223
replace caoyuan_FMFS=32231 if county==3 & FMFS==2231
replace caoyuan_FMFS=32232 if county==3 & FMFS==2232
replace caoyuan_FMFS=32233 if county==3 & FMFS==2233


bys caoyuan_FMFS:sum EFcd EFfb  EF_N2O


***Four-dimensional***

