[:cqt, :stft].each do |chroma_algorithm|
  [:learn, :bin].each do |templates|
    [10, 0, 5, 12].each do |smooth_chromas|
      [5, 0, 10, 30, 50, 80, 100].each do |compression_factor|
        Experiment.new(
          chroma_algorithm: chroma_algorithm,
          templates: templates,
          smooth_chromas: smooth_chromas,
          n_fft: 4096,
          hop_length: 2048,
          compression_factor: compression_factor
        ).results
      end
    end
  end
end

