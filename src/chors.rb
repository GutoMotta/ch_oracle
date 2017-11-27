require 'byebug'
require 'fileutils'
require 'gruff'
require 'matrix'
require 'set'
require 'yaml'
require 'ostruct'

module Gruff
  module Themes
    send(:remove_const, :KEYNOTE)
    const_set(:KEYNOTE, PASTEL)
  end
end

require File.expand_path("../chors_file.rb", __FILE__)
require File.expand_path("../annotation_loop.rb", __FILE__)
require File.expand_path("../chroma.rb", __FILE__)
require File.expand_path("../librosa.rb", __FILE__)
require File.expand_path("../chromagram.rb", __FILE__)
require File.expand_path("../annotation.rb", __FILE__)
require File.expand_path("../song.rb", __FILE__)
require File.expand_path("../template_bank.rb", __FILE__)
require File.expand_path("../chord_matcher.rb", __FILE__)
require File.expand_path("../evaluation.rb", __FILE__)
require File.expand_path("../experiment.rb", __FILE__)
