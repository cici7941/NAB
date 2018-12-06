Numenta Anomaly Benchmark for Evaluating Algorithms for Anomaly Detection in Streaming


### Quick usage

```julia
using NAB, DataFrames

data = <DataFrame for anomaly detection>

data[:timestamp] = DateTime(data[:timestamp], "yyyy-mm-dd HH:MM:SS")

trueAnomalies = [DateTime(2015,8,11,12,7)]

predictions = <DataFrame with timestamps and corresponding labels>

detectorName = <The name of anomaly detection algorithm>

costMatrix = Dict(
    "tpWeight" => 1.0,
    "fnWeight" => 1.0,
    "fpWeight" => 1.0
)

scorer = scoreDataSet(Labeler(0.1,0.15), data, trueAnomalies, predictions,
detectorName=detectorName, costMatrix=costMatrix)["scorer"]

normalizedScore = scorer.normalizeScore()
```
