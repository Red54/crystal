require 'spec_helper'

describe 'Type inference: def overload' do
  it "types a call with overload" do
    assert_type('def foo; 1; end; def foo(x); 2.5; end; foo') { int }
  end

  it "types a call with overload with yield" do
    assert_type('def foo; yield; 1; end; def foo; 2.5; end; foo') { double }
  end

  it "types a call with overload with yield the other way" do
    assert_type('def foo; yield; 1; end; def foo; 2.5; end; foo { 1 }') { int }
  end

  it "types a call with overload type first overload" do
    assert_type('def foo(x : Int); 2.5; end; def foo(x : Float); 1; end; foo(1)') { double }
  end

  it "types a call with overload type second overload" do
    assert_type('def foo(x : Int); 2.5; end; def foo(x : Double); 1; end; foo(1.5)') { int }
  end

  it "types a call with overload Object type first overload" do
    assert_type('class Foo; end; class Bar; end; def foo(x : Foo); 2.5; end; def foo(x : Bar); 1; end; foo(Foo.new)') { double }
  end

  it "types a call with overload Object type first overload" do
    assert_type(%q(
      class Foo
        def initialize
          @x = 1
        end
      end
      class Bar
      end

      def foo(x : Foo); 2.5; end; def foo(x : Bar); 1; end; foo(Foo.new)
      )) { double }
  end

  it "types a call with overload selecting the most restrictive" do
    assert_type('def foo(x); 1; end; def foo(x : Double); 1.1; end; foo(1.5)') { double }
  end

  it "types a call with overload selecting the most restrictive" do
    assert_type(%Q(
      def foo(x, y : Int)
        1
      end

      def foo(x : Int, y)
        1.1
      end

      def foo(x : Int, y : Int)
        'a'
      end

      foo(1, 1)
    )) { char }
  end

  it "types a call with overload matches hierarchy" do
    assert_type(%Q(
      class A; end

      def foo(x : Object)
        1
      end

      foo(A.new)
    )) { int }
  end

  it "types a call with overload matches hierarchy 2" do
    assert_type(%Q(
      class A
      end

      class B < A
      end

      def foo(x : A)
        1
      end

      def foo(x : B)
        1.5
      end

      foo(B.new)
    )) { double }
  end

  it "types a call with overload matches hierarchy 3" do
    assert_type(%Q(
      class A
      end

      class B < A
      end

      def foo(x : A)
        1
      end

      def foo(x : B)
        1.5
      end

      foo(A.new)
    )) { int }
  end

  it "types a call with overload self" do
    assert_type(%Q(
      class A
        def foo(x : self)
          1
        end

        def foo(x)
          1.5
        end
      end

      a = A.new
      a.foo(a)
    )) { int }
  end

  it "types a call with overload self other match" do
    assert_type(%Q(
      class A
        def foo(x : self)
          1
        end

        def foo(x)
          1.5
        end
      end

      a = A.new
      a.foo(1)
    )) { double }
  end

  it "types a call with overload self in included module" do
    assert_type(%Q(
      module Foo
        def foo(x : self)
          1
        end
      end

      class A
        def foo(x)
          1.5
        end
      end

      class B < A
        include Foo
      end

      b = B.new
      b.foo(b)
    )) { int }
  end

  it "types a call with overload self in included module other type" do
    assert_type(%Q(
      module Foo
        def foo(x : self)
          1
        end
      end

      class A
        def foo(x)
          1.5
        end
      end

      class B < A
        include Foo
      end

      b = B.new
      b.foo(A.new)
    )) { double }
  end

  it "types a call with overload self with inherited type" do
    assert_type(%Q(
      class A
        def foo(x : self)
          1
        end
      end

      class B < A
      end

      a = A.new
      a.foo(B.new)
    )) { int }
  end
end
