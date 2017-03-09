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


def reset_iteration
  $iterationsToStop = KZ
end

def function(x)
  A*x**3 + B*x**2 + C*x + D
end

def random_phenotype(min = 0, max = 31)
  rand(min..max)
end

def list_of_random_phenotypes(quantity = 6)
  phenotype = []
  quantity.times do
    phenotype.push(random_phenotype)
  end
  phenotype
end

def function_results(phenotypes)
  puts "\nFunction results:"
  results = []
  for pt in phenotypes
    result = function(pt)
    puts "\t#{pt} => #{result}"
    if result > $bestResult.to_f
      puts "\t\tFound better result #{$bestResult} => #{result}"
      $bestResult = result
      $bestPhenotype = pt
      reset_iteration
    end
    results.push(result)
  end
  results
end

def evaluation_of_population(results)
  sumResults = results.inject(:+)

  evaluation = []
  for result in results
    evaluation.push( evaluation.last.to_f + result.to_f / sumResults )
  end
  evaluation
end

def roulette(phenotypes, evaluation)
  puts "\nRoulette:"
  winners = []
  phenotypes.length.times do
    randNumber = rand(0.0..1.0)
    evaluation.length.times do |i|
      if randNumber <= evaluation[i]
        puts "\tRandom number: #{randNumber}\t<= #{phenotypes[i]}"
        winners.push(phenotypes[i])
        break
      end
    end
  end
  puts
  winners
end

def phenotypes_to_genotypes(phenotypes)
    genotypes = []
    for f in phenotypes
      genotypes.push("%05b" % f)
    end
    genotypes
end

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
  print "\t\ttrue\t#{genotype} => index #{mutationPoint} "
  genotype[mutationPoint] = genotype[mutationPoint] == "0" ? "1" : "0"
  print "=> #{genotype}\n"
  genotype
end

def crossover(gene1, gene2)
  raise "Genotypes must have the same length." if gene1.length != gene2.length

  crossoverPoint = rand(1...gene1.length)
  newGene1 = gene1[0, crossoverPoint] + gene2[crossoverPoint..-1]
  newGene2 = gene2[0, crossoverPoint] + gene1[crossoverPoint..-1]
  print "\n\t\t#{gene1}, #{gene2} => crossover point #{crossoverPoint}"
  print " => #{newGene1}, #{newGene2}"
  [newGene1, newGene2]
end

def generate_children(winners)
  puts "\nGenerate children:"
  children = []
  puts "\tChange phenotypes to genotypes:"
  genotypes = phenotypes_to_genotypes(winners)
  winners.each_with_index do |w, i|
    puts "\t\t#{w} => #{genotypes[i]}"
  end

  genotypes.length.times do |i|
    if i.even?
      parent1, parent2 = genotypes[i], genotypes[i+1]
      # If crossover? give TRUE send parents to crossover
      # otherwise leave parents in the new population
      will_crossover = crossover?
      print "\n\tParents crossover: #{will_crossover}"
      if will_crossover
        children += crossover(parent1, parent2)
      else
        print "\n\t\tParents stay => #{parent1}, #{parent2}."
        children += [parent1, parent2]
      end
    end
  end

  # Mutation
  puts "\n\n\tMutations:"
  children.each_with_index do |child, i|
    if mutation?
      children[i] = mutation(child)
    else
      puts "\t\tfalse\t#{child}"
    end
  end

  puts "\n\tChange genotypes to phenotypes:"
  finalChildren = genotypes_to_phenotypes(children)
  children.each_with_index do |w, i|
    puts "\t\t#{w} => #{finalChildren[i]}"
  end
  finalChildren
end

def main
  phenotypes = list_of_random_phenotypes
  puts "Random phenotypes:"
  print phenotypes
  puts ""

  results = function_results(phenotypes)
  evaluation = evaluation_of_population(results)
  puts "Best result at the beginnig: #{$bestPhenotype} => #{$bestResult}"

  puts "\nEvaluation of population:"
  phenotypes.each_with_index do |pt, i|
    if i == 0
      puts "\t#{pt} => #{evaluation[i]}"
    else
      puts "\t#{pt} => #{evaluation[i]-evaluation[i-1]}"
    end
  end

  puts "\nFragments on the roulette wheel:"
  phenotypes.each_with_index do |pt, i|
    puts "\t#{pt} => #{evaluation[i]}"
  end

  winners = roulette(phenotypes, evaluation)
  phenotypesNew = generate_children(winners)
  puts "Old population:"
  print "#{phenotypes}\n"
  puts "New population:"
  print "#{phenotypesNew}\n"
  results = function_results(phenotypesNew)
  evaluation = evaluation_of_population(results)

  puts "\nBest result: #{$bestPhenotype} => #{$bestResult}"

end

main
