require "range"
require "comparable"

lib C
  fun atoi(str : Char*) : Int
  fun atof(str : Char*) : Double
  fun strtof(str : Char*, endp : Char**) : Float
  fun strncmp(s1 : Char*, s2 : Char*, n : Int) : Int
  fun strlen(s : Char*) : Int
  fun strcpy(dest : Char*, src : Char*) : Char*
  fun strcat(dest : Char*, src : Char*) : Char*
  fun strcmp(s1 : Char*, s2 : Char*) : Int
  fun strncpy(s1 : Char*, s2 : Char*, n : Int) : Char*
  fun sprintf(str : Char*, format : Char*, ...)
end

class String
  include Comparable

  def self.from_cstr(chars)
    length = C.strlen(chars)
    str = Pointer.malloc(length + 5)
    str.as(Int).value = length
    C.strcpy(str.as(Char) + 4, chars)
    str.as(String)
  end

  def self.from_cstr(chars, length)
    str = Pointer.malloc(length + 5)
    str.as(Int).value = length
    C.strncpy(str.as(Char) + 4, chars, length)
    (str + length + 4).as(Char).value = '\0'
    str.as(String)
  end

  def self.new_with_capacity(capacity)
    str = Pointer.malloc(capacity + 5)
    buffer = str.as(String).cstr
    yield buffer
    str.as(Int).value = C.strlen(buffer)
    str.as(String)
  end

  def self.new_with_length(length)
    str = Pointer.malloc(length + 5)
    buffer = str.as(String).cstr
    yield buffer
    buffer[length] = '\0'
    str.as(Int).value = length
    str.as(String)
  end

  def to_i
    C.atoi @c.ptr
  end

  def to_f
    C.strtof @c.ptr, nil
  end

  def to_d
    C.atof @c.ptr
  end

  def [](index : Int)
    index += length if index < 0
    @c.ptr[index]
  end

  def [](range : Range)
    from = range.begin
    from += length if from < 0
    to = range.end
    to += length if to < 0
    to -= 1 if range.excludes_end?
    length = to - from + 1
    self[from, length]
  end

  def [](start : Int, count : Int)
    String.new_with_length(count) do |buffer|
      C.strncpy(buffer, @c.ptr + start, count)
    end
  end

  def downcase
    String.new_with_length(length) do |buffer|
      length.times do |i|
        buffer[i] = @c.ptr[i].downcase
      end
    end
  end

  def upcase
    String.new_with_length(length) do |buffer|
      length.times do |i|
        buffer[i] = @c.ptr[i].upcase
      end
    end
  end

  def capitalize
    return self if length == 0

    String.new_with_length(length) do |buffer|
      buffer[0] = @c.ptr[0].upcase
      (length - 1).times do |i|
        buffer[i + 1] = @c.ptr[i + 1].downcase
      end
    end
  end

  def chomp
    excess = 0
    while (c = @c.ptr[length - 1 - excess]) == '\r' || c == '\n'
      excess += 1
    end

    if excess == 0
      self
    else
      self[0, length - excess]
    end
  end

  def strip
    excess_right = 0
    while @c.ptr[length - 1 - excess_right].whitespace?
      excess_right += 1
    end

    excess_left = 0
    while @c.ptr[excess_left].whitespace?
      excess_left += 1
    end

    if excess_right == 0 && excess_left == 0
      self
    else
      self[excess_left, length - excess_left - excess_right]
    end
  end

  def rstrip
    excess_right = 0
    while @c.ptr[length - 1 - excess_right].whitespace?
      excess_right += 1
    end

    if excess_right == 0
      self
    else
      self[0, length - excess_right]
    end
  end

  def lstrip
    excess_left = 0
    while @c.ptr[excess_left].whitespace?
      excess_left += 1
    end

    if excess_left == 0
      self
    else
      self[excess_left, length - excess_left]
    end
  end

  def empty?
    length == 0
  end

  def <=>(other : self)
    Object.same?(self, other) ? 0 : C.strcmp(@c.ptr, other)
  end

  def =~(regex)
    $~ = regex.match(self)
    $~ ? $~.begin(0) : nil
  end

  def +(other)
    new_string_buffer = Pointer.malloc(length + other.length + 1).as(Char)
    C.strcpy(new_string_buffer, @c.ptr)
    C.strcat(new_string_buffer, other)
    String.from_cstr(new_string_buffer)
  end

  def *(times : Int)
    return "" if times <= 0
    str = StringBuilder.new
    times.times { str << self }
    str.inspect
  end

  def length
    @length
  end

  def each_char
    p = @c.ptr
    length.times do
      yield p.value
      p += 1
    end
  end

  def inspect
    "\"#{to_s}\""
  end

  def starts_with?(str)
    C.strncmp(cstr, str, str.length) == 0
  end

  def hash
    h = 0
    each_char do |c|
      h = 31 * h + c.ord
    end
    h
  end

  def to_s
    self
  end

  def cstr
    @c.ptr
  end
end