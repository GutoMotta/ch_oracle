from ch_oracle import ChOracle
import sys
import os

directory = sys.argv[1]
directory_name = directory.split("/")[-1]
output_directory = "outputs/%s" % directory_name
if not os.path.exists(output_directory):
    os.makedirs(output_directory)

paths = os.listdir(directory)

for filename in paths:
    path = "%s/%s" % (directory, filename)
    out = "%s/%s.out" % (output_directory, filename)
    ChOracle(path).save_evaluation_file(out)
