require 'spec_helper'

describe Darwinning::EvolutionTypes::Reproduction do
  describe '#evolve' do
    context 'when using pmx_swap' do
      subject { described_class.new(crossover_method: :pmx_swap) }

      shared_examples_for 'a crossover method that mixes two parents' do
        let!(:previous_parent1_genotypes) { parent1.genotypes.values }
        let!(:previous_parent2_genotypes) { parent2.genotypes.values }

        it "modifies the member's genotype to be the new expression of the gene" do
          child1, child2 = subject.evolve(parent1, parent2)

          expect(parent1.genotypes.values).to eq(previous_parent1_genotypes)
          expect(parent2.genotypes.values).to eq(previous_parent2_genotypes)
          expect(child1.genotypes.values).to eq([2, 1, 3])
          expect(child2.genotypes.values).to eq([1, 3, 2])
        end
      end

      context 'with a subclass of Organism' do
        let(:parent1) { Triple.new }
        let(:parent2) { Triple.new }

        before do
          sample1 = [1, 2, 3]
          parent1.genotypes.zip(sample1).each do |genotype, value|
            parent1.genotypes[genotype[0]] = value
          end
          sample2 = [2, 3, 1]
          parent2.genotypes.zip(sample2).each do |genotype, value|
            parent2.genotypes[genotype[0]] = value
          end
        end

        it_behaves_like 'a crossover method that mixes two parents'
      end

      context 'with a class that includes Darwinning' do
        let(:parent1) { NewTriple.new }
        let(:parent2) { NewTriple.new }

        before do
          sample1 = [1, 2, 3]
          parent1.genes.zip(sample1).each do |gene, value|
            parent1.send("#{gene.name}=", value)
          end
          sample2 = [2, 3, 1]
          parent2.genes.zip(sample2).each do |gene, value|
            parent2.send("#{gene.name}=", value)
          end
        end

        it_behaves_like 'a crossover method that mixes two parents'
      end
    end
  end
end
