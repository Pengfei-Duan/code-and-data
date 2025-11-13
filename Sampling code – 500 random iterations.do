* ==========================================
* Multivariate grouped sampling
* ==========================================

clear all
set seed 12345

clear
set more off
  global PP   "F:\小论文文章\未结束\无人机\自己\文章抽样\stata"  
  global o "$PP\out"
  global D    "$PP\dta_cln" 
  global R    "$PP\dta_raw"      
  cd "$R"
***************************************************

* 导入数据
use "$D\高质量喂养.dta", clear



*111 Calf in Pen  
*211 Calf Grazing on Plain  
*311 Calf Grazing in Mountain  

*112 Adult Cattle in Pen  
*212 Adult Cattle Grazing on Plain  
*312 Adult Cattle Grazing in Mountain  

*121 Lamb in Pen  
*221 Lamb Grazing on Plain  
*321 Lamb Grazing in Mountain  

*122 Adult Sheep in Pen  
*222 Adult Sheep Grazing on Plain  
*322 Adult Sheep Grazing in Mountain

gen Afangmufs=111 if  fangmufs==1 & shengchudaxiao==11
replace Afangmufs=211 if  fangmufs==2 & shengchudaxiao==11
replace Afangmufs=311 if  fangmufs==3 & shengchudaxiao==11

replace Afangmufs=112 if  fangmufs==1 & shengchudaxiao==12
replace Afangmufs=212 if  fangmufs==2 & shengchudaxiao==12
replace Afangmufs=312 if  fangmufs==3 & shengchudaxiao==12

replace Afangmufs=121 if  fangmufs==1 & shengchudaxiao==21
replace Afangmufs=221 if  fangmufs==2 & shengchudaxiao==21
replace Afangmufs=321 if  fangmufs==3 & shengchudaxiao==21

replace Afangmufs=122 if  fangmufs==1 & shengchudaxiao==22
replace Afangmufs=222 if  fangmufs==2 & shengchudaxiao==22
replace Afangmufs=322 if  fangmufs==3 & shengchudaxiao==22

keep if county==1 & animal==1
*keep if county==1 & animal==2
*keep if county==2 & animal==1
*keep if county==2 & animal==2
*keep if county==3 & animal==1
*keep if county==3 & animal==2


* =====Set parameters =====
local varlist "EFcd EFfb EF_N2O"
local groupvar "Afangmufs "
local nreps 500
local n 30


tempfile original_data
save `original_data', replace


levelsof `groupvar', local(groups)
local ngroups : word count `groups'



local nvars : word count `varlist'



foreach var of local varlist {
    matrix means_`var' = J(`nreps', `ngroups', .)
    matrix colnames means_`var' = `groups'
  
}

* ===== Start sampling loop =====


quietly {
    forvalues i = 1/`nreps' {
        use `original_data', clear
        
       
        sample `n'
        
  
        foreach var of local varlist {
            local col = 1
            foreach g of local groups {
            
                summarize `var' if `groupvar' == `g'
                if r(N) > 0 {
                    matrix means_`var'[`i', `col'] = r(mean)
                }
                else {
                    matrix means_`var'[`i', `col'] = .
                }
                local col = `col' + 1
            }
        }
        
     
        if mod(`i', 100) == 0 {
            noisily display "已完成 `i'/`nreps' 次抽样"
        }
    }
}

display "finished"

* =====results=====


clear
set obs `nreps'
gen iteration = _n

* 为每个变量和每个组创建变量
local var_num = 1
foreach var of local varlist {
    display "正在处理变量: `var'"
    
    * 提取矩阵数据
    local col = 1
    foreach g of local groups {
        gen `var'_group`g' = .
        
        forvalues i = 1/`nreps' {
            quietly replace `var'_group`g' = means_`var'[`i', `col'] in `i'
        }
        
        label variable `var'_group`g' "`var'在组`g'的均值"
        local col = `col' + 1
    }
    
    local var_num = `var_num' + 1
}

* 重新排序变量
order iteration
sum *









