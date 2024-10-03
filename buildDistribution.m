function sdt = buildDistribution(t_mean, t_std, f_mean, f_std)
% step 1: do distribution
num_stimuli = 10000;
target_strength = normrnd(t_mean, t_std, [1, num_stimuli / 2]);
foil_strength = normrnd(f_mean, f_std, [1, num_stimuli / 2]);
stimuli = [target_strength, foil_strength];

label = [true(1, num_stimuli / 2), false(1, num_stimuli / 2)];


sdt.target = target_strength; 
sdt.foil = foil_strength; 
sdt.stimuli = stimuli; 
sdt.label = label; 



end 