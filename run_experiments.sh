#!/bin/bash
#
#
# ruby scripts/output_from_chromas.rb -c chromas_power_1_instead_of_2
#   -t templates_binary.yml -o chromas_power_1_instead_of_2 -f

set -o xtrace

ruby scripts/output_from_chromas.rb -c stft -t templates/templates_stftf1.yml -l templates/templates_stftf1_files.csv -o stft_fold1_filtering -f &
ruby scripts/output_from_chromas.rb -c stft -t templates/templates_stftf2.yml -l templates/templates_stftf2_files.csv -o stft_fold2_filtering -f &
ruby scripts/output_from_chromas.rb -c stft -t templates/templates_stftf3.yml -l templates/templates_stftf3_files.csv -o stft_fold3_filtering -f &
ruby scripts/output_from_chromas.rb -c stft -t templates/templates_stftf4.yml -l templates/templates_stftf4_files.csv -o stft_fold4_filtering -f &

ruby scripts/output_from_chromas.rb -c cqt -t templates/templates_cqtf1.yml -o cqt_fold1_filtering -f &
ruby scripts/output_from_chromas.rb -c cqt -t templates/templates_cqtf2.yml -o cqt_fold2_filtering -f &
ruby scripts/output_from_chromas.rb -c cqt -t templates/templates_cqtf3.yml -o cqt_fold3_filtering -f &
ruby scripts/output_from_chromas.rb -c cqt -t templates/templates_cqtf4.yml -o cqt_fold4_filtering -f &

wait

ruby scripts/evaluate_recognition.rb chromas_power_1_instead_of_2 &

ruby scripts/evaluate_recognition.rb stft_fold1_filtering &
ruby scripts/evaluate_recognition.rb stft_fold2_filtering &
ruby scripts/evaluate_recognition.rb stft_fold3_filtering &
ruby scripts/evaluate_recognition.rb stft_fold4_filtering &

ruby scripts/evaluate_recognition.rb cqt_fold1_filtering &
ruby scripts/evaluate_recognition.rb cqt_fold2_filtering &
ruby scripts/evaluate_recognition.rb cqt_fold3_filtering &
ruby scripts/evaluate_recognition.rb cqt_fold4_filtering &

wait

echo "ok"
