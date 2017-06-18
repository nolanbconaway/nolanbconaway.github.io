import numpy as np

labels = {
"4ad": dict(n = 14),
"anti": dict(n = 12),
"astralwerks": dict(n = 11),
"columbia": dict(n = 11),
"domino": dict(n = 16),
"drag city": dict(n = 16),
"jagjaguwar": dict(n = 12),
"matador": dict(n = 22),
"merge": dict(n = 22),
"mute": dict(n = 11),
"nonesuch": dict(n = 10),
"profound lore": dict(n = 12),
"relapse": dict(n = 10),
"rough trade": dict(n = 12),
"self-released": dict(n = 26),
"sub pop": dict(n = 18),
"thrill jockey": dict(n = 12),
"warp": dict(n = 16)
}

p = 0.22
ns = np.array([i['n'] for i in labels.values()])
N = 1000000



samples = np.empty((N, len(ns)))
for i in range(N):
	samples[i,:] = np.random.binomial(ns,p)

# how likely are four 0s?
zs = np.sum(samples == 0, axis=1)
print np.mean(zs>3), np.sum(zs>3)

# how likely are seven abovee 30%
ps =  samples / ns[np.newaxis,:]
ps = np.sum(ps > 0.4,axis=1)
print np.mean(ps>3), np.sum(ps>3)

ps =  ps>3
zs = zs>3

print np.mean(ps & zs), np.sum(ps & zs)
