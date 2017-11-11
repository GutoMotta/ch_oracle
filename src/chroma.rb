class Chroma
  attr_reader :on, :off, :chroma

  def self.parse(line)
    on, off, chroma = line.split(' ')

    new on.to_f, off.to_f, chroma.split(' ').map(&:to_f)
  end

  def initialize(on, off, chroma)
    @on = on
    @off = off
    @chroma = chroma
  end

  def to_s
    "#{on} #{off} #{chroma.join ','}"
  end
end
