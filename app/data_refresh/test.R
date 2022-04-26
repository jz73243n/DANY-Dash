# test.R looks at the main RDS files for each dashboard and checks for NULLs in  
# columns that later get filtered when the application is running. It is helpful 
# to run this after you refresh the data to make sure any changes that have been 
# made to the SQL code are ok.


# calculate null sum per column
arr_null_sum <- unlist(lapply(arr,function(x) sum(is.na(x)))) 
arc_null_sum <- unlist(lapply(arc, function(x) sum(is.na(x))))
dispo_null_sum <- unlist(lapply(dispos, function(x) sum(is.na(x))))
sen_null_sum <- unlist(lapply(sentences, function(x) sum(is.na(x))))
fines_null_sum <- unlist(lapply(fines, function(x) sum(is.na(x))))
coh_null_sum <- unlist(lapply(cohort, function(x) sum(is.na(x))))

# check number of NULLs in each later-filtered arrests column
arr_null_sum["firstEvtYear"]
arr_null_sum["arrestType"]
arr_null_sum["screenOutcome"]
arr_null_sum["arrestTopCat"]
arr_null_sum["arrestTopMg"]
arr_null_sum["ageAtOffGrp"]
arr_null_sum["priorFelConv"]
arr_null_sum["priorFelConvGrp"]
arr_null_sum["priorMisdConvGrp"]
arr_null_sum["yrSinceLastConvGrp"]
arr_null_sum["arrestLocation"]

# check arraignments
arc_null_sum["arcYear"]
arc_null_sum["scrTopCat"]
arc_null_sum["scrTopCat2"]
arc_null_sum["scrTopMg"]
arc_null_sum["releaseStatusCond"]
arc_null_sum["gender"]
arc_null_sum["race"]
arc_null_sum["ageAtOffGrp"]
arc_null_sum["priorFelConvGrp"]
arc_null_sum["priorMisdConvGrp"]
arc_null_sum["yrSinceLastConvGrp"]
arc_null_sum["arrestLocation"]

# check dispositions
dispo_null_sum["dispoYear"]
dispo_null_sum["isArcDispo"]
dispo_null_sum["instTopCat"]
dispo_null_sum["instTopCat2"]
dispo_null_sum["instTopMg"]
dispo_null_sum["dispoType"]
dispo_null_sum["gender"]
dispo_null_sum["race"]
dispo_null_sum["ageAtOffGrp"]
dispo_null_sum["priorFelConvGrp"]
dispo_null_sum["priorMisdConvGrp"]
dispo_null_sum["yrSinceLastConvGrp"]
dispo_null_sum["arrestLocation"]

# check sentences
#there will usually be one null here
sen_null_sum["sentenceYear"]
sen_null_sum["senTopCat"]
sen_null_sum["senTopCat2"]
sen_null_sum["senTopMg"]
sen_null_sum["sentenceClean"]
sen_null_sum["race"]
sen_null_sum["gender"]
sen_null_sum["ageAtOffGrp"]
sen_null_sum["priorFelConvGrp"]
sen_null_sum["priorMisdConvGrp"]
sen_null_sum["yrSinceLastConvGrp"]
sen_null_sum["arrestLocation"]

# check fines
fines_null_sum["sentenceYear"]
fines_null_sum["senFineCat"]
fines_null_sum["senFineCat2"]
fines_null_sum["senFineMg"]
fines_null_sum["sentenceClean"]
fines_null_sum["race"]
fines_null_sum["gender"]
fines_null_sum["ageAtOffGrp"]
fines_null_sum["priorFelConvGrp"]
fines_null_sum["priorMisdConvGrp"]
fines_null_sum["yrSinceLastConvGrp"]
fines_null_sum["arrestLocation"]

# check cohort
coh_null_sum["cohort"]
coh_null_sum["instTopCat"]
coh_null_sum["instTopCat2"]
coh_null_sum["instTopMg"]
coh_null_sum["race"]
coh_null_sum["gender"]
coh_null_sum["ageAtOffGrp"]
coh_null_sum["priorFelConvGrp"]
coh_null_sum["priorMisdConvGrp"]
coh_null_sum["yrSinceLastConvGrp"]
coh_null_sum["arrestLocation"]

