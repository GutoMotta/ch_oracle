class Chroma
  attr_accessor :on, :off, :feature

  def self.parse(line)
    on, off, feature = line.split(' ')

    new on.to_f, off.to_f, feature.split(',').map(&:to_f)
  end

  def initialize(on, off, feature)
    @on = on
    @off = off
    @feature = feature
  end

  def to_s
    "#{on} #{off} #{feature.join ','}"
  end

  def similarity(other_chroma)
    [feature, other_chroma].transpose.map { |f, o| f * o }.sum
  end

  def raw
    [on, off, feature]
  end
end
