using NAB
using Base.Test, Base.Dates

include("test_helpers.jl")

function testNullCase()
    costMatrix = Dict{AbstractString, Float64}("tpWeight" => 1.0, "fpWeight" => 1.0, "fnWeight" => 1.0, "tnWeight" => 1.0)

    startTime = DateTime(now())
    increment = Minute(5)
    len = 10
    timestamps = generateTimestamps(startTime, increment, len)

    predictions = zeros(Int, len)

    labels = zeros(Int, len)

    windows = Array(Tuple{DateTime,DateTime},0)

    scorer = Scorer(timestamps, predictions, labels, windows, costMatrix, 0)

    scorer.getScore()

    @test scorer.score == 0.0
end

function testFalsePositiveScaling()
    costMatrix = Dict{AbstractString, Float64}("tpWeight" => 1.0, "fpWeight" => 1.0, "fnWeight" => 1.0, "tnWeight" => 1.0)

    startTime = DateTime(now())
    increment = Minute(5)
    len = 100
    numWindows = 1
    windowSize = 10

    timestamps = generateTimestamps(startTime, increment, len)
    windows = generateWindows(timestamps, numWindows, windowSize)
    labels = generateLabels(timestamps, windows)

    costMatrix["fpWeight"] = 0.11

    scores = []
    for i in 1:20
        predictions = zeros(Int, len)
        indices = rand(1:len, 10)
        predictions[indices] = 1
        scorer = Scorer(timestamps, predictions, labels, windows, costMatrix,0)
        scorer.getScore()
        push!(scores, scorer.score)
    end

    @test -1.5 <= mean(scores) <= 0.5
end

function testRewardLowFalseNegatives()
    costMatrix = Dict{AbstractString, Float64}("tpWeight" => 1.0, "fpWeight" => 1.0, "fnWeight" => 1.0, "tnWeight" => 1.0)

    startTime = DateTime(1970,1,1)
    increment = Minute(5)
    len = 100
    numWindows = 1
    windowSize = 10

    timestamps = generateTimestamps(startTime, increment, len)
    windows = generateWindows(timestamps, numWindows, windowSize)
    labels = generateLabels(timestamps, windows)
    predictions = zeros(Int, len)
    costMatrix["fpWeight"] = 1.0
    costMatrixFN = deepcopy(costMatrix)
    costMatrixFN["fnWeight"] = 2.0
    costMatrixFN["fpWeight"] = 0.055

    scorer1 = Scorer(timestamps, predictions, labels, windows, costMatrix,0)
    scorer1.getScore()

    scorer2 = Scorer(timestamps, predictions, labels, windows, costMatrixFN,0)
    scorer2.getScore()

    @test scorer1.score == 0.5*scorer2.score

    checkCounts(scorer1.counts, len-windowSize*numWindows, 0, 0,windowSize*numWindows)

    checkCounts(scorer2.counts, len-windowSize*numWindows, 0, 0,windowSize*numWindows)
end

function testRewardLowFalsePositives()
    costMatrix = Dict{AbstractString, Float64}("tpWeight" => 1.0, "fpWeight" => 1.0, "fnWeight" => 1.0, "tnWeight" => 1.0)

    startTime = DateTime(now())
    increment = Minute(5)
    len = 100
    numWindows = 0
    windowSize = 10

    timestamps = generateTimestamps(startTime, increment, len)
    windows = Array(Tuple{DateTime,DateTime},0)
    labels = generateLabels(timestamps, windows)
    predictions = zeros(Int, len)

    costMatrixFP = deepcopy(costMatrix)
    costMatrixFP["fpWeight"] = 2.0
    costMatrixFP["fnWeight"] = 0.5
    # FP
    predictions[1] = 1

    scorer1 = Scorer(timestamps, predictions, labels, windows, costMatrix, 0)
    (_, score1)= scorer1.getScore()
    scorer2 = Scorer(timestamps, predictions, labels, windows, costMatrixFP,0)
    (_, score2) = scorer2.getScore()

    @test score1 == 0.5*score2
    checkCounts(scorer1.counts, len-windowSize*numWindows-1, 0, 1, 0)
    checkCounts(scorer2.counts, len-windowSize*numWindows-1, 0, 1, 0)
end

function testScoringAllMetrics()
    costMatrix = Dict{AbstractString, Float64}("tpWeight" => 1.0, "fpWeight" => 1.0, "fnWeight" => 1.0, "tnWeight" => 1.0)

    startTime = DateTime(now())
    increment = Minute(5)
    len = 100
    numWindows = 2
    windowSize = 5

    timestamps = generateTimestamps(startTime, increment, len)
    windows = generateWindows(timestamps, numWindows, windowSize)
    labels = generateLabels(timestamps, windows)
    predictions = zeros(Int, len)

    index = findfirst(timestamps .== windows[1][1])
    # TP, add'l TP, and FP
    predictions[index] = 1
    predictions[index+1] = 1
    predictions[index+7] = 1

    scorer = Scorer(timestamps, predictions, labels, windows, costMatrix, 0)
    (_, score) = scorer.getScore()

    @test_approx_eq_eps(score, -0.9540, 1e-4)
    checkCounts(scorer.counts, len-windowSize*numWindows-1, 2, 1, 8)
end

function checkCounts(counts, tn, tp, fp, fn)
  """Ensure the metric counts are correct."""
  @test counts["tn"] == tn
  @test counts["tp"] == tp
  @test counts["fp"] == fp
  @test counts["fn"] == fn
end

testNullCase()
testFalsePositiveScaling()
testRewardLowFalseNegatives()
testRewardLowFalsePositives()
testScoringAllMetrics()