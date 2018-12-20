require 'spec_helper'

describe Darwinning::EvolutionTypes::Mutation do
  describe '#evolve' do
    context 'when the mutation is triggered' do
      # Use a mutation_rate of 1 ... which means a 100% chance of mutation.
      subject { described_class.new(mutation_rate: 1.0) }
      let(:new_gene_variant) { double }

      before do
        allow(gene).to receive(:express).and_return(new_gene_variant)
      end

      shared_examples_for 'a mutation that updates the genotype of the member' do
        before { subject.evolve([member]) }

        it "modifies the member's genotype to be the new expression of the gene" do
          expect(member.genotypes[gene]).to eq(new_gene_variant)
        end
      end

      context 'with a subclass of Organism' do
        let(:member) { Single.new }
        let(:gene) { member.genes[0] }

        it_behaves_like 'a mutation that updates the genotype of the member'
      end

      context 'with a class that includes Darwinning' do
        let(:member) { NewSingle.new }
        let(:gene) { Darwinning::Gene.new(name: :first_digit, value_range: (0..9)) }

        before do
          allow(Darwinning::Gene).to receive(:new)
            .with(name: :first_digit, value_range: (0..9))
            .and_return(gene)
        end

        it_behaves_like 'a mutation that updates the genotype of the member'
      end
    end

    context 'when using interchange_random_genotypes' do
      subject { described_class.new(mutation_method: :interchange_random_genotypes, mutation_rate: 1.0) }

      shared_examples_for 'a mutation that interchange two genotypes of the member' do
        let!(:previous_genotypes) { member.genotypes.values }
        before { subject.evolve([member]) }

        it "modifies the member's genotype to be the new expression of the gene" do
          expect(member.genotypes.values).to_not eq(previous_genotypes)
          expect(member.genotypes.values.sort).to eq(previous_genotypes.sort)
        end
      end

      context 'with a subclass of Organism' do
        let(:member) { Triple.new }

        before do
          sample = [1, 2, 3]
          member.genotypes.zip(sample).each do |genotype, value|
            member.genotypes[genotype[0]] = value
          end
        end

        it_behaves_like 'a mutation that interchange two genotypes of the member'
      end

      context 'with a class that includes Darwinning' do
        let(:member) { NewTriple.new }

        before do
          sample = [1, 2, 3]
          member.genes.zip(sample).each do |gene, value|
            member.send("#{gene.name}=", value)
          end
        end

        it_behaves_like 'a mutation that interchange two genotypes of the member'
      end
    end
  end
end
