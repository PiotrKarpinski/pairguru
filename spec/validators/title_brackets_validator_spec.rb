require "rails_helper"


describe 'TitleBracketsValidator' do
  subject { Validatable.new(title: title) }

  shared_examples "has valid title" do
    it "should be valid" do
      expect(subject).to be_valid
    end
  end

  shared_examples "has invalid title" do
    it "should not be valid" do
      expect(subject).not_to be_valid
    end
  end

  context "with curly brackets" do
    let(:title) { "The Fellowship of the Ring {Peter Jackson}" }
    it_behaves_like "has valid title"
  end

  context "with square brackets" do
    let(:title) { "The Fellowship of the Ring [Lord of The Rings]" }
    it_behaves_like "has valid title"
  end

  context "with not closed brackets" do
    let(:title) { "The Fellowship of the Ring (2001" }
    it_behaves_like "has invalid title"
  end

  context "with not opened brackets" do
    let(:title) { "The Fellowship of the Ring 2001)" }
    it_behaves_like "has invalid title"
  end

  context "with not too much closing brackets" do
    let(:title) { "The Fellowship of the Ring (2001) - 2003)" }
    it_behaves_like "has invalid title"
  end

  context "with not too much opening brackets" do
    let(:title) { "The Fellowship of the Ring (2001 - (2003)" }
    it_behaves_like "has invalid title"
  end

  context "with empty brackets" do
    let(:title) { "The Fellowship of the Ring ()" }
    it_behaves_like "has invalid title"
  end

  context "with brackets in wrong order" do
    let(:title) { "The Fellowship of the )Ring(" }
    it_behaves_like "has invalid title"
  end

  context "with matching brackets" do
    let(:title) { "The Fellowship of the Ring (2001)" }
    it_behaves_like "has valid title"
  end

  context "with multiple matching brackets" do
    let(:title) { "The Fellowship of the Ring [Lord of The Rings] (2001) {Peter Jackson}" }
    it_behaves_like "has valid title"
  end

  context "with nested matching brackets" do
    let(:title) { "The Fellowship of the Ring [Lord of The Rings {Peter Jackson}] (2012)" }
    it_behaves_like "has valid title"
  end

  context "with no brackets" do
    let(:title) { "Lord of The Rings" }
    it_behaves_like "has valid title"
  end
end

class Validatable
  include ActiveModel::Validations
  attr_accessor :title
  validate :no_empty_brackets, :no_single_brackets, :no_wrong_order, :not_too_much_brackets

  def no_empty_brackets
    new_string = @title.gsub('()', '|').gsub('[]', '|').gsub('{}', '|')
    if new_string.include?("|")
      errors.add(:title, "No empty brackets") && nil
    end
  end

  def not_too_much_brackets
    if @title.count('(') != @title.count(')')
      errors.add(:title, "Too many brackets")
    end
  end

  def no_wrong_order
    closing_brackets = [')', ']', '}']
    %w|( [ {|.each_with_index do |ch, index|
      if @title.index(ch) && @title.index(closing_brackets[index]) && (@title.index(ch) > @title.index(closing_brackets[index]))
        errors.add(:title, "Bracket is closing before being open")
      end
    end
  end

  def no_single_brackets
    new_string = @title.tr('()', '|')
    if new_string.count('|').odd?
      errors.add(:title, "No single brackets") && nil
    end
  end

  def initialize(movie)
    @title = movie[:title]
  end
end
