require 'spec_helper'

describe 'Type inference: while' do
  it "types while" do
    assert_type('while true; 1; end') { self.nil }
  end

  it "types while with break without value" do
    assert_type('while true; break; end') { self.nil }
  end

  it "types while with break with value" do
    assert_type('while true; break 1; end') { UnionType.new(self.nil, int) }
  end
end