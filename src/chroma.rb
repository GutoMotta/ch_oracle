class Chroma
  attr_writer :feature
  attr_accessor :on, :off

  def self.parse(line)
    on, off, feature = line.split(' ')

    new on.to_f, off.to_f, feature.split(',').map(&:to_f)
  end

  def initialize(on, off, feature, compression_factor: 0)
    @on = on
    @off = off
    @feature = feature
    @compression_factor = compression_factor
  end

  def to_s
    "#{on} #{off} #{feature.join ','}"
  end

  def similarity(other_chroma)
    [feature, other_chroma].transpose.map { |f, o| f * o }.sum
  end

  def feature
    if @compression_factor.to_i > 0
      compressed_feature
    else
      @feature
    end
  end

  def raw
    [on, off, feature]
  end

  private

  def compressed_feature
    return @compressed_feature if @compressed_feature

    compressed = @feature.map { |i| Math.log(1 + i * @compression_factor) }
    vector_feature = Vector[*compressed]

    return vector_feature.to_a if vector_feature.norm.zero?

    @compressed_feature ||= vector_feature.normalize.to_a
  end
end
