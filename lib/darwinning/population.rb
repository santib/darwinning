module Darwinning

  class Population
    attr_accessor :members, :generations_limit, :fitness_goal
    attr_accessor :organism, :generation, :population_size
    attr_accessor :evolution_types

    DEFAULT_EVOLUTION_TYPES = [
      Darwinning::EvolutionTypes::Reproduction.new,
      Darwinning::EvolutionTypes::Mutation.new(mutation_rate: 0.10)
    ]

    def initialize(options = {})
      @organism = options.fetch(:organism)
      @population_size = options.fetch(:population_size)
      @fitness_goal = options.fetch(:fitness_goal)
      @generations_limit = options.fetch(:generations_limit, 0)
      @evolution_types = options.fetch(:evolution_types, DEFAULT_EVOLUTION_TYPES)
      @members = []
      @generation = 0 # initial population is generation 0

      build_population(@population_size)
    end

    def build_population(population_size)
      population_size.times do |i|
        @members << organism.new
      end
    end

    def evolve!
      until evolution_over?
        make_next_generation!
      end
    end

    def weighted_select(members)
      e = 0.01
      fitness_sum = members.inject(0) { |sum, m| sum + m.fitness }

      weighted_members = members.sort_by do |m|
        (m.fitness - fitness_goal).abs
      end.map do |m|
        [m, fitness_sum / ((m.fitness - fitness_goal).abs + e)]
      end

      weight_sum = weighted_members.inject(0) { |sum, m| sum + m[1] }
      pick = (0..weight_sum).to_a.sample

      weighted_members.reverse! # In order to pop from the end we need the lowest ranked first
      pick_sum = 0

      until pick_sum > pick do
        selected_member = weighted_members.pop
        pick_sum += selected_member[1]
      end

      selected_member.first
    end

    def set_members_fitness!(fitness_values)
      members.to_enum.each_with_index { |m, i| m.fitness = fitness_values[i] }
    end

    def make_next_generation!
      temp_members = members
      used_members = []
      new_members = []

      until new_members.length == members.length / 2
        m1 = weighted_select(members - used_members)
        used_members << m1
        m2 = weighted_select(members - used_members)
        used_members << m2

        new_members << apply_pairwise_evolutions(organism, m1, m2)
      end

      new_members.flatten!
      @members = apply_non_pairwise_evolutions(new_members)
      @generation += 1
    end

    def apply_pairwise_evolutions(organism, m1, m2)
      evolution_types.inject([m1, m2]) do |ret, evolution_type|
        if evolution_type.pairwise?
          evolution_type.evolve(organism, *ret)
        else
          ret
        end
      end
    end

    def apply_non_pairwise_evolutions(members)
      evolution_types.inject(members) do |ret, evolution_type|
        if evolution_type.pairwise?
          ret
        else
          evolution_type.evolve(ret)
        end
      end
    end

    def evolution_over?
      # check if the fiteness goal or generation limit has been met
      if generations_limit > 0
        generation == generations_limit || best_member.fitness == fitness_goal
      else
        generation == generations_limit || best_member.fitness == fitness_goal
      end
    end

    def best_member
      @members.sort_by { |m| m.fitness }.first
    end

    def size
      @members.length
    end
  end

end
