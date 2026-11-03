# frozen_string_literal: true

require 'date'
require 'ostruct'
require_relative '../../lib/nodes/var_node'

class MockVarClass
  def initialize
    @ivar = 'Instance Variable'
  end

  # NOTE: Currently not in use.
  # TODO: Support Ruby code followed by Antlers code in a render method via LowNode/LowLoad, thus setting up a local variable.
  def local_var
    var = 'Local Variable'
    binding
  end

  def method_call
    'Method Call'
  end

  def method_parent
    OpenStruct.new({ method_child: true })
  end

  def published_at
    DateTime.new(2026, 10, 13, 9, 30)
  end

  def draft
    false
  end

  def links
    { 'docs' => 'https://a.io', code: 'https://b.io' }
  end

  def tags
    @tags ||= %w[ruby markdown]
  end

  def secretive
    Class.new do
      private

      def secret = 'private'
    end.new
  end

  def instance_binding
    binding
  end
end

RSpec.describe Antlers::VarNode do
  let(:mock_instance) { MockVarClass.new }

  describe '#render' do
    context 'with an instance variable' do
      subject(:var_node) { described_class.new(value: '@ivar') }

      it 'evaluates an instance variable' do
        expect(var_node.render(current_binding: mock_instance.instance_binding)).to eq('Instance Variable')
      end
    end

    context 'with a local variable' do
      subject(:var_node) { described_class.new(value: 'var') }

      it 'evaluates a local variable' do
        expect(var_node.render(current_binding: mock_instance.local_var)).to eq('Local Variable')
      end
    end

    context 'with a method call' do
      subject(:var_node) { described_class.new(value: 'method_call') }

      it 'evaluates a method call' do
        expect(var_node.render(current_binding: mock_instance.instance_binding)).to eq('Method Call')
      end
    end

    context 'with a method chain' do
      subject(:var_node) { described_class.new(value: 'method_parent.method_child') }

      it 'evaluates a method chain' do
        expect(var_node.render(current_binding: mock_instance.instance_binding)).to eq('true')
      end
    end

    context 'with a nested path into data' do
      def render(value) = described_class.new(value:).render(current_binding: mock_instance.instance_binding)

      it "reads a hash's string or symbol keys and an array's indices" do
        expect([render('links.docs'), render('links.code'), render('tags.1'), render('tags.9')])
          .to eq(['https://a.io', 'https://b.io', 'markdown', ''])
      end

      it "reads a list's first, last and size, and a hash's first and size" do
        expect([render('tags.first'), render('tags.last'), render('tags.size'), render('links.size')]).to eq(%w[ruby markdown 2 2])
        expect(Antlers::Queries.read_path(value: mock_instance.links, path: ['first'])).to eq(['docs', 'https://a.io'])
      end

      it "reads a string's upcase and downcase" do
        expect([render('method_call.upcase'), render('method_call.downcase')]).to eq(['METHOD CALL', 'method call'])
      end

      it "doesn't call other methods on hashes, arrays or plain values" do
        expect([render('tags.clear'), render('links.last'), render('method_call.reverse'), render('draft.to_s')]).to all(eq(''))
        expect(mock_instance.tags).to eq(%w[ruby markdown])
      end

      it "doesn't call an object's private methods" do
        expect { render('secretive.secret') }.to raise_error(NoMethodError)
      end
    end

    context 'with a method that returns false' do
      subject(:var_node) { described_class.new(value: 'draft') }

      it 'renders false' do
        expect(var_node.render(current_binding: mock_instance.instance_binding)).to eq('false')
      end
    end

    context 'with a method chain on an undefined name' do
      subject(:var_node) { described_class.new(value: 'missing.title') }

      it 'renders nothing' do
        expect(var_node.render(current_binding: mock_instance.instance_binding)).to eq('')
      end
    end

    context 'with an object' do
      subject(:var_node) { described_class.new(value: 'published_at', raw: true) }

      it 'renders a string' do
        expect(var_node.render(current_binding: mock_instance.instance_binding)).to eq('2026-10-13T09:30:00+00:00')
      end
    end

    context 'with a string' do
      subject(:var_node) { described_class.new(value: "I'm just a string") }

      it 'evaluates a string' do
        expect(var_node.render).to eq('I&#39;m just a string')
      end
    end
  end
end
