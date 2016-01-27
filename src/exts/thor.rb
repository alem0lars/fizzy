class Thor
  module Actions

    # Monkey-patch to retrieve the template currently processed.
    old_template = instance_method(:template)
    define_method :template, ->(source, *args, &blk) do
      $fizzy_cur_template = source
      old_template.bind(self).(source, *args, &blk)
    end

  end
end
