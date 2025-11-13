use "F:\Desktop\Animal GHG emission factors.dta",clear


***GE***

gen Cfi=0.322*other_cattle+0.386*female_cattle+0.370*male_cattle if animal==1
replace Cfi=0.236*little_sheep+0.217*big_sheep if animal==2


gen NEm=Cfi*(animal_weight^0.75)

gen walk= ((harea*667)^0.5 )*(2^0.5)

replace fangmufs=1 if walk<=1000
replace fangmufs=2 if walk>1000 & walk<5000
replace fangmufs=3 if walk>=5000 

replace Ca11=0.0067 if animal==2 & fangmufs==1
replace Ca12=0.0107 if animal==2 & fangmufs==2
replace Ca13=0.024  if animal==2 & fangmufs==3

replace Ca21=0    if animal==1 & fangmufs==1
replace Ca22=0.17 if animal==1 & fangmufs==2
replace Ca23=0.36 if animal==1 & fangmufs==3

gen Ca=Ca11 if Ca11!=.
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

gen milk=5

replace NEl=milk*(1.47+0.4*(4/100))*renshen*(60/365)*(2/3) if animal==1  
replace NEl=0 if animal==1 & animal_weight>100 & animal_weight<=485
replace NEl=((5*12.33)/365)*4.6*renshen*(60/365) if animal==2  
replace NEl=0 if animal==2 & animal_weight<46 & animal_weight>=15

gen hours=0
gen NEwork=0.1*NEm*hours if animal==1 
replace NEwork=0 if animal==2


gen Prwool=0
gen NEwool=(24*Prwool)/365 if animal==2
replace NEwool=0 if animal==1
 
gen Cp=0.1 if animal==1
replace Cp=0.077 if animal==2

gen NEp=Cp*NEm*renshen*(280/365)*(2/3)   if animal==1
replace NEp=Cp*NEm*renshen*(150/365)  if animal==2

gen DE=75   if  animal==1
replace DE=(72+85)/2 if animal==2

gen REM=(1.123-((4.092*(10^(-3)))*DE))+((1.126*(10^(-5)))*(DE^2))-(25.4/DE) 

gen REG=(1.164-((5.16*(10^(-3)))*DE))+((1.308*(10^(-5)))*(DE^2))-(37.4/DE)

gen GE=(((NEm+NEa+NEl+NEwork+NEp)/REM)+((NEg+NEwool)/REG))/(DE/100)


***GE***

***EFcd***

gen YM=4.0 if DE==75
replace YM=5.8 if DE==(72+85)/2

gen EFcd=(GE*(YM/100)*365)/55.65

***EFcd***


***EFfb***


gen VS=((GE*(1-(DE/100)))+(0.04*GE))*((1-0.06)/18.45)

gen B0=0.18 if animal==1
replace B0=0.19 if animal==2

gen EFfb=VS*365*(B0*0.67*((2/100)*0.06+(1/100)*0.64+(0.47/100)*0.28+(10/100)*0.02))  if animal==1
replace EFfb=VS*365*(B0*0.67*((2/100)*0.17+(1/100)*0.03+(0.47/100)*0.8)) if animal==2

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

***EF_N2O***

*** Two-dimensional***

*Feeding Quality — High Quality
bysort animal:egen EFcd_mean=mean(EFcd)
bysort animal:egen EFfb_mean=mean(EFfb)
bysort animal:egen EF_N2O_mean=mean(EF_N2O)

tab EFcd_mean,m
tab EFfb_mean,m
tab EF_N2O_mean,m

*** Two-dimensional***


***Three-dimensional***
*（1）Grazing Method — High Quality

gen shengchudaxiao=11 if animal==1 & animal_weight<485
replace shengchudaxiao=12 if animal==1 & animal_weight>=485
replace shengchudaxiao=21 if animal==2 & animal_weight<46
replace shengchudaxiao=22 if animal==2 & animal_weight>=46

gen FMFS=111 if shengchudaxiao==11&fangmufs==1
replace FMFS=112 if shengchudaxiao==11&fangmufs==2
replace FMFS=113 if shengchudaxiao==11&fangmufs==3
replace FMFS=121 if shengchudaxiao==12&fangmufs==1
replace FMFS=122 if shengchudaxiao==12&fangmufs==2
replace FMFS=123 if shengchudaxiao==12&fangmufs==3
replace FMFS=211 if shengchudaxiao==21&fangmufs==1
replace FMFS=212 if shengchudaxiao==21&fangmufs==2
replace FMFS=213 if shengchudaxiao==21&fangmufs==3
replace FMFS=221 if shengchudaxiao==22&fangmufs==1
replace FMFS=222 if shengchudaxiao==22&fangmufs==2
replace FMFS=223 if shengchudaxiao==22&fangmufs==3

bysort FMFS:egen EFcd_mean5=mean(EFcd)
bysort FMFS:egen EFfb_mean5=mean(EFfb)
bysort FMFS:egen EF_N2O_mean5=mean(EF_N2O)

tab FMFS EFcd_mean5,m
tab FMFS EFfb_mean5,m
tab FMFS EF_N2O_mean5,m

* Grassland Type — High Quality
replace county=3 if county==4
gen CDLX=111 if shengchudaxiao==11&county==1
replace CDLX=112 if shengchudaxiao==11&county==2
replace CDLX=113 if shengchudaxiao==11&county==3
replace CDLX=121 if shengchudaxiao==12&county==1
replace CDLX=122 if shengchudaxiao==12&county==2
replace CDLX=123 if shengchudaxiao==12&county==3
replace CDLX=211 if shengchudaxiao==21&county==1
replace CDLX=212 if shengchudaxiao==21&county==2
replace CDLX=213 if shengchudaxiao==21&county==3
replace CDLX=221 if shengchudaxiao==22&county==1
replace CDLX=222 if shengchudaxiao==22&county==2
replace CDLX=223 if shengchudaxiao==22&county==3

bysort CDLX:egen EFcd_mean6=mean(EFcd)
bysort CDLX:egen EFfb_mean6=mean(EFfb)
bysort CDLX:egen EF_N2O_mean6=mean(EF_N2O)

tab CDLX EFcd_mean6,m
tab CDLX EFfb_mean6,m
tab CDLX EF_N2O_mean6,m

***Three-dimensional***


***Four-dimensional***
* 1 = Desert Steppe  2 = Typical Steppe  3 = Meadow Steppe  
* 11 = Calf  12 = Adult Cattle  21 = Lamb  22 = Adult Sheep  
* 1 = Stall-feeding  2 = Plain Grazing  3 = Hilly Grazing  

*(1) Grazing Methods under Desert Steppe  
* 1111 = Desert Steppe, Calf, High Quality, Stall-feeding  
* 1112 = Desert Steppe, Calf, High Quality, Plain Grazing  
* 1113 = Desert Steppe, Calf, High Quality, Hilly Grazing  
* 1121 = Desert Steppe, Adult Cattle, High Quality, Stall-feeding  
* 1122 = Desert Steppe, Adult Cattle, High Quality, Plain Grazing  
* 1123 = Desert Steppe, Adult Cattle, High Quality, Hilly Grazing  
* 1211 = Desert Steppe, Lamb, High Quality, Stall-feeding  
* 1212 = Desert Steppe, Lamb, High Quality, Plain Grazing  
* 1213 = Desert Steppe, Lamb, High Quality, Hilly Grazing  
* 1221 = Desert Steppe, Adult Sheep, High Quality, Stall-feeding  
* 1222 = Desert Steppe, Adult Sheep, High Quality, Plain Grazing  
* 1223 = Desert Steppe, Adult Sheep, High Quality, Hilly Grazing

gen caoyuan_FMFS=1111 if county==1 & FMFS==111
replace caoyuan_FMFS=1112 if county==1 & FMFS==112
replace caoyuan_FMFS=1113 if county==1 & FMFS==113
replace caoyuan_FMFS=1121 if county==1 & FMFS==121
replace caoyuan_FMFS=1122 if county==1 & FMFS==122
replace caoyuan_FMFS=1123 if county==1 & FMFS==123
replace caoyuan_FMFS=1211 if county==1 & FMFS==211
replace caoyuan_FMFS=1212 if county==1 & FMFS==212
replace caoyuan_FMFS=1213 if county==1 & FMFS==213
replace caoyuan_FMFS=1221 if county==1 & FMFS==221
replace caoyuan_FMFS=1222 if county==1 & FMFS==222
replace caoyuan_FMFS=1223 if county==1 & FMFS==223

*(2) Grazing Methods under Typical Steppe  
* 2111 = Typical Steppe, Calf, High Quality, Stall-feeding  
* 2112 = Typical Steppe, Calf, High Quality, Plain Grazing  
* 2113 = Typical Steppe, Calf, High Quality, Hilly Grazing  
* 2121 = Typical Steppe, Adult Cattle, High Quality, Stall-feeding  
* 2122 = Typical Steppe, Adult Cattle, High Quality, Plain Grazing  
* 2123 = Typical Steppe, Adult Cattle, High Quality, Hilly Grazing  
* 2211 = Typical Steppe, Lamb, High Quality, Stall-feeding  
* 2212 = Typical Steppe, Lamb, High Quality, Plain Grazing  
* 2213 = Typical Steppe, Lamb, High Quality, Hilly Grazing  
* 2221 = Typical Steppe, Adult Sheep, High Quality, Stall-feeding  
* 2222 = Typical Steppe, Adult Sheep, High Quality, Plain Grazing  
* 2223 = Typical Steppe, Adult Sheep, High Quality, Hilly Grazing

replace caoyuan_FMFS=2111 if county==2 & FMFS==111
replace caoyuan_FMFS=2112 if county==2 & FMFS==112
replace caoyuan_FMFS=2113 if county==2 & FMFS==113
replace caoyuan_FMFS=2121 if county==2 & FMFS==121
replace caoyuan_FMFS=2122 if county==2 & FMFS==122
replace caoyuan_FMFS=2123 if county==2 & FMFS==123
replace caoyuan_FMFS=2211 if county==2 & FMFS==211
replace caoyuan_FMFS=2212 if county==2 & FMFS==212
replace caoyuan_FMFS=2213 if county==2 & FMFS==213
replace caoyuan_FMFS=2221 if county==2 & FMFS==221
replace caoyuan_FMFS=2222 if county==2 & FMFS==222
replace caoyuan_FMFS=2223 if county==2 & FMFS==223



*(3) Grazing Methods under Meadow Steppe  
* 3111 = Meadow Steppe, Calf, High Quality, Stall-feeding  
* 3112 = Meadow Steppe, Calf, High Quality, Plain Grazing  
* 3113 = Meadow Steppe, Calf, High Quality, Hilly Grazing  
* 3121 = Meadow Steppe, Adult Cattle, High Quality, Stall-feeding  
* 3122 = Meadow Steppe, Adult Cattle, High Quality, Plain Grazing  
* 3123 = Meadow Steppe, Adult Cattle, High Quality, Hilly Grazing  
* 3211 = Meadow Steppe, Lamb, High Quality, Stall-feeding  
* 3212 = Meadow Steppe, Lamb, High Quality, Plain Grazing  
* 3213 = Meadow Steppe, Lamb, High Quality, Hilly Grazing  
* 3221 = Meadow Steppe, Adult Sheep, High Quality, Stall-feeding  
* 3222 = Meadow Steppe, Adult Sheep, High Quality, Plain Grazing  
* 3223 = Meadow Steppe, Adult Sheep, High Quality, Hilly Grazing

replace caoyuan_FMFS=3111 if county==3 & FMFS==111
replace caoyuan_FMFS=3112 if county==3 & FMFS==112
replace caoyuan_FMFS=3113 if county==3 & FMFS==113
replace caoyuan_FMFS=3121 if county==3 & FMFS==121
replace caoyuan_FMFS=3122 if county==3 & FMFS==122
replace caoyuan_FMFS=3123 if county==3 & FMFS==123
replace caoyuan_FMFS=3211 if county==3 & FMFS==211
replace caoyuan_FMFS=3212 if county==3 & FMFS==212
replace caoyuan_FMFS=3213 if county==3 & FMFS==213
replace caoyuan_FMFS=3221 if county==3 & FMFS==221
replace caoyuan_FMFS=3222 if county==3 & FMFS==222
replace caoyuan_FMFS=3223 if county==3 & FMFS==223


bysort caoyuan_FMFS:egen EFcd_mean7=mean(EFcd)
bysort caoyuan_FMFS:egen EFfb_mean7=mean(EFfb)
bysort caoyuan_FMFS:egen EF_N2O_mean7=mean(EF_N2O)

tab EFcd_mean7,m
tab EFfb_mean7,m
tab EF_N2O_mean7,m


***Four-dimensional***



