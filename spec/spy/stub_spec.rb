require 'spec_helper'

module RSpec
  module Mocks
    describe "A method stub" do
      before(:each) do
        @class = Class.new do
          class << self
            def existing_class_method
              existing_private_class_method
            end

            private
            def existing_private_class_method
              :original_value
            end
          end

          def existing_instance_method
            existing_private_instance_method
          end

          private
          def existing_private_instance_method
            :original_value
          end
        end
        @instance = @class.new
        @stub = Object.new
      end

      describe "using Spy.stub" do
        it "returns declared value when message is received" do
          Spy.stub(@instance, :msg).and_return(:return_value)
          expect(@instance.msg).to equal(:return_value)
        end
      end

      it "instructs an instance to respond_to the message" do
        Spy.stub(@instance, :msg)
        expect(@instance).to respond_to(:msg)
      end

      it "instructs a class object to respond_to the message" do
        Spy.stub(@class, :msg)
        expect(@class).to respond_to(:msg)
      end

      it "handles multiple stubbed methods" do
        Spy.stub(@instance, :msg1 => 1, :msg2 => 2)
        expect(@instance.msg1).to eq(1)
        expect(@instance.msg2).to eq(2)
      end

      it "yields a specified object" do
        Spy.stub(@instance, :method_that_yields).and_yield(:yielded_obj)
        current_value = :value_before
        @instance.method_that_yields {|val| current_value = val}
        expect(current_value).to eq :yielded_obj
      end

      it "yields a specified object and return another specified object" do
        yielded_obj = double("my mock")
        Spy.stub(yielded_obj, :foo)
        Spy.stub(@instance, :method_that_yields_and_returns).and_yield(yielded_obj).and_return(:baz)
        expect(@instance.method_that_yields_and_returns { |o| o.foo :bar }).to eq :baz
      end

      it "throws when told to" do
        Spy.stub(@stub, :something).and_throw(:up)
        expect { @stub.something }.to throw_symbol(:up)
      end

      it "throws with argument when told to" do
        Spy.stub(@stub, :something).and_throw(:up, 'high')
        expect { @stub.something }.to throw_symbol(:up, 'high')
      end

      it "overrides a pre-existing method" do
        Spy.stub(@stub, :existing_instance_method).and_return(:updated_stub_value)
        expect(@stub.existing_instance_method).to eq :updated_stub_value
      end
    end
  end
end