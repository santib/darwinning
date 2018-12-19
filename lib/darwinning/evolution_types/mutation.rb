module Darwinning
  module EvolutionTypes
    class Mutation
      attr_reader :mutation_method, :mutation_rate

      def initialize(options = {})
        @mutation_rate = options.fetch(:mutation_rate, 0.0)
        @mutation_method = options.fetch(:mutation_method, :re_express_random_genotype)
      end

      def evolve(members)
        mutate(members)
      end

      def pairwise?
        false
      end

      protected

      def mutate(members)
        members.map do |member|
          if rand < mutation_rate
            send(mutation_method, member)
          else
            member
          end
        end
      end

      # Selects a random genotype from the organism and re-expresses its gene
      def re_express_random_genotype(member)
        random_index = rand(member.genotypes.length - 1)
        gene = member.genes[random_index]

        if member.class.superclass == Darwinning::Organism
          member.genotypes[gene] = gene.express
        else
          member.send("#{gene.name}=", gene.express)
        end

        member
      end

      # Selects two random genotypes and swaps them
      def interchange_random_genotypes(member)
        gene1, gene2 = member.genes.sample(2)

        genotype1 = member.genotypes[gene1]
        genotype2 = member.genotypes[gene2]

        if member.class.superclass == Darwinning::Organism
          member.genotypes[gene1] = genotype2
          member.genotypes[gene2] = genotype1
        else
          member.send("#{gene1.name}=", genotype2)
          member.send("#{gene2.name}=", genotype1)
        end

        member
      end
    end
  end
end
