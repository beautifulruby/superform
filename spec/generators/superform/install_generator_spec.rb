# frozen_string_literal: true

# Test suite for the superform:install generator
#
# This spec tests the following functionality:
# - Dependency checking for phlex-rails gem
# - Creation of Components::Forms::Base in app/components/forms/base.rb
# - Proper module structure and content generation
# - Error handling when dependencies are missing
# - Full generator execution flow

require "spec_helper"
require "rails/generators"
require "generators/superform/install/install_generator"
require "tmpdir"
require "fileutils"


RSpec.describe Superform::InstallGenerator, type: :generator do
  include FileUtils

  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new }

  before do
    generator.destination_root = destination_root
    allow(Rails).to receive(:root).and_return(Pathname.new(destination_root))
  end

  after do
    rm_rf(destination_root) if File.exist?(destination_root)
  end

  describe "#check_phlex_rails_dependency" do
    context "when phlex-rails is not installed" do
      before do
        allow(generator).to receive(:gem_in_bundle?).with("phlex-rails").and_return(false)
      end

      it "displays error message and exits" do
        expect(generator).to receive(:say).with(
          "ERROR: phlex-rails is not installed. Please run 'bundle add phlex-rails' first.",
          :red
        )
        expect(generator).to receive(:exit).with(1)

        generator.check_phlex_rails_dependency
      end
    end

    context "when phlex-rails is installed" do
      before do
        allow(generator).to receive(:gem_in_bundle?).with("phlex-rails").and_return(true)
      end

      it "does not exit or show error" do
        expect(generator).not_to receive(:say)
        expect(generator).not_to receive(:exit)

        generator.check_phlex_rails_dependency
      end
    end
  end

  describe "#create_application_form" do
    before do
      allow(generator).to receive(:gem_in_bundle?).with("phlex-rails").and_return(true)
      mkdir_p(File.join(destination_root, "app", "components", "forms"))
    end

    it "creates the base form component file" do
      generator.create_application_form

      expect(File.exist?(File.join(destination_root, "app", "components", "forms", "base.rb"))).to be true
    end

    it "generates base form with essential methods" do
      generator.create_application_form

      base_file = File.read(File.join(destination_root, "app", "components", "forms", "base.rb"))
      
      expect(base_file).to include("class Base < Superform::Rails::Form")
      expect(base_file).to include("def row(component)")
      expect(base_file).to include("def error_messages")
    end
  end

  describe "#gem_in_bundle?" do
    let(:mock_specs) { [double(name: "phlex-rails"), double(name: "rails")] }

    before do
      allow(Bundler).to receive(:load).and_return(double(specs: mock_specs))
    end

    it "returns true when gem is in bundle" do
      expect(generator.send(:gem_in_bundle?, "phlex-rails")).to be true
      expect(generator.send(:gem_in_bundle?, "rails")).to be true
    end

    it "returns false when gem is not in bundle" do
      expect(generator.send(:gem_in_bundle?, "nonexistent-gem")).to be false
    end

    context "with empty bundle" do
      before do
        allow(Bundler).to receive(:load).and_return(double(specs: []))
      end

      it "returns false for any gem" do
        expect(generator.send(:gem_in_bundle?, "phlex-rails")).to be false
        expect(generator.send(:gem_in_bundle?, "rails")).to be false
      end
    end
  end

  describe "full generator run" do
    context "when phlex-rails is installed" do
      before do
        allow(generator).to receive(:gem_in_bundle?).with("phlex-rails").and_return(true)
        mkdir_p(File.join(destination_root, "app", "components", "forms"))
      end

      it "completes successfully" do
        expect { generator.invoke_all }.not_to raise_error
        expect(File.exist?(File.join(destination_root, "app", "components", "forms", "base.rb"))).to be true
      end
    end

    context "when phlex-rails is not installed" do
      before do
        allow(generator).to receive(:gem_in_bundle?).with("phlex-rails").and_return(false)
        allow(generator).to receive(:say)
        allow(generator).to receive(:exit).and_raise(SystemExit)
      end

      it "fails with SystemExit" do
        expect { generator.invoke_all }.to raise_error(SystemExit)
        expect(File.exist?(File.join(destination_root, "app", "components", "forms", "base.rb"))).to be false
      end
    end
  end
end