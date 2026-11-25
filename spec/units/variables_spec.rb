# frozen_string_literal: true

require_relative '../../lib/nodes/for_node'
require_relative '../../lib/nodes/var_node'

RSpec.describe Antlers::Variables::Expression do
  it 'reads an expression once' do
    expect(described_class.for('row.cells')).to be(described_class.for('row.cells'))
  end

  it 'reads a variable and its path' do
    expect(described_class.for('@table.rows.size')).to have_attributes(name: '@table', path: %w[rows size], instance_variable: true)
  end

  it 'reads values without a variable' do
    expect(['3', "'text'", ':name', 'nil', '"it\'s"'].map { described_class.for(it) }.map(&:value)).to eq([3, 'text', :name, nil, "it's"])
  end

  it "keeps a value's string from being changed by a render" do
    expect(described_class.for("'text'").value).to be_frozen
  end

  it 'still reads a cached variable from each binding' do
    node = Antlers::VarNode.new(value: 'cell')
    rendered = %w[a b].map do |cell|
      node.render(current_binding: binding)
    end

    expect(rendered).to eq(%w[a b])
  end
end
