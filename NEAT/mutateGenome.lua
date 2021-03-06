--Pretty print

require("NEAT/util/getRandomNeuron")
require("NEAT/util/generateNeurons")

local MUTATE_ADD_SYNAPSE = 1
local MUTATE_ADD_NEURON = 2
local MUTATE_MODIFY_SYNAPSE = 3

--Create mutations on the genome 
function mutateGenome(genome)
	--Modify the mutation rates?

	--Determine if we should re-weigh synapses
	if math.random() < SYNAPSE_WEIGHT_MUTATION_CHANCE then
		mutateSynapseWeights(genome)
	end

	--Determine if we should add a synapse
	if math.random() < ADD_SYNAPSE_MUTATION_CHANCE then
		mutateAddSynapse(genome)
		mutateAddSynapse(genome)
	end

	--Determine if we should add a neuron
	if math.random() < ADD_NEURON_MUTATION_CHANCE then
		mutateAddNeuron(genome)
	end
end

--Mutate all weights of synapses
function mutateSynapseWeights(genome)
	for i=1,#genome.synapses do
		local synapse = genome.synapses[i]

		--Determine if we are to completely change it or just "perturb" it
		if math.random() < SYNAPSE_WEIGHT_PERTURB_MUTATION_CHANCE then
			--Just perturb
			synapse.weight = synapse.weight + math.random() * SYNAPSE_PERTURBATION_BIAS
		else
			--Completely random
			synapse.weight = math.random()
		end
	end
end

--Randomly pick two neurons to connect
function mutateAddSynapse(genome)
	local neurons = generateNeurons(genome.synapses)
	local fromNeuron = getRandomNeuron(neurons, true, 0)
	local toNeuron = getRandomNeuron(neurons, false, fromNeuron.label)

	local newSynapse = Synapse:new()

	newSynapse.from = fromNeuron.label
	newSynapse.to = toNeuron.label

	--Check to make sure we're not adding a synapse that already exists
	-- (perhaps this should never be possible?)
	--if(synapseExists(newSynapse, genome.synapses)) then
	--	return
	--end

	--Give the new synapse a random weight
	newSynapse.weight = math.random()

	table.insert(genome.synapses, newSynapse)
end

--Randomly pick a synapse to split and add a neuron to
function mutateAddNeuron(genome)
	--No synapses to split?
	if #genome.synapses == 0 then
		return
	end

	--Pick a synapse
	local splitSynapse = genome.synapses[math.random(1,#genome.synapses)]

	--If the synapse is disabled, ignore this (Should this even be possible?)
	if not splitSynapse.enabled then
		return
	end

	--Disable the old synapse
	splitSynapse.gotsplit = true
	splitSynapse.enabled = false

	--Create a new neuron
	genome.maxNeuron = genome.maxNeuron + 1

	--TODO assign these synapses IDs
	local firstSynapse = Synapse:new()
	firstSynapse.from = splitSynapse.from
	firstSynapse.to = genome.maxNeuron
	firstSynapse.weight = 1
	firstSynapse.enabled = true


	local secondSynapse = Synapse:new()
	secondSynapse.from = genome.maxNeuron
	secondSynapse.to = splitSynapse.to
	secondSynapse.weight = splitSynapse.weight
	secondSynapse.enabled = true

	--Add both new synapses
	table.insert(genome.synapses, firstSynapse)
	table.insert(genome.synapses, secondSynapse)
end