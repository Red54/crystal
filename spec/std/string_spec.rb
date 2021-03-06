require 'spec_helper'

describe 'Stdlib: String' do
  it 'compare strings: different length' do
    run('require "object"; require "c"; require "range"; require "string"; require "pointer"; "a" == "aa"').to_b.should be_false
  end

  it 'compare strings: same length, same string' do
    run('require "object"; require "c"; require "range"; require "string"; require "pointer"; "foo" == "foo"').to_b.should be_true
  end

  it 'compare strings: same length, different string' do
    run('require "object"; require "c"; require "range"; require "string"; require "pointer"; "foo" == "bar"').to_b.should be_false
  end
end
