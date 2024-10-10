import numpy as np

def build_distribution(t_mean, t_std, f_mean, f_std):
    # Step 1: Generate distributions
    num_stimuli = 10000
    target_strength = np.random.normal(t_mean, t_std, num_stimuli // 2)
    foil_strength = np.random.normal(f_mean, f_std, num_stimuli // 2)
    
    stimuli = np.concatenate((target_strength, foil_strength))
    label = np.concatenate((np.ones(num_stimuli // 2, dtype=bool), np.zeros(num_stimuli // 2, dtype=bool)))

    sdt = {
        'target': target_strength,
        'foil': foil_strength,
        'stimuli': stimuli,
        'label': label
    }

    return sdt
