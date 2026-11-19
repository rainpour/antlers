# frozen_string_literal: true

require_relative '../../lib/nodes/form_node'

class MockFormClass
  def form_action
    '/users?tab=new&page=1'
  end

  def instance_binding
    binding
  end
end

RSpec.describe Antlers::FormNode do
  let(:mock_instance) { MockFormClass.new }

  describe '#render' do
    context 'with an action string' do
      subject(:form_node) { described_class.new(name: %('/submit'), action: %('/submit')) }

      it 'renders the static string' do
        expect(form_node.render(current_binding: mock_instance.instance_binding))
          .to eq("<form action='/submit' method='POST'></form>")
      end
    end

    context 'with an action variable' do
      subject(:form_node) { described_class.new(name: 'form_action', action: 'form_action') }

      it 'renders the evaluated variable' do
        expect(form_node.render(current_binding: mock_instance.instance_binding))
          .to eq("<form action='/users?tab=new&amp;page=1' method='POST'></form>")
      end
    end
  end
end

RSpec.describe Antlers::FormNode, 'with attributes' do
  let(:form_binding) { binding }

  it 'renders its attributes, escaped' do
    form_node = described_class.new(name: %('/cart'), action: %('/cart'), attributes: { 'class' => %(add "to" cart) })
    html = %(<form action='/cart' method='POST' class='add &quot;to&quot; cart'></form>)

    expect(form_node.render(current_binding: form_binding)).to eq(html)
  end

  it 'takes GET as its method' do
    form_node = described_class.new(name: %('/search'), action: %('/search'), method: 'get')

    expect(form_node.render(current_binding: form_binding)).to eq("<form action='/search' method='GET'></form>")
  end

  it 'only takes GET or POST' do
    expect { described_class.new(name: %('/cart'), action: %('/cart'), method: 'DELETE') }.to raise_error(ArgumentError)
  end
end
