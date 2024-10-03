%%
out = fourParamModel([2,5,0.5,-4]);
figure; bar(out);
xticks(1:6)
xticklabels({'Hit-exp','FA-exp','Hit-optoIC','FA-optoIC','Hit-optoMGB','FA-MGB'})


y = [0.9, 0.1, 0.9, 0.9,0.6, 0.4]; 



e = myerror([1,1,0,0],y);

%%
fun = @(x)(myerror(x,y));
out = fmincon(fun, [1,1,0,0],[],[],[],[],[1e-06,1e-06,-100,-100],[100 100 100 100]);



%%

predBehav = fourParamModel(out);
figure; bar(predBehav);
xticks(1:6)
xticklabels({'Hit-exp','FA-exp','Hit-optoIC','FA-optoIC','Hit-optoMGB','FA-MGB'})









%%

function e = myerror(x,y)
    e = sum((y-fourParamModel(x)).^2);
end 


function out= fourParamModel(x)
ICvar = x(1);
MGBgain =  x(2);
cri = x(3);
cri_opto = x(4);

IC = buildDistribution(1, ICvar, 0, ICvar);
MGB = buildDistribution(1, ICvar/MGBgain, 0, ICvar/MGBgain);

%optimalCriterion = (mean(IC.target) + mean(IC.foil))/2; 

expert = applyCriteria(MGB,cri);

opto_IC = applyCriteria(IC,cri_opto);

opto_MGB = applyCriteria(IC,cri);

out = [expert.hit, expert.fa, opto_IC.hit, opto_IC.fa, opto_MGB.hit, opto_MGB.fa];
end 

