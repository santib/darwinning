module Darwinning
  module EvolutionTypes
    class Reproduction

      attr_reader :crossover_method

      # Available crossover_methods:
      #   :alternating_swap
      #   :random_swap
      #   :pmx_swap
      def initialize(options = {})
        @crossover_method = options.fetch(:crossover_method, :alternating_swap)
      end

      def evolve(m1, m2)
        sexytimes(m1, m2)
      end

      def pairwise?
        true
      end

      protected

      def sexytimes(m1, m2)
        raise "Only organisms of the same type can breed" unless m1.class == m2.class

        new_genotypes = send(crossover_method, m1, m2)

        organism_klass = m1.class
        organism1 = new_member_from_genotypes(organism_klass, new_genotypes.first)
        organism2 = new_member_from_genotypes(organism_klass, new_genotypes.last)

        [organism1, organism2]
      end

      def new_member_from_genotypes(organism_klass, genotypes)
        new_member = organism_klass.new
        if organism_klass.superclass == Darwinning::Organism
          new_member.genotypes = genotypes
        else
          new_member.genes.each do |gene|
            new_member.send("#{gene.name}=", genotypes[gene])
          end
        end
        new_member
      end

      def alternating_swap(m1, m2)
        genotypes1 = {}
        genotypes2 = {}

        m1.genes.each_with_index do |gene, i|
          if i % 2 == 0
            genotypes1[gene] = m1.genotypes[gene]
            genotypes2[gene] = m2.genotypes[gene]
          else
            genotypes1[gene] = m2.genotypes[gene]
            genotypes2[gene] = m1.genotypes[gene]
          end
        end

        [genotypes1, genotypes2]
      end

      def random_swap(m1, m2)
        genotypes1 = {}
        genotypes2 = {}

        m1.genes.each do |gene|
          g1_parent = [m1,m2].sample
          g2_parent = [m1,m2].sample

          genotypes1[gene] = g1_parent.genotypes[gene]
          genotypes2[gene] = g2_parent.genotypes[gene]
        end

        [genotypes1, genotypes2]
      end

      def pmx_swap(m1, m2)
        genotypes1 = {}
        genotypes2 = {}
        genotypes1_interchange = {}
        genotypes2_interchange = {}

        swap_point = rand(m1.genes.size / 2)

        m1.genes.each_with_index do |gene, i|
          m1_node = m1.genotypes[gene]
          m2_node = m2.genotypes[gene]

          if i <= swap_point
            genotypes1_interchange[m2_node] = m1_node
            genotypes2_interchange[m1_node] = m2_node
            genotypes1[gene] = m2_node
            genotypes2[gene] = m1_node
          else
            key1 = m1_node
            while genotypes1_interchange.key?(key1)
              key1 = genotypes1_interchange[key1]
            end
            genotypes1[gene] = key1

            key2 = m2_node
            while genotypes2_interchange.key?(key2)
              key2 = genotypes2_interchange[key2]
            end
            genotypes2[gene] = key2
          end
        end

        [genotypes1, genotypes2]
      end
    end
  end
end
