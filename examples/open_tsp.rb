require 'darwinning'
require 'pp'

class OpenTSP < Darwinning::Organism
  CANT_NODES = 5

  OpenTSP::CANT_NODES.times do |s|
    @genes << Darwinning::Gene.new(
      name: s, value_range: (0..OpenTSP::CANT_NODES - 1)
    )
  end

  def fitness
    return Float::INFINITY if repeated_node

    fitness = 0
    previous_node_id = nil

    genotypes.each_value do |node_id|
      fitness += distance(previous_node_id, node_id) if previous_node_id

      previous_node_id = node_id
    end

    fitness
  end

  def distance_matrix
    [
      [ 0,  10,  20,  30,  100],
      [10,   0,  10,  20,  100],
      [20,  10,   0,  10,  100],
      [30,  20,  10,   0,  100],
      [100, 100, 100, 100,  0 ]
    ]
  end

  def distance(from_node_id, to_node_id)
    distance_matrix[from_node_id][to_node_id]
  end

  def repeated_node
    genotypes.values.uniq.length < genotypes.values.length
  end
end

class OpenTSPPopulation < Darwinning::Population
  def build_population(population_size)
    population_size.times do
      sample = (0..OpenTSP::CANT_NODES - 1).to_a.shuffle

      member = OpenTSP.new
      member.genotypes.zip(sample).each do |genotype, value|
        member.genotypes[genotype[0]] = value
      end

      @members << member
    end
  end
end


evolution_types = [
  Darwinning::EvolutionTypes::Reproduction.new(
    crossover_method: :pmx_swap
  ),
  Darwinning::EvolutionTypes::Mutation.new(
    mutation_method: :interchange_random_genotypes,
    mutation_rate: 0.10
  )
]

open_tsp_pop = OpenTSPPopulation.new(
  organism: OpenTSP, population_size: 20,
  fitness_goal: 0, generations_limit: 200,
  evolution_types: evolution_types
)
open_tsp_pop.evolve!

pp "Best member: #{open_tsp_pop.best_member.genotypes.values}"
pp "Best member: #{open_tsp_pop.best_member.fitness}"
