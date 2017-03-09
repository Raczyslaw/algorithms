##################################################
# Genetic algorithm
# for finding the maximum of a function
#
# ax3 + bx2 + cx + d
##################################################

# function coefficients
A = -1
B = 32
C = 0
D = 50
# Probabilities of crossover and mutation
PK = 0.8
PM = 0.2

# Number of iterations without finding a better result
KZ = 50

$iterationsToStop = KZ
$bestResult = nil
$bestPhenotype = nil

# Reset iteration to stop algorithm
def reset_iteration
  $iterationsToStop = KZ
end

# Function f(x)
def function(x)
  A*x**3 + B*x**2 + C*x + D
end

# Generate random phenotype
def random_phenotype(min = 0, max = 31)
  rand(min..max)
end

# Generate array with random phenotypes
def list_of_random_phenotypes(quantity = 6)
  phenotype = []
  quantity.times do
    phenotype.push(random_phenotype)
  end
  phenotype
end

# Return array with function results for given phenotypes
def function_results(phenotypes)
  results = []
  for pt in phenotypes
    result = function(pt)
    abort('Function must return positive result') if result < 0
    if result > $bestResult.to_f
      # Save best result, phenotype and reset iterations to stop algorithm
      $bestResult = result
      $bestPhenotype = pt
      reset_iteration
    end
    results.push(result)
  end
  results
end

# Generate points for roulette (0.0 - 1.0)
def evaluation_of_population(results)
  sumResults = results.inject(:+)

  evaluation = []
  for result in results
    evaluation.push( evaluation.last.to_f + result.to_f / sumResults )
  end
  evaluation
end

# Draw parents for crossover
def roulette(phenotypes, evaluation)
  winners = []
  phenotypes.length.times do
    randNumber = rand(0.0..1.0)
    evaluation.length.times do |i|
      if randNumber <= evaluation[i]
        winners.push(phenotypes[i])
        break
      end
    end
  end
  winners
end

# Return binary representation of the phenotypes in String
def phenotypes_to_genotypes(phenotypes)
    genotypes = []
    for f in phenotypes
      genotypes.push("%05b" % f)
    end
    genotypes
end

# Change binary Strings to Intigers
def genotypes_to_phenotypes(genotypes)
  phenotypes = []
  for g in genotypes
    phenotypes.push(g.to_i(2))
  end
  phenotypes
end

def crossover?
  rand(0.0..1.0) < PK
end

def mutation?
  rand(0.0..1.0) < PM
end

def mutation(genotype)
  mutationPoint = rand(0...genotype.length)
  genotype[mutationPoint] = genotype[mutationPoint] == "0" ? "1" : "0"
  genotype
end

def crossover(gene1, gene2)
  raise "Genotypes must have the same length." if gene1.length != gene2.length

  crossoverPoint = rand(1...gene1.length)
  newGene1 = gene1[0, crossoverPoint] + gene2[crossoverPoint..-1]
  newGene2 = gene2[0, crossoverPoint] + gene1[crossoverPoint..-1]

  [newGene1, newGene2]
end

def generate_children(winners)
  children = []
  genotypes = phenotypes_to_genotypes(winners)

  # Crossover
  genotypes.length.times do |i|
    if i.even?
      parent1, parent2 = genotypes[i], genotypes[i+1]

      # If crossover? give TRUE send parents to crossover
      # otherwise leave parents in the new population
      genes = crossover? ? crossover(parent1, parent2) : [parent1, parent2]
      children += genes
    end
  end

  # Mutation
  children.each_with_index do |child, i|
    children[i] = mutation(child) if mutation?
  end

  # Return children as phenotypes
  children = genotypes_to_phenotypes(children)
end

def main
  phenotypes = list_of_random_phenotypes
  puts "Random phenotypes:"
  print phenotypes

  results = function_results(phenotypes)
  evaluation = evaluation_of_population(results)

  puts "\nBest result at the beginnig: #{$bestPhenotype} => #{$bestResult}"

  iteration = 0

  until $iterationsToStop < 1
    winners = roulette(phenotypes, evaluation)
    phenotypes = generate_children(winners)
    # print phenotypes
    # puts ""
    results = function_results(phenotypes)
    evaluation = evaluation_of_population(results)

    $iterationsToStop -= 1
    iteration += 1
  end

  puts "\nAfter #{iteration} iterations the best result is:"
  puts "#{$bestPhenotype} => #{$bestResult}"

end

main
