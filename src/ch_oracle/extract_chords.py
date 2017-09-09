from ch_oracle.ch_oracle import ChOracle
import sys

if len(sys.argv) > 4:
    t = float(sys.argv[4])
else:
    t = None

ChOracle(sys.argv[2], sys.argv[1], t).save_evaluation_file(sys.argv[3])
