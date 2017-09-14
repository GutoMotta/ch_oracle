module AnnotationLoop
  def annotation_loop(ann_a, ann_b)
    a = b = 0
    while a < ann_a.size && b < ann_b.size
      on_a, off_a, *t_a = ann_a[a]
      on_b, off_b, *t_b = ann_b[b]

      yield t_a, t_b

      if off_a == off_b
        a += 1
        b += 1
      elsif off_a < off_b
        a += 1
      else
        b += 1
      end
    end
  end
end
