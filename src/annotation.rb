class Annotation < ChorsFile
  def data
    read.lines.map do |line|
      on, off, chord = line.strip.split(' ')
      [on.to_f, off.to_f, chord]
    end
  end

  def write(annotations)
    super(annotations.map { |line| line.join(' ') }.join("\n"))
  end
end
