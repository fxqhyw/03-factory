module Factory
  def self.new(*args, &block)
    if name_is_valid?(args.first)
      name = args.shift
      args_validation(args)
      const_set(name, class_create(*args, &block))
    else
      args_validation(args)
      class_create(*args, &block)
    end
  end

  private_class_method

  def self.name_is_valid?(name)
    name.is_a?(String) && /^[A-Z]/.match(name)
  end

  def self.args_validation(args)
    args.each do |a|
      unless a.is_a? Symbol
        raise NameError, "identifier #{a} need to be constant"
      end
    end
  end

  def self.class_create(*args, &block)
    Class.new(Factory) do
      attr_accessor(*args)

      define_method :initialize do |*attrs|
        args.zip(attrs) do |method, value|
          send("#{method}=", value)
        end
      end
      class_eval(&block) if block_given?
    end
  end

  class Factory
    include Enumerable

    def ==(other)
      self.class == other.class && values == other.values
    end

    alias eql? ==

    def [](key)
      if key.is_a?(Integer)
        msg = "offset #{key} too large for factory(size:#{length})"
        raise IndexError, msg if key > length - 1
        instance_variable_get(instance_variables[key])
      else
        send(key.to_sym)
      end
    end

    def []=(key, value)
      if key.is_a?(Integer)
        iv = instance_variables[key]
        instance_variable_set(iv, value)
      else
        send("#{key.to_sym}=", value)
      end
    end

    def to_a
      instance_variables.inject([]) { |arr, iv| arr << instance_variable_get(iv) }
    end

    alias values to_a

    def values_at(*selector)
      values.values_at(*selector)
    end

    def members
      instance_variables.inject([]) { |mem, iv| mem << iv.to_s.sub('@', '').to_sym }
    end

    def length
      members.length
    end

    alias size length

    def to_h
      members.zip(values).to_h
    end

    def each(&block)
      block_given? ? values.send(:each, &block) : enum_for(:each)
    end

    def each_pair(&block)
      block_given? ? to_h.send(:each, &block) : enum_for(:each)
    end

    def dig(*args)
      to_h.send(:dig, *args)
    end

    def select(&block)
      block_given? ? values.send(:select, &block) : enum_for(:select)
    end
  end
end