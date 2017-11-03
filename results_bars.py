import matplotlib.pyplot as plt
import numpy as np
import yaml

def best_result_in(experiments):
    results = [[exp, results_for(exp)] for exp in experiments]
    best = sorted(results, key=lambda l:l[1])[-1]

    return best

def results_for(experiment):
    file = open("measures/%s/overall.yml" % experiment)
    res = yaml.load(file)
    file.close()

    result = res["precisions"]["avg"]

    print "result for %s is %s" % (experiment, str(result))

    return result

experiments = ["binary_dcqt", "binary_dstft"]
results = [[exp, results_for(exp)] for exp in experiments]

results += [best_result_in(["cqt_d2f1", "cqt_d2f2", "cqt_d2f3", "cqt_d2f4"]),
            best_result_in(["stft_d2f1", "stft_d2f2", "stft_d2f3", "stft_d2f4"]),
            best_result_in(["cqt_fold1_filtering", "cqt_fold2_filtering", "cqt_fold3_filtering", "cqt_fold4_filtering"]),
            best_result_in(["stft_fold1_filtering", "stft_fold2_filtering", "stft_fold3_filtering", "stft_fold4_filtering"])]

results = list(reversed(sorted(results, key=lambda l:l[1])))

x_y = np.transpose(results)

fig, ax = plt.subplots(figsize=(10,6))
x_ticks = range(len(results))
ax.bar(x_ticks, x_y[1])

for i, v in enumerate(x_y[1]):
    ax.text(i, float(v), "%s%s" % (str(round(100 * float(v), 2)), "%"),
            ha='center', va='bottom')

ax.set_xticks(x_ticks)
ax.set_xticklabels(x_y[0])
ax.set_ylim([0, 0.5])

ax.set_ylabel('precision')

plt.savefig("results")
plt.close(fig)
