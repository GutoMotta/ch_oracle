#!/bin/bash
set -o xtrace

ruby output_from_chromas.rb cqt_n2 templates_binary.yml   binary_dcqt &
ruby output_from_chromas.rb cqt_n2 templates_cqt_n2f1.yml cqt_d2f1 templates_cqt_n2f1_files.csv &
ruby output_from_chromas.rb cqt_n2 templates_cqt_n2f2.yml cqt_d2f2 templates_cqt_n2f2_files.csv &
ruby output_from_chromas.rb cqt_n2 templates_cqt_n2f3.yml cqt_d2f3 templates_cqt_n2f3_files.csv &
ruby output_from_chromas.rb cqt_n2 templates_cqt_n2f4.yml cqt_d2f4 templates_cqt_n2f4_files.csv &

ruby output_from_chromas.rb stft_n2 templates_binary.yml    binary_dstft &
ruby output_from_chromas.rb stft_n2 templates_stft_n2f1.yml stft_d2f1 templates_stft_n2f1_files.csv &
ruby output_from_chromas.rb stft_n2 templates_stft_n2f2.yml stft_d2f2 templates_stft_n2f2_files.csv &
ruby output_from_chromas.rb stft_n2 templates_stft_n2f3.yml stft_d2f3 templates_stft_n2f3_files.csv &
ruby output_from_chromas.rb stft_n2 templates_stft_n2f4.yml stft_d2f4 templates_stft_n2f4_files.csv &

wait

ruby evaluate_recognition.rb binary_dcqt &
ruby evaluate_recognition.rb cqt_d2f1 &
ruby evaluate_recognition.rb cqt_d2f2 &
ruby evaluate_recognition.rb cqt_d2f3 &
ruby evaluate_recognition.rb cqt_d2f4 &

ruby evaluate_recognition.rb binary_dstft &
ruby evaluate_recognition.rb stft_d2f1 &
ruby evaluate_recognition.rb stft_d2f2 &
ruby evaluate_recognition.rb stft_d2f3 &
ruby evaluate_recognition.rb stft_d2f4 &

wait

echo "ok"
